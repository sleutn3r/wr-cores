------------------------------------------------------------------------
-- Title      : Forward Error Correction
-- Project    : WhiteRabbit Node
-------------------------------------------------------------------------------
-- File       : wr_fec_en_engine.vhd
-- Author     : Maciej Lipinski
-- Company    : CERN BE-Co-HT
-- Created    : 2011-04-01
-- Last update: 2011-07-27
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-- 
-- 
-- 
-- Reception of data (Reception FSM):
-- * it expects the information about the size of the message (payload) to be 
--   FECed
-- * it stores the header in a separate RAM buffer, exchanging the EtherType to 
--   FEC's one (parameter)
-- * it creates FEC header which is added to the output messages with:
--   -> FEC schema      (4  bits) - what FECing method is used
--   -> fec Fragment ID (4  bits) - number of FECed frame within single FECing 
--   -> message ID      (16 bits) - number of the FECed (Control) message (to 
--                                  identify lost Control messages)
--   -> orig etherType  (16 bits) - the etherType replaced by FEC etherType TODO(5)
--   -> original lenght (13 bits) - the size of the payload before FECing
--   -> fragment lenght (11 bits) - the size of the FECed payload following the FEC
--                                  header
-- * it stores the payload in 64 bits words in two RAMs (the same data in both RAMS)
-- * it splits the incoming payload into even bits (adds padding if necessary)
-- 
-- Reception of settings:
-- * the size of the payload (in bytes)
-- * etherType of the original frame (provided by the interface)
-- * FEC_ID (not implemented yet, TODO(6))
-- 
-- 
-- Reed Solomon (RS FSM)
-- * controls the process of producing Parity Messages
-- * it uses two halves of the original message (payload)
-- * the RSing is done by Wesley's code
-- * uses Payload RAM 2
-- 
-- Hamming (FSM)
-- * run in paraller with RS FSM, since the original part 
-- * can be encoded before RS is finished,
-- * RS FSM just needs to wait for the Parity Messages to be produced
-- * it takes 64 bits at a time and produces 64+8 bits which are written
--   to round buffer (2*72 bits). (out_buffer) 
-- * round buffer is used because the 144 bits' number is not very 
--   convenient, the data is sent from the out_buffer
-- 
-- Sending (FSM)
-- * takes data from the round buffer (out_buffer) and sends in 16 bits words
-- * any flexibility of output data is not implemented
-- * for each frame
--   -> first the ethernet header is send (stored in header RAM)
--   -> then FEC header is sent
--   -> then the data from the round buffer is sent
-- 
-- 
-- 
-------------------------------------------------------------------------------
--
-- Copyright (c) 2011 Maciej Lipinski / CERN
--
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2011-04-01  1.0      mlipinsk Created
-- 2011-07-27  1.0      mlipinsk debugged
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wr_fec_pkg.all;
use work.genram_pkg.all; -- wrappers for RAM/FIFO by Tomek
use work.rs_pkg.all; -- Wesley's work
--use work.hamm_package_496bit.all;
use work.hamm_package_64bit.all;
use work.wr_hamming_pkg.all;

entity wr_fec_en_engine is
  port (
     clk_i   : in std_logic;
     rst_n_i : in std_logic;
    
     -- input data to be encoded
     if_data_in        : in  std_logic_vector(c_fec_engine_data_width  - 1 downto 0);
     
     -- input data byte sel
     if_byte_sel_i     : in std_logic_vector(c_fec_engine_Byte_sel_num  - 1 downto 0);     
     
     -- encoded data
     if_data_o         : out std_logic_vector(c_fec_engine_data_width  - 1 downto 0);
     
     -- indicates which Bytes of the output data have valid data
     if_byte_sel_o     : out std_logic_vector(c_fec_engine_Byte_sel_num  - 1 downto 0);
     
     -- size of the incoming message to be encoded (entire Control Message)
     if_msg_size_i     : in  std_logic_vector(c_fec_msg_size_MAX_Bytes_width     - 1 downto 0);
     
     
     -- tells FEC whether use FEC_ID provided from outside word (HIGH)
     -- or generate it internally (LOW)
     if_FEC_ID_ena_i   : in std_logic;
     
     -- ID of the message to be FECed, used only if if_FEC_ID_ena_i=HIGH
     if_FEC_ID_i       : in  std_logic_vector(c_fec_FEC_header_FEC_ID_bits     - 1 downto 0);
     -- information what the engine is supposed to do:
     -- 0 = do nothing
     -- 1 = header is being transfered
     -- 2 = payload to be encoded is being transfered
     -- 3 = transfer pause
     -- 4 = message end
     -- 5 = abandond FECing
     if_in_ctrl_i         : in  std_logic_vector(2 downto 0);

     -- strobe when settings (msg size and output msg number) available
     if_in_settngs_ena_i  : in std_logic;
          
     -- it provides to the FEC engine original etherType, which should be 
     -- added to the FEC header, the interface remembers the original etherType 
     -- and sends to the FEC engine the frame header with already replaced 
     -- etherType (FEC etherType).
     -- this output is assumed to be valid on the finish of header trasmission
     -- so starting with the first word of the PAYLOAD
     if_in_etherType_i : in std_logic_vector(15 downto 0);           
          
     -- Input error indicator, :
     -- 0 = ready for data
     -- 1 = no frame size provided...
     if_in_ctrl_o         : out std_logic;

     -- indicates whether engine is ready to encode new Control Message
     -- 0 = idle
     -- 1 = busy
     if_busy_o         : out std_logic;

     -- info about output data
     -- 0 = no data ready
     -- 1 = outputing header 
     -- 2 = outputing payload
     -- 3 = output pause 
     --if_out_ctrl_o         : out  std_logic_vector(1 downto 0);
     
     -- 0 = data not available
     -- 1 data valid
     if_out_ctrl_o         : out  std_logic;
     
     -- is like cyc in WB, high thourhout single frame sending
     if_out_frame_cyc_o    : out std_logic;
     
     -- frame start (needs to be used with if_out_ctrl_o)
     if_out_start_frame_o  : out std_logic;
     
     -- last (half)word of the frame
     if_out_end_of_frame_o : out std_logic;
     
     -- the end of the last frame
     if_out_end_of_fec_o   : out std_logic;
     
     -- indicates whether output interface is ready to take data
     -- 0 = ready
     -- 1 = busy     
     if_out_ctrl_i         : in  std_logic;
     
     -- '1' => VLAN-taged frame
     -- '0' => untagged frame
     -- vlan_taggged_frame_i  : in std_logic;     
     
     -- info on desired number of output messages, should be available 
     -- at the same time as
     if_out_MSG_num_i  : in  std_logic_vector(c_fec_out_MSG_num_MAX_width - 1 downto 0)     

  );
end wr_fec_en_engine;

architecture rtl of wr_fec_en_engine is

  -- input data
  signal if_data_i         : std_logic_vector(c_fec_engine_data_width  - 1 downto 0);
  
  -----------------------------------------------------------------------
  -- big buffer-registers for data
  -----------------------------------------------------------------------  
  
  -- we write data to this buffer and later to ram
  signal input_buffer        : std_logic_vector(c_fec_ram_data_width - 1 downto 0);
  
  signal out_buffer           : std_logic_vector(143 downto 0);
  
  -- this stores FEC's header
  signal fec_header_buffer      : std_logic_vector(c_fec_FEC_header_size_bits - 1 downto 0);
  
  -- original valid
  signal fec_header_etherType_valid : std_logic;
  -----------------------------------------------------------------------
  -- Message size at different stages of encoding
  -----------------------------------------------------------------------  
  
  -- divFECin_msg_size=2*CEIL(in_msg_size/2), 
  signal divFECin_msg_size :  std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);
  
  -- break_msg_at_size = CEIL(divFECin_msg_size)
  signal break_msg_at_size :  std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);
  -- size of single message (~half of the original one) to be inputed to RS module 
  -- by M Bytes chunks, therefore, this size is 
  --     RSin_msg_size=M*CEIL(divFECin_msg_size/M), 
  --- the additional Bytes are padded
  signal RSin_msg_size :  std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);

  
  signal eth_header_size :  std_logic_vector(c_fec_Ethernet_header_size_MAX_bits_width - 1 downto 0);

  -- indicates when framgent counter should be incremented and stored in the FEC header buffer
  -- driven by the sending_fsm, used by the settings process
  signal inc_fragmentID  :  std_logic;
  -----------------------------------------------------------------------
  -- Message numbers (not configurable, for the time being)
  -----------------------------------------------------------------------  
  
  -- required number of output FECed messages
  signal out_MSG_num    :  std_logic_vector(c_fec_out_MSG_num_MAX_width- 1 downto 0); 

  -- number of the output messages which hold original data (2 or 6 for the time being)
  signal out_orig_data_MSG_num :  std_logic_vector(c_fec_out_MSG_num_MAX_width- 1 downto 0); 
  
  
  
  -----------------------------------------------------------------------
  -- Hamming staff
  ----------------------------------------------------------------------- 
    
  -- input to hamming function
  signal hamming_in_data       : data_ham_64bit;
  
  signal hamming_parity_tmp    : parity_ham_64bit;
  -- 
  signal current_hamming_buf_num : std_logic;   

  -----------------------------------------------------------------------
  -- RAM address indicators, 
  ----------------------------------------------------------------------- 
  -- RAM address pointer to the first chunk (original msg divided by N) of info
  signal p_addr_rd_first_divMsg  : std_logic_vector(c_fec_ram_addr_width    - 1 downto 0);  
  
  -- RAM address pointer to the currently read chunk (original msg divided by N) of info
  signal p_addr_rd_next_divMsg  : std_logic_vector(c_fec_ram_addr_width    - 1 downto 0);  
  
  -- this is size (in RAM addresses) of a single divMsg (so incoming frame/Msg divided by
  -- appropriate number, i.e. 2, and padded)
  signal ram_addr_divMsg_size : std_logic_vector(c_fec_ram_addr_width    - 1 downto 0);  
  
  -- this is size (in RAM addresses) of entire original input Msg (frame)
  signal ram_addr_origMsg_size : std_logic_vector(c_fec_ram_addr_width    - 1 downto 0);  
  
  -----------------------------------------------------------------------
  -- FINITE STATE MACHINE definitions
  -----------------------------------------------------------------------  

  -- reception FSM
  type t_receive_state is (
       	S_IDLE,          -- doing nothing
        S_HEADER,        -- receiving header
	      S_PAYLOAD,       -- receiving payload to be encoded
        S_PAUSE,         -- pause in receiving header or payload
        S_WAIT_ENCODING  -- wait util encoding and sending of the message is 
			 -- finished
	);      

  -- Hamming encoding FSM
  type t_hamming_state is (
       	S_IDLE,                  -- doing nothing
        S_WAIT_ENOUGH_DATA_B1,      -- we wait until enough data is received for the
                                 -- coder to work
        S_WAIT_ENOUGH_DATA_B2,      -- we wait until enough data is received for the
                                 -- coder to work                                 
        S_WAIT_ENOUGH_RS_PARITY_B1, -- wait for parity words generated by RS                    
        S_WAIT_ENOUGH_RS_PARITY_B2, -- wait for parity words generated by RS                    
        S_HAMMING_ORIGINAL_MSG_B1,
        S_HAMMING_ORIGINAL_MSG_B2,
       	S_HAMMING_RS_PARITY_MSG_B1,     -- push data into hamming function
       	S_HAMMING_RS_PARITY_MSG_B2,     -- push data into hamming function
       	S_ALL_HAMMED             -- all messges hammed
	);      

  -- R-S encoding FSM
  type t_rs_state is (
       	S_IDLE,              -- doing nothing
       	S_SET,               -- setting RS engine
        S_WAIT_ENOUGH_DATA,  -- we wait until enough data is received for the
                             -- coder to work. In particular, the last to-be-FECed
                             -- message is being received (M Bytes already received)
        S_LOAD_EMPTY_DATA,   -- loading empty words, we will get RS parity codes in their place 
        S_LOAD_DATA,         -- loading data to be encoded
       	S_RSENCODE,          -- encoding with R-S (give it few cycles)
        S_RSENCODING_FINISHED-- encoding finished, we write resulting symbols to 
                             -- the buffer
	);      
  -- sending FSM
  type t_sending_state is (
 	      S_IDLE,            -- doing nothing
        S_WAIT_DATA,       --
        S_SEND_ETHERNET_HEADER,         -- 
        S_SEND_FEC_HEADER,
        S_SEND_PAYLOAD,
        S_NEXT_FRAME,      --
        S_PAUSE,           -- pause in sending header or payload
        S_ALL_SENT         -- FEC module is done with the current Control Message
	);      

  -- declarations
  signal receive_state    : t_receive_state;
  signal hamming_state    : t_hamming_state;
  signal rs_state         : t_rs_state;
  signal sending_state    : t_sending_state;

  -----------------------------------------------------------------------
  -- Reed Solomon
  -----------------------------------------------------------------------  

  -- indicates to the RS encoder/decoder which messages are missing
  signal rs_indices        : Karray ;
  
  -- request to load load pattern (above indices)
  signal rs_load_indices   : std_logic;
  
  -- load data in
  signal rs_enable_in      : std_logic;
  
  -- input data stream
  signal rs_stream_in      : Marray;
  
  signal rs_setting_finished  : std_logic;
  
  signal rs_encoding_done  : std_logic;
  
  signal rs_out_result      : KMarray;
  -----------------------------------------------------------------------
  -- Other signals (hell of a lot of)
  -----------------------------------------------------------------------  
  signal zeros            : std_logic_vector(31 downto 0);
  signal FECsettingsReady : std_logic;
  signal FECsettingsUsed  : std_logic;

  
  -- '1' when finished receiving message
  signal in_msg_received  : std_logic;

  -- sending FSM indicates that it used all parity bits
  signal all_HAM_parity_bits_sent_B1 :std_logic;
  signal all_HAM_parity_bits_sent_B2 :std_logic;
  
  -- indicates that parity bits are ready to be used
  signal HAM_parity_bits_ready_B1 : std_logic;
  signal HAM_parity_bits_ready_B2 : std_logic;
  
  
  -----------------------------------------------------------------------
  -- RAM signals
  -----------------------------------------------------------------------   
  -- header
  signal header_ram_we         : std_logic;
  signal header_ram_rd_address : std_logic_vector(c_fec_Ethernet_header_ram_addr_width    - 1 downto 0);
  signal header_ram_wr_address : std_logic_vector(c_fec_Ethernet_header_ram_addr_width    - 1 downto 0);
  signal header_ram_input      : std_logic_vector(c_fec_engine_data_width - 1 downto 0);
  signal header_ram_output     : std_logic_vector(c_fec_engine_data_width - 1 downto 0);

  
  -- ORIG_PAYLOAD_1 and ORIG_PAYLOAD_2
  signal op_ram_we         : std_logic;
  signal op_ram_wr_address : std_logic_vector(c_fec_ram_addr_width    - 1 downto 0);
  signal op_ram_input      : std_logic_vector(c_fec_Hamming_word_size - 1 downto 0);

  -- ORIG_PAYLOAD_1 
  signal op_1_ram_rd_address : std_logic_vector(c_fec_ram_addr_width    - 1 downto 0);
  signal op_1_ram_output     : std_logic_vector(c_fec_Hamming_word_size - 1 downto 0);
  
  -- ORIG_PAYLOAD_2
  signal op_2_ram_rd_address : std_logic_vector(c_fec_ram_addr_width    - 1 downto 0);
  signal op_2_ram_output     : std_logic_vector(c_fec_Hamming_word_size - 1 downto 0);
  
  -- RS_PAYLOAD
  signal rs_ram_we         : std_logic;
  signal rs_ram_rd_address : std_logic_vector(c_fec_ram_addr_width    - 1 downto 0);
  signal rs_ram_wr_address : std_logic_vector(c_fec_ram_addr_width    - 1 downto 0);
  signal rs_ram_output     : std_logic_vector(c_fec_Hamming_word_size - 1 downto 0);
  signal rs_ram_input      : std_logic_vector(c_fec_Hamming_word_size - 1 downto 0);
  
  
  signal p_rs_ram_wr_first_msg_add : std_logic_vector(c_fec_ram_addr_width    - 1 downto 0);  
  signal p_rs_ram_wr_next_msg_add : std_logic_vector(c_fec_ram_addr_width    - 1 downto 0);  
  -- very important !!!
  -- determinse which RS result symbo to write to RAM
  -- TODO: configurable
  signal result_symbol     : std_logic;
  
  -- counts input words (word is assumed to be 16bits)
  signal input_payload_word_cnt : std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);
  signal input_payload_size_cnt : std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);
  
  
  -- when the package is divided in the middle of 32 word  
  signal odd_write               : std_logic;
  signal write_input             : std_logic;
  
  signal help_input_buffer   : std_logic_vector(7 downto 0);
  
  -- to see in which DivMsg we are
  signal in_second_msg       : std_logic;
  
  signal mem_all_HAM_parity_bits_sent_b1 : std_logic;
  signal mem_all_HAM_parity_bits_sent_b2 : std_logic;
  
  signal output_words_cnt_mod9 : std_logic_vector(3 downto 0);                
  signal output_words_cnt      : std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);   
  
  signal finished_encoding : std_logic;
  
  signal rs_finished : std_logic;
  
  signal end_of_outmsg : std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);
  
  signal if_out_frame_cyc : std_logic;
  
  signal out_helper_buffer : std_logic_vector(c_fec_engine_data_width  - 1 downto 0);
  
  -- remember that there was ctrl_out_i
  signal out_helper_ctrl_d : std_logic;
  
begin 
  
  zeros(31 downto 0 ) <= (others => '0');
 
  
  
  
  RS_MODULE :  RS_erasure 
    port map(
      clk_in     => clk_i,
      rst_n_i    => rst_n_i,
      -- controls to program the loss pattern
      i_in       => rs_indices,
      request_in => rs_load_indices,
      ready_out  => rs_setting_finished,
      -- controls for decoding the preprogrammed loss pattern
      enable_in  => rs_enable_in,
      stream_in  => rs_stream_in,
      done_out   => rs_encoding_done,
      result_out => rs_out_result
      );
  
  -- memory for ethernet header
  -- written from input (received frame)
  -- read when sending
  HEADER : generic_dpram
    generic map(
      g_data_width               => c_fec_engine_data_width,        -- 16 bits
      g_size                     => c_fec_Ethernet_header_ram_size) -- 10 words
    port map( 
      rst_n_i                    => rst_n_i,
      clka_i                     => clk_i,
      bwea_i                     => "00",
      wea_i                      => header_ram_we,
      aa_i                       => header_ram_wr_address,
      da_i                       => header_ram_input, 
      qa_o                       => open,
      clkb_i                     => clk_i,
      bweb_i                     => "00",
      web_i                      => '0',
      ab_i                       => header_ram_rd_address,
      db_i                       => x"0000",
      qb_o                       => header_ram_output);
  
  
  -- memory for payload
  -- A: written from input (received frame)
  -- B: read by Hamming    
  ORIG_PAYLOAD_1 : generic_dpram
    generic map(
      g_data_width               => c_fec_ram_data_width, -- 64  bits
      g_size                     => c_fec_ram_size)       -- 753 words
    port map( 
      rst_n_i                    => rst_n_i,
      clka_i                     => clk_i,
      bwea_i                     => "00000000",
      -- a is input
      wea_i                      => op_ram_we,
      aa_i                       => op_ram_wr_address,
      da_i                       => op_ram_input, 
      qa_o                       => open,
      clkb_i                     => clk_i,
      bweb_i                     => "00000000",
      web_i                      => '0',
      ab_i                       => op_1_ram_rd_address,
      db_i                       => x"0000000000000000",
      qb_o                       => op_1_ram_output);

  -- memory for payload
  -- A: written from input (received frame)
  -- B: read by Reed-Solomon
  ORIG_PAYLOAD_2 : generic_dpram
    generic map(
      g_data_width               => c_fec_ram_data_width, -- 64  bits
      g_size                     => c_fec_ram_size)       -- 753 words
    port map( 
      rst_n_i                    => rst_n_i,
      clka_i                     => clk_i,
      bwea_i                     => "00000000",
      -- a is input
      wea_i                      => op_ram_we,
      aa_i                       => op_ram_wr_address,
      da_i                       => op_ram_input, 
      qa_o                       => open,
      clkb_i                     => clk_i,
      bweb_i                     => "00000000",
      web_i                      => '0',
      ab_i                       => op_2_ram_rd_address,
      db_i                       => x"0000000000000000",
      qb_o                       => op_2_ram_output);

  -- memory for payload
  -- A: written by Reed-Solomon
  -- B: read by Hamming         
  RS_PAYLOAD : generic_dpram
    generic map(
      g_data_width               => c_fec_ram_data_width, -- 64
      g_size                     => c_fec_ram_size)
    port map( 
      rst_n_i                    => rst_n_i,
      clka_i                     => clk_i,
      bwea_i                     => "00000000",
      -- a is input
      wea_i                      => rs_ram_we,
      aa_i                       => rs_ram_wr_address,
      da_i                       => rs_ram_input, 
      qa_o                       => open,
      clkb_i                     => clk_i,
      bweb_i                     => "00000000",
      web_i                      => '0',
      ab_i                       => rs_ram_rd_address,
      db_i                       => x"0000000000000000",
      qb_o                       => rs_ram_output);      
  --===============================================================================================
  -- FSM for reception of data-to-be-encoded
  --===============================================================================================
  -- here we receive data stream from I/F, supposedly without breaks, but it is foreseen.
  -- we first get the header, which is stored in a special buffer for further useage.
  -- then we store the payload(s) 
  --
  
  INMUX: for i in 0 to (c_fec_engine_Byte_sel_num  - 1) generate
    if_data_i((i+1)*8 - 1 downto i*8) <= if_data_in((i+1)*8 - 1 downto i*8) when (if_byte_sel_i(i)='1') else x"00";
  end generate;
  
  
  fsm_receive : process(clk_i, rst_n_i)
  
  --------------- variables--------------

  variable eth_header_size_cnt    : integer range 0 to c_fec_Ethernet_header_size_MAX_bits - 1;
  
  begin
    if rising_edge(clk_i) then
      if(rst_n_i = '0' or  if_in_ctrl_i = c_FECIN_ABANDON) then --TODO: this is temporary solution
      --========================================
      -- new staff
      input_payload_word_cnt <= (others => '0');
      input_payload_size_cnt <= (others => '0');
      odd_write              <= '0';
      write_input            <= '0';      
      help_input_buffer      <= (others => '0');
      in_second_msg          <= '0';      
      in_msg_received        <= '0';              -- used in other FSMS
      eth_header_size        <= (others =>'0');
      eth_header_size_cnt    :=0;
      -- RAMs
      header_ram_we          <= '0';  
      header_ram_wr_address  <= (others =>'0');  
      header_ram_input       <= (others =>'0');  
      op_ram_we              <= '0';  
      op_ram_wr_address      <= (others =>'0');  
      op_ram_input           <= (others =>'0');  
      input_buffer           <= (others =>'0');  
      -- outputs
      if_busy_o             <= '0';
      if_in_ctrl_o          <= '0';
      receive_state         <= S_IDLE;
      fec_header_etherType_valid <='0';
      --========================================
      else

        -- main finite state machine
        case receive_state is

          --=======================================================================================
          when S_IDLE =>
          --=======================================================================================   
    	      
    	       input_payload_word_cnt <= (others => '0');
            input_payload_size_cnt <= (others => '0');  
            odd_write              <= '0';
            write_input            <= '0';      
            help_input_buffer      <= (others => '0');
            in_second_msg          <= '0';      
            in_msg_received        <= '0';              -- used in other FSMS
            eth_header_size        <= (others =>'0');
            eth_header_size_cnt    :=0;
            -- RAMs
            header_ram_we          <= '0';  
            header_ram_wr_address  <= (others =>'0');  
            header_ram_input       <= (others =>'0');  
            op_ram_we              <= '0';  
            op_ram_wr_address      <= (others =>'0');  
            op_ram_input           <= (others =>'0');  
            input_buffer           <= (others =>'0');  
            -- outputs
            fec_header_etherType_valid <='0';
    	      
    	       -- 1 = header is being transfered
   	        if(if_in_ctrl_i = b"001") then
   	        
   	           input_payload_word_cnt <= (others =>'0');
   	           input_payload_size_cnt <= (others =>'0');
   	           input_payload_size_cnt(0)<='1';
       	       receive_state         <= S_HEADER;

       	       ------ write to memory ------
       	       header_ram_we         <= '1';  
       	       header_ram_input      <= if_data_i;
               -----------------------------
               
       	       if_busy_o             <= '1';
       	       if_in_ctrl_o          <= '0'; 
       	       eth_header_size       <= (others =>'0');
       	       eth_header_size_cnt   := c_fec_engine_data_width;
       	       op_ram_wr_address     <= (others =>'0');
       	       fec_header_etherType_valid <='0';
       	       
            end if;

  

          --=======================================================================================
          when S_HEADER =>
          --=======================================================================================  
            op_ram_we             <= '0'; -- original payload RAMs     
            
            if(eth_header_size_cnt > c_fec_settings_input_threshold*8 and FECsettingsReady = '0') then
            
              -- we need to know pck (control message to be encoded) size before
              -- storing the payload
              receive_state    <= S_PAUSE;
              if_in_ctrl_o     <= '1';
              ------ write to memory ------
              header_ram_we         <= '1';  
              header_ram_input      <= if_data_i;
             -----------------------------
              header_ram_wr_address  <= std_logic_vector(unsigned(header_ram_wr_address) + 1);
                           
              eth_header_size_cnt := c_fec_engine_data_width + eth_header_size_cnt; 
             
            -- input transfer finished, TODO(1): this is not good, we need t throw error here
            elsif( if_in_ctrl_i = b"100") then 
               
              receive_state <= S_WAIT_ENCODING;
                  
            -- 3 = transfer pause
            elsif( if_in_ctrl_i = b"011") then 
               
              receive_state <= S_PAUSE;

  	         -- 2 = payload to be encoded is being transfered    
   	        elsif(if_in_ctrl_i = b"010") then

  	           -----------------------------------------------------   	           
   	          --              header end                         -- 
  	           -----------------------------------------------------
   	          -- recognizing header size, thus whether it's VLAN
   	          -- tagged or untagged, thus we know were to put the
   	          -- FEC's ethertype 
   	          -- TODO(2): make sanity check with the input vlan_tagged_frame_i
   	          if(eth_header_size_cnt < 18 * 8) then
   	          
  	             -- remembering header size
   	            eth_header_size       <= x"00" & "01110000" ;--14 Bytes
   	            
   	            -- substituting original etherType with FEC's on
                --header_ram_wr_address <= x"6";
                --header_ram_we         <= '1';
                --header_ram_input      <= c_FEC_ETH_TYPE;
 	            else
 	              
                -- remembering header size
                eth_header_size <= x"00" & "10010000" ;--18 Bytes
                
                -- substituting original etherType with FEC's on
                --header_ram_wr_address <= x"8";
                --header_ram_we         <= '1';
                --header_ram_input      <= c_FEC_ETH_TYPE;
 	            end if;
              -----------------------------------------------------  
              header_ram_wr_address <= (others=>'0');
              header_ram_we         <= '0';              
              fec_header_etherType_valid <='1';
              -----------------------------------------------------   	           
              --              payload start                      -- 
              ----------------------------------------------------- 	          
       	      receive_state             <= S_PAYLOAD;
              input_buffer              <= (others =>'0');  
              -- read first data
              input_buffer(15 downto 0) <=if_data_i;
              input_payload_word_cnt    <= std_logic_vector(unsigned(input_payload_word_cnt) + 1 );
              input_payload_size_cnt    <= std_logic_vector(unsigned(input_payload_size_cnt) + 1 );
              
            elsif(unsigned(header_ram_wr_address) <  c_fec_Ethernet_header_ram_size) then
              
              ------ write to memory ------
              header_ram_we       <= '1';  
              header_ram_input    <= if_data_i;
              -----------------------------
              
              
              header_ram_wr_address  <= std_logic_vector(unsigned(header_ram_wr_address) + 1);
              
              -- TODO: some mean of indicating error if the header size is too big
              eth_header_size_cnt := c_fec_engine_data_width + eth_header_size_cnt; 
              
            else
              --TODO(3): error here             
              assert false
                 report "HEADER: want to write too big header to the header buffer";

            end if;
                    
          --=======================================================================================        
          when S_PAYLOAD =>
          --=======================================================================================
            fec_header_etherType_valid <='0';
            header_ram_we         <= '0';  
            header_ram_wr_address <= (others=>'0');
            eth_header_size_cnt   :=0;
            write_input           <= '0'; 
            header_ram_we         <= '0';
            op_ram_input          <= (others => '0');
            -- input transfer finished
            if( if_in_ctrl_i = b"100") then 
               
               
               -- if there is still data to be written in the help_input_buffer
               -- due to the fact that we have "odd_write" (meaning: have of the 
               -- 16 bits word is written to one address of memory and the other 
               -- half to the subsequent address, we need to write this data...
               if(odd_write = '1' and input_payload_word_cnt(1 downto 0) ="00") then
               
                 input_buffer              <= (others => '0');
                 input_buffer(7 downto 0)  <= help_input_buffer;
                 write_input               <= '1';
               
               -- if the number of the last received word was divisible by 4,.. the writing
               -- was already initiated, otherwise, we need to write the remining data
               elsif(write_input = '0') then
                 write_input <= '1';
               end if;
               receive_state <=  S_WAIT_ENCODING;

            -- 3 = transfer pause
            elsif( if_in_ctrl_i = b"011") then 
               
              receive_state <= S_PAUSE;
              
            -- we can store in RAM  
            elsif(if_in_ctrl_i = b"010") then
              

              -- writing last word (8 or 16 bits) of the first half of the payload 
              -- TODO(4) why in_second_msg ?
              if(in_second_msg = '0' and input_payload_size_cnt = break_msg_at_size) then
                
                -- odd size of the divided message
                if(divFECin_msg_size(0) = '1') then
                  case input_payload_word_cnt(1 downto 0) is
                    when "00" => input_buffer <= (others => '0');
                                 input_buffer(7 downto 0)  <=if_data_i(7 downto 0);
                    when "01" => input_buffer(23 downto 16)<=if_data_i(7 downto 0);
                    when "10" => input_buffer(39 downto 32)<=if_data_i(7 downto 0);
                    when "11" => input_buffer(55 downto 48)<=if_data_i(7 downto 0);    
                    when others => assert false report "ERROR: input case, default";         
                  end case; 
                    help_input_buffer <= if_data_i(15 downto 8); 
                    odd_write         <= '1';
                    in_second_msg     <= '1';
                    input_payload_word_cnt(1 downto 0)<= "00";
                    
                else  -- even size of the divided message
                  case input_payload_word_cnt(1 downto 0) is
                    when "00" => input_buffer <= (others => '0');
                                 input_buffer(15 downto 0)<=if_data_i;
                    when "01" => input_buffer(31 downto 16)<=if_data_i;
                    when "10" => input_buffer(47 downto 32)<=if_data_i;
                    when "11" => input_buffer(63 downto 48)<=if_data_i;      
                    when others => assert false report "ERROR: input case, default";                           
                  end case;
                  input_payload_word_cnt(1 downto 0)<= "00";
                end if;
                write_input <= '1';
                input_payload_size_cnt    <= std_logic_vector(unsigned(input_payload_size_cnt) + 1 );
              -- the size is odd in bytes, writing second half of the payload  
              elsif(odd_write = '1') then
                case input_payload_word_cnt(1 downto 0) is
                  when "00" => input_buffer <= (others => '0');
                               input_buffer(7 downto 0)  <= help_input_buffer;
                               input_buffer(23 downto 8) <=if_data_i;
                  when "01" => input_buffer(39 downto 24)<=if_data_i;
                  when "10" => input_buffer(55 downto 40)<=if_data_i;
                  when "11" => input_buffer(63 downto 56)<=if_data_i(7 downto 0); 
                               help_input_buffer <= if_data_i(15 downto 8); 
                               write_input <= '1';            
                  when others => assert false report "ERROR: input case, default";                               
                end case;                
                input_payload_word_cnt <= std_logic_vector(unsigned(input_payload_word_cnt) + 1 );
                input_payload_size_cnt    <= std_logic_vector(unsigned(input_payload_size_cnt) + 1 );
              --"normal case"  
              else
              
                case input_payload_word_cnt(1 downto 0) is
                  when "00" => input_buffer <= (others => '0');
                               input_buffer(15 downto 0) <=if_data_i;
                  when "01" => input_buffer(31 downto 16)<=if_data_i;
                  when "10" => input_buffer(47 downto 32)<=if_data_i;
                  when "11" => input_buffer(63 downto 48)<=if_data_i;
                               write_input <= '1';      
                  when others => assert false report "ERROR: input case, default";                     
                end case;  
                input_payload_word_cnt <= std_logic_vector(unsigned(input_payload_word_cnt) + 1 );
                input_payload_size_cnt    <= std_logic_vector(unsigned(input_payload_size_cnt) + 1 );
              end if;
              
            else

              assert false
                 report "Payload: want to write too big header to the header buffer";

            end if;
            
          --=======================================================================================  
          when S_PAUSE =>
          --=====================================================================================
            
            if(header_ram_we = '1') then
              header_ram_we <='0';
            end if;
            
            if(FECsettingsReady = '1') then 
              if_in_ctrl_o          <= '0';
            end if;
            
            -- input transfer finished
            if( if_in_ctrl_i = b"100") then 
               
               write_input <= '1';
               receive_state <=  S_WAIT_ENCODING;      
 
            -- 1 = header is being transfered
            elsif(FECsettingsReady = '1' and if_in_ctrl_i = b"001") then
             
              receive_state       <= S_HEADER;
              if_in_ctrl_o        <= '0';
              ------ write to memory ------
              header_ram_we       <= '1';  
              header_ram_input    <= if_data_i;
              -----------------------------
                
             -- 2 = payload to be encoded is being transfered    
             elsif(if_in_ctrl_i = b"010") then
             
               receive_state <= S_PAYLOAD;
               
               -- if we transfer entire header, then pauze and then payload
               if(input_payload_word_cnt = zeros(c_fec_msg_size_MAX_Bytes_width - 1 downto 0)) then
                 fec_header_etherType_valid <='1';
               else
                 fec_header_etherType_valid <='0';
               end if;
               
              -- writing last word (8 or 16 bits) of the first half of the payload 
              -- TODO(4) why in_second_msg ?
              if(in_second_msg = '0' and input_payload_size_cnt = break_msg_at_size) then
                
                -- odd size of the divided message
                if(divFECin_msg_size(0) = '1') then
                  case input_payload_word_cnt(1 downto 0) is
                    when "00" => input_buffer <= (others => '0');
                                 input_buffer(7 downto 0)  <=if_data_i(7 downto 0);
                    when "01" => input_buffer(23 downto 16)<=if_data_i(7 downto 0);
                    when "10" => input_buffer(39 downto 32)<=if_data_i(7 downto 0);
                    when "11" => input_buffer(55 downto 48)<=if_data_i(7 downto 0);    
                    when others => assert false report "ERROR: input case, default";         
                  end case; 
                    help_input_buffer <= if_data_i(15 downto 8); 
                    odd_write         <= '1';
                    in_second_msg     <= '1';
                    input_payload_word_cnt(1 downto 0)<= "00";
                    
                else  -- even size of the divided message
                  case input_payload_word_cnt(1 downto 0) is
                    when "00" => input_buffer <= (others => '0');
                                 input_buffer(15 downto 0)<=if_data_i;
                    when "01" => input_buffer(31 downto 16)<=if_data_i;
                    when "10" => input_buffer(47 downto 32)<=if_data_i;
                    when "11" => input_buffer(63 downto 48)<=if_data_i;      
                    when others => assert false report "ERROR: input case, default";                           
                  end case;
                  input_payload_word_cnt(1 downto 0)<= "00";
                end if;
                write_input <= '1';
                input_payload_size_cnt    <= std_logic_vector(unsigned(input_payload_size_cnt) + 1 );
              -- the size is odd in bytes, writing second half of the payload  
              elsif(odd_write = '1') then
                case input_payload_word_cnt(1 downto 0) is
                  when "00" => input_buffer <= (others => '0');
                               input_buffer(7 downto 0)  <= help_input_buffer;
                               input_buffer(23 downto 8) <=if_data_i;
                  when "01" => input_buffer(39 downto 24)<=if_data_i;
                  when "10" => input_buffer(55 downto 40)<=if_data_i;
                  when "11" => input_buffer(63 downto 56)<=if_data_i(7 downto 0); 
                               help_input_buffer <= if_data_i(15 downto 8); 
                               write_input <= '1';            
                  when others => assert false report "ERROR: input case, default";                               
                end case;                
                input_payload_word_cnt <= std_logic_vector(unsigned(input_payload_word_cnt) + 1 );
                input_payload_size_cnt    <= std_logic_vector(unsigned(input_payload_size_cnt) + 1 );
              --"normal case"  
              else
              
                case input_payload_word_cnt(1 downto 0) is
                  when "00" => input_buffer <= (others => '0');
                               input_buffer(15 downto 0) <=if_data_i;
                  when "01" => input_buffer(31 downto 16)<=if_data_i;
                  when "10" => input_buffer(47 downto 32)<=if_data_i;
                  when "11" => input_buffer(63 downto 48)<=if_data_i;
                               write_input <= '1';      
                  when others => assert false report "ERROR: input case, default";                     
                end case;  
                input_payload_word_cnt <= std_logic_vector(unsigned(input_payload_word_cnt) + 1 );
                input_payload_size_cnt    <= std_logic_vector(unsigned(input_payload_size_cnt) + 1 );
              end if;
               

            end if;


          --=======================================================================================
          when S_WAIT_ENCODING =>
          --=======================================================================================
            write_input <= '0';
            if(sending_state = S_ALL_SENT) then
            
              --receive_state    <= S_IDLE;
              --if_busy_o        <= '0';
              --in_msg_received  <= '0';
              
              
              input_payload_word_cnt <= (others => '0');
              input_payload_size_cnt <= (others => '0');
              odd_write              <= '0';
              write_input            <= '0';      
              help_input_buffer      <= (others => '0');
              in_second_msg          <= '0';      
              in_msg_received        <= '0';
              eth_header_size        <= (others =>'0');
              eth_header_size_cnt    :=0;
              -- RAMs
              header_ram_we          <= '0';  
              header_ram_wr_address  <= (others =>'0');  
              header_ram_input       <= (others =>'0');  
              op_ram_we              <= '0';  
              op_ram_wr_address      <= (others =>'0');  
              op_ram_input           <= (others =>'0');  
              input_buffer           <= (others =>'0');  
              -- outputs
              if_busy_o             <= '0';
              if_in_ctrl_o          <= '0';
              receive_state         <= S_IDLE;
              fec_header_etherType_valid <='0';
              
            end if;

          --=======================================================================================
          when others =>
          --=======================================================================================           
            -- go back to idle
            receive_state <= S_IDLE;
            

          --=======================================================================================   
        end case;
        if(write_input = '1') then 
          op_ram_input      <= input_buffer;
          op_ram_we         <= '1';
        end if;
        
        if(op_ram_we = '1') then
          op_ram_wr_address <= std_logic_vector(unsigned(op_ram_wr_address) + 1);
          if(write_input = '0') then
            op_ram_we         <= '0';
          end if;
        end if;

        
      end if;
    end if;
  end process;
  

  
  --===============================================================================================
  -- Settings saver
  --===============================================================================================
  -- saving input settings and calculating settings for R-S
  --
  --  
  
  saveSettings : process(clk_i, rst_n_i)
  
  ------------------------------------- variables -------------------------------------------------
  -- temp variables to make the code less messy
  variable tmp_FECin_msg_size    :  std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);
  variable tmp_divFECin_msg_size :  std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);
  variable tmp_break_msg_at_size :  std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);
  variable tmp_RSin_msg_size     :  std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);
  variable FEC_ID                :  std_logic_vector(c_fec_FEC_header_FEC_ID_bits   - 1 downto 0);
  variable FEC_ID_tmp            :  std_logic_vector(c_fec_FEC_header_FEC_ID_bits   - 1 downto 0);
  variable tmp_HAMed_msg_size    :  std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);
  variable tmp_end_of_outmsg     :  std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);
  variable fragmentID            :  std_logic_vector(c_fec_FEC_header_FRAME_ID_bits - 1 downto 0);
  --------------------------------------------------------------------------------------------------
  begin
    if rising_edge(clk_i) then
      if(rst_n_i = '0'or  if_in_ctrl_i = c_FECIN_ABANDON) then --TODO: this is temporary solution
      --========================================
      FECsettingsReady      <= '0';
      out_MSG_num           <= (others=>'0');
      out_orig_data_MSG_num <= (others=>'0');
      divFECin_msg_size     <= (others=>'0');
      RSin_msg_size         <= (others=>'0');
      tmp_FECin_msg_size    := (others=>'0');
      tmp_divFECin_msg_size := (others=>'0');
      tmp_break_msg_at_size := (others=>'0');
      tmp_RSin_msg_size     := (others=>'0');
      tmp_HAMed_msg_size    := (others=>'0');
      FEC_ID                := c_fec_FEC_ID_init;
      FEC_ID_tmp            := (others=>'0');
      tmp_end_of_outmsg     := (others=>'0');
      fec_header_buffer     <= (others=>'0');
      ram_addr_divMsg_size  <= (others=>'0');
      ram_addr_origMsg_size <= (others=>'0');
      break_msg_at_size     <= (others=>'0');
      end_of_outmsg         <= (others=>'0');
      fragmentID            := (others=>'0');
      --========================================
      else

        -- remembering settings
        if(if_in_settngs_ena_i = '1' and FECsettingsUsed = '0') then
         

          -------------------------------------------------------------------------------------
          ------------                        input message size                       --------    
          -------------------------------------------------------------------------------------

          if(if_msg_size_i(0) = '0') then
            tmp_FECin_msg_size := if_msg_size_i;
          else
            tmp_FECin_msg_size := std_logic_vector(unsigned(if_msg_size_i)+1);
          end if;
          
          -------------------------------------------------------------------------------------
          ------------ number of output messages and size of messages to be processed  --------    
          -------------------------------------------------------------------------------------
          
          --if(if_out_MSG_num_i = zeros(c_fec_out_MSG_num_MAX_width - 1 downto 0)) then
          if(true) then -- for the time being no choice
          
            if(unsigned(if_msg_size_i) < "0000000101100") then --46=101100
            
               assert false report "ERROR: message size- too small, TODO(7): implement here sth";
            
            elsif(unsigned(if_msg_size_i) < "0100111000100") then --2500=100111000100 [Bytes]
            
               -- 2 info and 2 parity
               out_MSG_num           <= "100"; -- 4
               out_orig_data_MSG_num <= "010"; -- 2 std_logic_vector(to_unsigned(4,c_fec_out_MSG_num_MAX_width) - K);
               -- divide by 2 
               -- TODO(8): divide by K ==>> shift by log2(K)
               tmp_divFECin_msg_size := '0' & tmp_FECin_msg_size(c_fec_msg_size_MAX_Bytes_width - 1 downto 1);
               
            elsif(unsigned(if_msg_size_i) < "0111110100000") then --4000=111110100000
               -- 4 info and 2 parity
               out_MSG_num           <= "110";  --6
               out_orig_data_MSG_num <= "100"; -- 4"std_logic_vector(to_unsigned(6,c_fec_out_MSG_num_MAX_width) - K);
              
               assert false report "ERROR: settings: need divide by 6 implementation";-- TODO(9)
               
            else  
               assert false report "ERROR: message size- too big, TODO: implement here sth";--TODO(7):
            end if;
          else
            
            -- TODO(10)
            out_MSG_num           <= if_out_MSG_num_i;
            out_orig_data_MSG_num <= std_logic_vector(unsigned(if_out_MSG_num_i) - K);
            
            assert false report "DANGER: using this is not tested and can effect in explosion :)";
            
          end if;
          
          ---------------------------------------------
          -- RSin_msg_size=8*CEIL(divFECin_msg_size/8)
          ---------------------------------------------          
          if(tmp_divFECin_msg_size(2 downto 0) = "000") then 
            tmp_RSin_msg_size := tmp_divFECin_msg_size;
          else
            tmp_RSin_msg_size := tmp_divFECin_msg_size(c_fec_msg_size_MAX_Bytes_width - 1 downto 3) & "000";
            tmp_RSin_msg_size := std_logic_vector(unsigned(tmp_RSin_msg_size) + 8);
          end if;

          ---------------------------------------------
          -- calculate the output payload size 
          -- (after RS->Hamming)
          -- HAMed_msg_size [Bytes] = 
          --     (RSin_msg_size/8) + RSin_msg_size
          ---------------------------------------------          

          tmp_HAMed_msg_size := "000" & tmp_RSin_msg_size(c_fec_msg_size_MAX_Bytes_width - 1 downto 3);          
          tmp_HAMed_msg_size := std_logic_vector(unsigned(tmp_HAMed_msg_size)+ unsigned(tmp_RSin_msg_size));          
          
          ----------------------------------------------
          -- break_msg_at_size =  CEIL(divFECin_msg_size/2)
          ----------------------------------------------   
          -- this is becasue we have 16 bits input, so 16/2... this is not really flexible and the name is bad
          -- this should be break message at input word number...TODO(11)
          tmp_break_msg_at_size  := '0' & tmp_divFECin_msg_size(c_fec_msg_size_MAX_Bytes_width - 1 downto 1);
          if(tmp_divFECin_msg_size(0) = '1') then 
            tmp_break_msg_at_size      := std_logic_vector(unsigned(tmp_break_msg_at_size) + 1);
          end if;   
          
          -- calculate the output size with hamming parity bits 
          tmp_end_of_outmsg    := "000" & tmp_RSin_msg_size(c_fec_msg_size_MAX_Bytes_width - 1 downto 3);
          tmp_end_of_outmsg    := std_logic_vector(unsigned(tmp_RSin_msg_size) + unsigned(tmp_end_of_outmsg));
                    
          if(tmp_end_of_outmsg(0) = '0') then
            tmp_end_of_outmsg    := '0' & tmp_end_of_outmsg(c_fec_msg_size_MAX_Bytes_width - 1 downto 1);
            tmp_end_of_outmsg    := std_logic_vector(unsigned(tmp_end_of_outmsg) - 1); 
          else
            tmp_end_of_outmsg    := '0' & tmp_end_of_outmsg(c_fec_msg_size_MAX_Bytes_width - 1 downto 1);
            tmp_end_of_outmsg    := std_logic_vector(unsigned(tmp_end_of_outmsg) - 1);
          end if;
            
          --tmp_end_of_outmsg    := '0' & tmp_RSin_msg_size(c_fec_msg_size_MAX_Bytes_width - 1 downto 1);
          --tmp_end_of_outmsg    := std_logic_vector(unsigned(tmp_end_of_outmsg) + 2); --??? TODO(12) verify
          ---------------------------------------------
          -- write outside-process-available regs
          ---------------------------------------------            
          --FECin_msg_size         <= tmp_FECin_msg_size;
          divFECin_msg_size      <= tmp_divFECin_msg_size;
          break_msg_at_size      <= tmp_break_msg_at_size;
          end_of_outmsg          <= tmp_end_of_outmsg;
          RSin_msg_size          <= tmp_RSin_msg_size;
          FECsettingsReady       <= '1';
          
          -- TODO: configurable
          ram_addr_divMsg_size   <=  (others =>'0');
          ram_addr_divMsg_size(c_fec_msg_size_MAX_Bytes_width - 4 downto 0)   <= tmp_RSin_msg_size(c_fec_msg_size_MAX_Bytes_width - 1 downto 3);
          
          ram_addr_origMsg_size  <= (others =>'0');
          ram_addr_origMsg_size(c_fec_msg_size_MAX_Bytes_width - 3 downto 0)  <= tmp_RSin_msg_size(c_fec_msg_size_MAX_Bytes_width - 1 downto 3) & '0';
          
          -------------------------------------------------------------------------------------
          ------------                        create FEC header                       --------    
          -------------------------------------------------------------------------------------
          if(if_FEC_ID_ena_i = '1') then
            FEC_ID_tmp := if_FEC_ID_i;
          else
            FEC_ID_tmp := FEC_ID;
	    FEC_ID     := std_logic_vector(unsigned(FEC_ID)+1);
          end if;
	  
	 

          -- schema ID  (4 bits)
          fec_header_buffer(c_fec_FEC_header_Scheme_bits   -1 downto 0) <= x"0";
          
          
          -- FEC ID  (32 bits)     
          fec_header_buffer(c_fec_FEC_header_Scheme_bits   +
                            c_fec_FEC_header_FRAME_ID_bits +
                            c_fec_FEC_header_FEC_ID_bits   -1 downto 
                            c_fec_FEC_header_Scheme_bits   +
                            c_fec_FEC_header_FRAME_ID_bits  )           <= FEC_ID_tmp ;--x"DEAD"; --FEC_ID;   

          if(fec_header_etherType_valid = '1') then
        
            fec_header_buffer(c_fec_FEC_header_Scheme_bits   +
                              c_fec_FEC_header_FRAME_ID_bits +
                              c_fec_FEC_header_FEC_ID_bits   +
                              c_fec_FEC_header_etherType_bits-1 downto 
                              c_fec_FEC_header_Scheme_bits   +
                              c_fec_FEC_header_FEC_ID_bits   +
                              c_fec_FEC_header_FRAME_ID_bits  )           <= if_in_etherType_i;
          else
                            
            fec_header_buffer(c_fec_FEC_header_Scheme_bits   +
                              c_fec_FEC_header_FRAME_ID_bits +
                              c_fec_FEC_header_FEC_ID_bits   +
                              c_fec_FEC_header_etherType_bits-1 downto 
                              c_fec_FEC_header_Scheme_bits   +
                              c_fec_FEC_header_FEC_ID_bits   +
                              c_fec_FEC_header_FRAME_ID_bits  )           <= x"0000"; -- to be filld in later
          end if;              
                                   
          -- Original message lenght (13 bits)      
          fec_header_buffer(c_fec_FEC_header_Scheme_bits   +
                            c_fec_FEC_header_FRAME_ID_bits +
                            c_fec_FEC_header_FEC_ID_bits   +
                            c_fec_FEC_header_etherType_bits+
                            c_fec_FEC_original_len_bits    -1 downto 
                            c_fec_FEC_header_Scheme_bits   +
                            c_fec_FEC_header_FRAME_ID_bits +
                            c_fec_FEC_header_FEC_ID_bits   +
                            c_fec_FEC_header_etherType_bits)           <= "00" & if_msg_size_i;   

          -- fragment lenght  (11 bits)     
          fec_header_buffer(c_fec_FEC_header_Scheme_bits   +
                            c_fec_FEC_header_FRAME_ID_bits +
                            c_fec_FEC_header_FEC_ID_bits   +
                            c_fec_FEC_header_etherType_bits+
                            c_fec_FEC_original_len_bits    +
                            c_fec_FEC_fragment_len_bits    -1 downto 
                            c_fec_FEC_header_Scheme_bits   +
                            c_fec_FEC_header_FRAME_ID_bits +
                            c_fec_FEC_header_FEC_ID_bits   +
                            c_fec_FEC_header_etherType_bits+
                            c_fec_FEC_original_len_bits    )           <= tmp_HAMed_msg_size(c_fec_FEC_fragment_len_bits - 1 downto 0);   
           
        elsif(fec_header_etherType_valid = '1') then
        
          -- the input frame's etherType is known later then the rest of the settings (at the end of the header transfer),
          -- so add it to the already created FEC header
          fec_header_buffer(c_fec_FEC_header_Scheme_bits   +
                            c_fec_FEC_header_FRAME_ID_bits +
                            c_fec_FEC_header_FEC_ID_bits   +
                            c_fec_FEC_header_etherType_bits-1 downto 
                            c_fec_FEC_header_Scheme_bits   +
                            c_fec_FEC_header_FEC_ID_bits   +
                            c_fec_FEC_header_FRAME_ID_bits  )           <= if_in_etherType_i;
                            
        elsif(if_in_settngs_ena_i = '0'  and FECsettingsUsed = '1') then
        
          FECsettingsReady <= '0';

        end if;--if(if_in_settngs_ena_i = '1') then

        if(if_in_settngs_ena_i = '1' and FECsettingsUsed = '0' and inc_fragmentID = '0') then

          fragmentID := (others =>'0');
          -- FRAGMENT ID (4 bits)
          fec_header_buffer(c_fec_FEC_header_Scheme_bits   +
                            c_fec_FEC_header_FRAME_ID_bits -1 downto 
                            c_fec_FEC_header_Scheme_bits)               <= fragmentID ;--<= (others=>'0');
      
        elsif(inc_fragmentID = '1' ) then

          fragmentID := std_logic_vector(unsigned(fragmentID)+1);
          -- FRAGMENT ID (4 bits)
          fec_header_buffer(c_fec_FEC_header_Scheme_bits   +
                            c_fec_FEC_header_FRAME_ID_bits -1 downto 
                            c_fec_FEC_header_Scheme_bits)              <= fragmentID ;--<= (others=>'0');
        end if;--if(if_in_settngs_ena_i = '1' and FECsettingsUsed = '0') then

      end if;--if(rst_n_i = '0') then
    end if;--if rising_edge(clk_i) then
  end process;

  --===============================================================================================
  -- FSM to control Reed-Solomon 
  -- Parameters of the RS (for the time being not really configurable)
  --  * M = 8,
  --  * K = 2 
  --===============================================================================================
  fsm_rs : process(clk_i, rst_n_i)
  
  ------------------------------------- variables ----------------------------------------
  -- number of symbols [(M*8)bits] already processed
  variable symbols_loaded        : integer range 0 to c_fec_out_MSG_num_MAX - 1;
  ----------------------------------------------------------------------------------------
  
  begin
    if rising_edge(clk_i) then
      if(rst_n_i = '0' or  if_in_ctrl_i = c_FECIN_ABANDON) then --TODO: this is temporary solution
      --========================================
      for i in 0 to (K-1) loop 
        rs_indices(i)        <= (others=>'0');
      end loop;        
      
      for i in 0 to (M-1) loop 
        rs_stream_in(i) <= (others=>'0');
      end loop;          
      -- RS encoder control
      rs_load_indices           <= '0';
      rs_enable_in              <= '0';      
      finished_encoding         <='0';
      FECsettingsUsed           <= '0';
      rs_enable_in              <= '0';
      result_symbol             <= '0';
      symbols_loaded            := 0;
      op_2_ram_rd_address       <= (others => '0');
      rs_ram_wr_address         <= (others => '0');
      rs_ram_input              <= (others => '0');
      rs_ram_we                 <= '0';
      p_addr_rd_first_divMsg    <= (others => '0');
      p_addr_rd_next_divmsg     <= (others => '0');
      rs_finished               <= '0';
      p_rs_ram_wr_first_msg_add <= (others =>'0');
      p_rs_ram_wr_next_msg_add  <= (others =>'0');
      rs_state                  <= S_IDLE;
      --========================================
      else

        -- main finite state machine
        case rs_state is

          --=======================================================================================
          when S_IDLE => -- doing nothing
          --=======================================================================================   
            if(FECsettingsReady='1') then
            
              rs_state          <= S_SET;
              
              for i in 0 to (K-1) loop 
                rs_indices(i)   <= std_logic_vector(to_unsigned(i,8));
              end loop;  
              
              for i in 0 to (M-1) loop 
                rs_stream_in(i) <= (others=>'0');
              end loop; 
              

              rs_enable_in              <= '0';      
              finished_encoding         <='0';
              FECsettingsUsed           <= '0';
              rs_enable_in              <= '0';
              result_symbol             <= '0';
              symbols_loaded            := 0;
              op_2_ram_rd_address       <= (others => '0');
              rs_ram_wr_address         <= (others => '0');
              rs_ram_input              <= (others => '0');
              rs_ram_we                 <= '0';
              p_addr_rd_first_divMsg    <= (others => '0');
              p_addr_rd_next_divmsg     <= (others => '0');
              rs_finished               <= '0';
              
              p_rs_ram_wr_first_msg_add <= (others =>'0');
              p_rs_ram_wr_next_msg_add  <= (others =>'0');
              rs_load_indices           <= '1';
            end if;

          --=======================================================================================
          when S_SET =>   -- setting encoder
          --=======================================================================================  
            
             
             if(rs_load_indices = '1') then 
               rs_load_indices           <= '0';
             elsif(rs_setting_finished = '1') then
               rs_state                  <= S_WAIT_ENOUGH_DATA;
               FECsettingsUsed           <= '1';
               op_2_ram_rd_address       <= (others =>'0');
               p_addr_rd_first_divMsg    <= (others =>'0');
               p_addr_rd_next_divMsg     <= ram_addr_divMsg_size; ---!!!!!!!!
               
               p_rs_ram_wr_first_msg_add <= (others =>'0');
               p_rs_ram_wr_next_msg_add  <= ram_addr_divMsg_size;
             end if;
             
                    
          --=======================================================================================        
          when S_WAIT_ENOUGH_DATA =>  -- we wait until enough data is received for the
          --=======================================================================================
             rs_enable_in    <= '0';

             FECsettingsUsed   <= '0';
             
             -- wait for the first half of the message to be written and enough of the second half to start
             -- processing (we are taking data from both halfs the same address)
             if(unsigned(op_ram_wr_address) > unsigned(ram_addr_divMsg_size) + unsigned(op_2_ram_rd_address) ) then
               
               rs_state        <= S_LOAD_EMPTY_DATA;
               symbols_loaded  :=  1;
               rs_enable_in    <= '1';
               
               for i in 0 to (M-1) loop
                 rs_stream_in(i) <= "00000000";
               end loop;
               
             end if;
          
          --=======================================================================================        
          when S_LOAD_EMPTY_DATA =>  -- empty words, we will get RS codes for this
          --=======================================================================================
            rs_enable_in      <= '1';
            
            for i in 0 to (M-1) loop
              rs_stream_in(i) <= "00000000";
            end loop;
            
            
            if(symbols_loaded = K-1) then -- change address because the data is changed cycle later
            
              op_2_ram_rd_address    <= p_addr_rd_next_divMsg;
              p_addr_rd_first_divMsg <= std_logic_vector(unsigned(p_addr_rd_first_divMsg)+1);
              symbols_loaded         := symbols_loaded + 1;
            ----------------------------------------------------------------------
            elsif(symbols_loaded = K) then -- load data for next state
            ----------------------------------------------------------------------
              rs_state       <= S_LOAD_DATA;
              symbols_loaded :=  1;
              
              for i in 0 to (M-1) loop
                  rs_stream_in(i) <= op_2_ram_output(8*(i+1)-1 downto 8*i);
              end loop;
              
              -- read from first divMsg
              --op_2_ram_rd_address    <= p_addr_rd_next_divMsg;
              --p_addr_rd_first_divMsg <= std_logic_vector(unsigned(p_addr_rd_first_divMsg)+1);
            ----------------------------------------------------------------------                         
            else -- load empty data, increment
            ----------------------------------------------------------------------
              symbols_loaded := symbols_loaded + 1;
            ----------------------------------------------------------------------  
            end if;
            ----------------------------------------------------------------------            
          --=======================================================================================        
          when S_LOAD_DATA =>  -- loading data to be encoded
          --=======================================================================================

            if(symbols_loaded  = 2) then

              rs_state            <= S_RSENCODE;              
              rs_enable_in        <= '0';             
              
              --rs_ram_wr_ena       <= '1';
              result_symbol       <= '0';
              
              op_2_ram_rd_address   <= p_addr_rd_first_divMsg;
              p_addr_rd_next_divMsg <= std_logic_vector(unsigned(p_addr_rd_first_divMsg)+unsigned(ram_addr_divMsg_size));
              
              if(p_addr_rd_first_divMsg = ram_addr_divMsg_size) then
                --finished_encoding  := true;
                finished_encoding <= '1';
              else
                --finished_encoding  := false;                
                finished_encoding <='0';
              end if;

            else

              for i in 0 to (M-1) loop
                  rs_stream_in(i) <= op_2_ram_output(8*(i+1)-1 downto 8*i);
              end loop;
              
              --op_2_ram_rd_address <= std_logic_vector(unsigned(op_2_ram_rd_address)+unsigned(ram_addr_divMsg_size));
              
              symbols_loaded        := symbols_loaded + 1;
              
            end if;

          --=======================================================================================  
          when S_RSENCODE => -- encoding with R-S (give it few cycles)
          --=====================================================================================
              
            if(rs_encoding_done = '1') then  
              
              for j in 0 to (M-1) loop
                rs_ram_input(8*(j+1) - 1 downto 8*j) <= rs_out_result(0)(j) ;
              end loop;
              rs_ram_we <='1';
              
              if(finished_encoding = '1') then
                rs_state          <= S_RSENCODING_FINISHED;
              else
                
                if(unsigned(op_ram_wr_address) > unsigned(ram_addr_divMsg_size) + unsigned(op_2_ram_rd_address) ) then
                  
                  rs_state        <= S_LOAD_EMPTY_DATA;
                  symbols_loaded  :=  1;
                  rs_enable_in    <= '1';
                  
                  for i in 0 to (M-1) loop
                    rs_stream_in(i) <= "00000000";
                  end loop;
                   
                 
                elsif (in_msg_received = '1' ) then
               
                  rs_state        <= S_LOAD_EMPTY_DATA;
                  symbols_loaded  := 1;
                  rs_enable_in    <= '1';
                  
                  for i in 0 to (M-1) loop
                    rs_stream_in(i) <= "00000000";
                  end loop;           
                else
                  rs_state          <= S_WAIT_ENOUGH_DATA;
                end if;
              end if;
              
              --symbols_loaded := 0;--fixed bug
              result_symbol  <= '1';

            end if;
            
          --=======================================================================================
          when S_RSENCODING_FINISHED => -- encoding finished, we write resulting symbols to the buffer
          --=======================================================================================
            rs_state            <= S_IDLE;
            rs_enable_in        <= '0';
            rs_finished         <= '1';
            op_2_ram_rd_address <= (others => '0');
            
          --=======================================================================================
          when others =>
          --=======================================================================================           
            for i in 0 to (K-1) loop 
              rs_indices(i)        <= (others=>'0');

            end loop;        
          
            for i in 0 to (M-1) loop 
              rs_stream_in(i) <= (others=>'0');
            end loop;          
          
            rs_load_indices   <= '0';
            rs_enable_in      <= '0';
            symbols_loaded    := 0;
            finished_encoding <= '0';
            FECsettingsUsed   <= '0';
            rs_enable_in      <= '0';
            rs_state          <= S_IDLE;
          --=======================================================================================   
        end case;

        if (result_symbol = '1') then 
          for j in 0 to (M-1) loop
            rs_ram_input(8*(j+1) - 1 downto 8*j) <= rs_out_result(1)(j) ;
          end loop;
          rs_ram_we     <='1';
          result_symbol <= '0';
          
          rs_ram_wr_address          <= p_rs_ram_wr_next_msg_add;
          p_rs_ram_wr_first_msg_add  <= std_logic_vector(unsigned(p_rs_ram_wr_first_msg_add) + 1);

          
          --rs_ram_wr_address  <= std_logic_vector(unsigned(rs_ram_wr_address) + 1);
          
        end if;
          
        if(rs_ram_we = '1' and result_symbol = '0') then
          rs_ram_we <='0';
          
          rs_ram_wr_address        <= p_rs_ram_wr_first_msg_add;
          
          --p_rs_ram_wr_next_msg_add <= std_logic_vector(unsigned(p_addr_rd_first_divMsg)+ unsigned(ram_addr_divMsg_size));          
          p_rs_ram_wr_next_msg_add <= std_logic_vector(unsigned(p_rs_ram_wr_first_msg_add)+ unsigned(ram_addr_divMsg_size));          
          
          --rs_ram_wr_address  <= std_logic_vector(unsigned(rs_ram_wr_address) + 1);
        end if;

      end if;
    end if;
  end process;
  
  

  
  
  --===============================================================================================
  --FSM to control Hamming
  ------------------------------------------------------------------------------------------------
  -- hamming RAM words (64 bits) one after another, and putting them to a round buffer of the
  -- round buffer (2 RAM words + 2 hamming words, 2x64 + 2*8 = 144 bits), data from the round
  -- buffer is sent by the sending FSM
  --===============================================================================================
  fsm_hamming : process(clk_i, rst_n_i)

  
  ----------------------------------------------------------------------------------------
  
  begin
    if rising_edge(clk_i) then
      if(rst_n_i = '0' or  if_in_ctrl_i = c_FECIN_ABANDON) then --TODO(12): this is temporary solution
      --========================================
      out_buffer                      <=(others =>'0');
      HAM_parity_bits_ready_B1        <='0';
      HAM_parity_bits_ready_B2        <='0';
      hamming_in_data                 <=(others =>'0');
      rs_ram_rd_address               <= (others =>'0');
      op_1_ram_rd_address             <= (others =>'0');
      mem_all_HAM_parity_bits_sent_b1 <='0';
      mem_all_HAM_parity_bits_sent_b2 <='0';
      hamming_state                   <= S_IDLE;
      
      --========================================
      else

        if(all_HAM_parity_bits_sent_b1 = '1') then
          mem_all_HAM_parity_bits_sent_b1 <='1';
        end if;

        if(all_HAM_parity_bits_sent_b2 = '1') then
          mem_all_HAM_parity_bits_sent_b2 <='1';
        end if;

        -- main finite state machine
        case hamming_state is

          --=======================================================================================
          when S_IDLE => -- doing nothing
          --=======================================================================================   
            -- "010" => Payload
            if(if_in_ctrl_i = b"010" and FECsettingsReady = '1') then
              hamming_state           <= S_WAIT_ENOUGH_DATA_B1;
            end if;

            out_buffer                      <=(others =>'0');
            hamming_in_data                 <=(others =>'0');
            rs_ram_rd_address               <= (others =>'0');
    
            HAM_parity_bits_ready_B1        <= '0';
            HAM_parity_bits_ready_B2        <= '0';
            op_1_ram_rd_address             <= (others =>'0');
            mem_all_HAM_parity_bits_sent_b1 <= '1';
            mem_all_HAM_parity_bits_sent_b2 <= '1';
          --=======================================================================================
          when S_WAIT_ENOUGH_DATA_B1 =>   
          --=======================================================================================  
            
            if(all_HAM_parity_bits_sent_b1 = '1' or mem_all_HAM_parity_bits_sent_b1 = '1') then
            
              if((unsigned(op_ram_wr_address) > unsigned(op_1_ram_rd_address)) or in_msg_received = '1') then 
            
                mem_all_HAM_parity_bits_sent_b1 <= '0';    
                        
                hamming_state                   <= S_HAMMING_ORIGINAL_MSG_B1;
                hamming_in_data                 <= op_1_ram_output;
              
                -------------------------------------------------------
                -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                -- this is how it should be....
                -- but software implementation is different...
                -- and maybe it's a better way
                --out_buffer(3)                   <= op_1_ram_output(0);
                --out_buffer(7  downto 5)         <= op_1_ram_output(3 downto 1);
                --out_buffer(15 downto 9)         <= op_1_ram_output(10 downto 4);
                --out_buffer(31 downto 17)        <= op_1_ram_output(25 downto 11);
                --out_buffer(63 downto 33)        <= op_1_ram_output(56 downto 26);
                --out_buffer(71 downto 65)        <= op_1_ram_output(63 downto 57);

                out_buffer(63 downto 0)         <= op_1_ram_output;
                -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                -------------------------------------------------------


               
                op_1_ram_rd_address             <= std_logic_vector(unsigned(op_1_ram_rd_address) + 1);
                
              end if;
            end if;
          --=======================================================================================
          when S_WAIT_ENOUGH_DATA_B2 =>   
          --=======================================================================================  
            if(all_HAM_parity_bits_sent_b2 = '1' or mem_all_HAM_parity_bits_sent_b2 = '1') then
              if(unsigned(op_ram_wr_address) > unsigned(op_1_ram_rd_address) or in_msg_received = '1') then
                            
                mem_all_HAM_parity_bits_sent_b2 <= '0';   
            
                hamming_state                   <= S_HAMMING_ORIGINAL_MSG_B2;
                hamming_in_data                 <= op_1_ram_output;
  
                -------------------------------------------------------
                -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                -- this is how it should be....
                -- but software implementation is different...
                -- and maybe it's a better way
                --out_buffer(75)                  <= op_1_ram_output(0);
                --out_buffer(79  downto 77)       <= op_1_ram_output(3 downto 1);
                --out_buffer(87  downto 81)       <= op_1_ram_output(10 downto 4);
                --out_buffer(103 downto 89)       <= op_1_ram_output(25 downto 11);
                --out_buffer(135 downto 105)      <= op_1_ram_output(56 downto 26);
                --out_buffer(143 downto 137)      <= op_1_ram_output(63 downto 57);
                 
                out_buffer(135 downto 72)       <= op_1_ram_output; 
                             
                -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                            
                -------------------------------------------------------
              
              
                op_1_ram_rd_address             <= std_logic_vector(unsigned(op_1_ram_rd_address) + 1);
            
              end if;
            end if;            
          --=======================================================================================
          when S_WAIT_ENOUGH_RS_PARITY_B1 =>   
          --======================================================================================= 
            if(all_HAM_parity_bits_sent_b1 = '1' or mem_all_HAM_parity_bits_sent_b1 = '1') then
            
              --if((unsigned(rs_ram_wr_address) > unsigned(rs_ram_rd_address)) or rs_finished = '1') then 
              if((unsigned(p_rs_ram_wr_first_msg_add) > unsigned(rs_ram_rd_address)) or rs_finished = '1') then 

                mem_all_HAM_parity_bits_sent_b1 <= '0';   
             
                hamming_state                   <= S_HAMMING_RS_PARITY_MSG_B1;
                hamming_in_data                 <= rs_ram_output;

                -------------------------------------------------------
                -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                -- this is how it should be....
                -- but software implementation is different...
                -- and maybe it's a better way
                --out_buffer(3)                   <= rs_ram_output(0);
                --out_buffer(7 downto  5)         <= rs_ram_output(3 downto 1);
                --out_buffer(15 downto 9)         <= rs_ram_output(10 downto 4);
                --out_buffer(31 downto 17)        <= rs_ram_output(25 downto 11);
                --out_buffer(63 downto 33)        <= rs_ram_output(56 downto 26);
                --out_buffer(71 downto 65)        <= rs_ram_output(63 downto 57);
              
                out_buffer(63 downto 0)        <= rs_ram_output;
              
                -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                            
                -------------------------------------------------------              
              
                rs_ram_rd_address               <= std_logic_vector(unsigned(rs_ram_rd_address) + 1);
                
              end if;
            end if;                    
          --=======================================================================================
          when S_WAIT_ENOUGH_RS_PARITY_B2 =>   
          --======================================================================================= 
            if(all_HAM_parity_bits_sent_b2 = '1' or mem_all_HAM_parity_bits_sent_b2 = '1') then
              --if((unsigned(rs_ram_wr_address) > unsigned(rs_ram_rd_address))  or rs_finished = '1') then 
              if((unsigned(p_rs_ram_wr_first_msg_add) > unsigned(rs_ram_rd_address)) or rs_finished = '1') then 
              
                mem_all_HAM_parity_bits_sent_b2 <= '0';   
                
                hamming_state                   <= S_HAMMING_RS_PARITY_MSG_B2;
                hamming_in_data                 <= rs_ram_output;
               
                -------------------------------------------------------
                -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                -- this is how it should be....
                -- but software implementation is different...
                -- and maybe it's a better way               
                --out_buffer(75)                  <= rs_ram_output(0);
                --out_buffer(79  downto 77)       <= rs_ram_output(3 downto 1);
                --out_buffer(87  downto 81)       <= rs_ram_output(10 downto 4);
                --out_buffer(103 downto 89)       <= rs_ram_output(25 downto 11);
                --out_buffer(135 downto 105)      <= rs_ram_output(56 downto 26);
                --out_buffer(143 downto 137)      <= rs_ram_output(63 downto 57);

                out_buffer(135 downto 72)      <= rs_ram_output;
                         
                -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                            
                -------------------------------------------------------
                                               
                rs_ram_rd_address               <= std_logic_vector(unsigned(rs_ram_rd_address) + 1);
                
              end if;
            end if;  
          --=======================================================================================        
          when S_HAMMING_ORIGINAL_MSG_B1 =>  
          --=======================================================================================
            
              --hamming_parity_B1 <= hamming_parity_tmp;
              
              
              -------------------------------------------------------
              -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
              -- this is how it should be....
              -- but software implementation is different...
              -- and maybe it's a better way                
              --out_buffer(0)  <=  hamming_parity_tmp(0); 
              --out_buffer(1)  <=  hamming_parity_tmp(1);
              --out_buffer(2)  <=  hamming_parity_tmp(2);                                      
              --out_buffer(4)  <=  hamming_parity_tmp(3);
              --out_buffer(8)  <=  hamming_parity_tmp(4);
              --out_buffer(16) <=  hamming_parity_tmp(5);
              --out_buffer(32) <=  hamming_parity_tmp(6);
              --out_buffer(64) <=  hamming_parity_tmp(7); 
              
              out_buffer(71 downto 64) <=  hamming_parity_tmp; 
                            
              -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                            
              -------------------------------------------------------              
              
              HAM_parity_bits_ready_B1 <= '1';
              -- left 10 bits          <-> right 11 bits
              -- op_1_ram_rd_address  <-> RSin_msg_size
              --if(op_1_ram_rd_address(c_fec_ram_addr_width-3 downto 0) = RSin_msg_size(c_fec_msg_size_MAX_Bytes_width  - 1 downto 3)) then 
              if(op_1_ram_rd_address = ram_addr_divMsg_size) then 
                 
                 -- finsihed sending first message
                 hamming_state       <= S_WAIT_ENOUGH_DATA_B1;
              
              elsif(op_1_ram_rd_address = ram_addr_origMsg_size  ) then 
                  
                  hamming_state     <= S_WAIT_ENOUGH_RS_PARITY_B1;
                
              elsif(unsigned(op_ram_wr_address) > unsigned(op_1_ram_rd_address) ) then 
            
                if((all_HAM_parity_bits_sent_b2 = '1' or mem_all_HAM_parity_bits_sent_b2 = '1')) then
                
                  mem_all_HAM_parity_bits_sent_b2 <= '0';   
                  
                  hamming_state                   <= S_HAMMING_ORIGINAL_MSG_B2;
                  hamming_in_data                 <= op_1_ram_output;
                  
                  -------------------------------------------------------
                  -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                  -- this is how it should be....
                  -- but software implementation is different...
                  -- and maybe it's a better way 
                  --out_buffer(75)                  <= op_1_ram_output(0);
                  --out_buffer(79  downto 77)       <= op_1_ram_output(3 downto 1);
                  --out_buffer(87  downto 81)       <= op_1_ram_output(10 downto 4);
                  --out_buffer(103 downto 89)       <= op_1_ram_output(25 downto 11);
                  --out_buffer(135 downto 105)      <= op_1_ram_output(56 downto 26);
                  --out_buffer(143 downto 137)      <= op_1_ram_output(63 downto 57);
                  
                  out_buffer(135 downto 72)      <= op_1_ram_output;
                  
                  -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                            
                  -------------------------------------------------------                    
                  
                  op_1_ram_rd_address             <= std_logic_vector(unsigned(op_1_ram_rd_address) + 1);
                else
                  hamming_state       <= S_WAIT_ENOUGH_DATA_B2;                   
                end if;
                
              else
              
                hamming_state       <= S_WAIT_ENOUGH_DATA_B2;
               
              end if;
              
            --end if;
            --=======================================================================================        
            when S_HAMMING_ORIGINAL_MSG_B2 =>  
            --=======================================================================================
              
              
                -------------------------------------------------------
                -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                -- this is how it should be....
                -- but software implementation is different...
                -- and maybe it's a better way 
                --out_buffer(72)  <=  hamming_parity_tmp(0); 
                --out_buffer(73)  <=  hamming_parity_tmp(1);
                --out_buffer(74)  <=  hamming_parity_tmp(2);                                      
                --out_buffer(76)  <=  hamming_parity_tmp(3);
                --out_buffer(80)  <=  hamming_parity_tmp(4);
                --out_buffer(88)  <=  hamming_parity_tmp(5);
                --out_buffer(104) <=  hamming_parity_tmp(6);
                --out_buffer(136) <=  hamming_parity_tmp(7); 
                
                out_buffer(143 downto 136) <=  hamming_parity_tmp; 
                
                -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                            
                -------------------------------------------------------
                
                HAM_parity_bits_ready_B2 <= '1';
                
                --if(op_1_ram_rd_address(c_fec_ram_addr_width-3 downto 0) = RSin_msg_size(c_fec_msg_size_MAX_Bytes_width  - 1 downto 3)) then 
                if(op_1_ram_rd_address = ram_addr_divMsg_size) then 
                     
                   if(mem_all_HAM_parity_bits_sent_b1 = '1' or all_HAM_parity_bits_sent_b1 = '1') then   
                   
                     mem_all_HAM_parity_bits_sent_b1 <='0';
                                   
                     hamming_state                   <= S_HAMMING_ORIGINAL_MSG_B1;
                     hamming_in_data                 <= op_1_ram_output;
                     
                     -------------------------------------------------------
                     -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                     -- this is how it should be....
                     -- but software implementation is different...
                     -- and maybe it's a better way 
                     --out_buffer(3)                   <= op_1_ram_output(0);
                     --out_buffer(7  downto 5)         <= op_1_ram_output(3 downto 1);
                     --out_buffer(15 downto 9)         <= op_1_ram_output(10 downto 4);
                     --out_buffer(31 downto 17)        <= op_1_ram_output(25 downto 11);
                     --out_buffer(63 downto 33)        <= op_1_ram_output(56 downto 26);
                     --out_buffer(71 downto 65)        <= op_1_ram_output(63 downto 57);
                     
                     out_buffer(63 downto 0)        <= op_1_ram_output;
                     
                     -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                            
                     -------------------------------------------------------
                     
                     op_1_ram_rd_address             <= std_logic_vector(unsigned(op_1_ram_rd_address) + 1);
                   else
                     hamming_state       <= S_WAIT_ENOUGH_DATA_B1;       
                   end if;
                
                elsif(unsigned(op_1_ram_rd_address) = unsigned(ram_addr_origMsg_size)) then 
  
                    hamming_state     <= S_WAIT_ENOUGH_RS_PARITY_B1;
                    
                elsif(unsigned(op_ram_wr_address) > unsigned(op_1_ram_rd_address) ) then 
              
                  if(mem_all_HAM_parity_bits_sent_b1 = '1'  or all_HAM_parity_bits_sent_b1 = '1') then   
                  
                    mem_all_HAM_parity_bits_sent_b1 <='0';
                                  
                    hamming_state                   <= S_HAMMING_ORIGINAL_MSG_B1;
                    hamming_in_data                 <= op_1_ram_output;
                    
                    -------------------------------------------------------
                    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                    -- this is how it should be....
                    -- but software implementation is different...
                    -- and maybe it's a better way 
                    --out_buffer(3)                   <= op_1_ram_output(0);
                    --out_buffer(7  downto 5)         <= op_1_ram_output(3 downto 1);
                    --out_buffer(15 downto 9)         <= op_1_ram_output(10 downto 4);
                    --out_buffer(31 downto 17)        <= op_1_ram_output(25 downto 11);
                    --out_buffer(63 downto 33)        <= op_1_ram_output(56 downto 26);
                    --out_buffer(71 downto 65)        <= op_1_ram_output(63 downto 57);
                    
                    out_buffer(63 downto 0)        <= op_1_ram_output;
                    
                    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                            
                    -------------------------------------------------------                    
                    
                    op_1_ram_rd_address             <= std_logic_vector(unsigned(op_1_ram_rd_address) + 1);
                    
                  else
                    
                    hamming_state       <= S_WAIT_ENOUGH_DATA_B1;       
                    
                  end if;
                             
                else
                
                  hamming_state       <= S_WAIT_ENOUGH_DATA_B1;
                 
                end if;
                
          --=======================================================================================        
          when S_HAMMING_RS_PARITY_MSG_B1 =>  
          --=======================================================================================
            
              HAM_parity_bits_ready_B1 <= '1';
              
              -------------------------------------------------------
              -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
              -- this is how it should be....
              -- but software implementation is different...
              -- and maybe it's a better way
              -- out_buffer(0)  <=  hamming_parity_tmp(0); 
              -- out_buffer(1)  <=  hamming_parity_tmp(1);
              -- out_buffer(2)  <=  hamming_parity_tmp(2);                                      
              -- out_buffer(4)  <=  hamming_parity_tmp(3);
              -- out_buffer(8)  <=  hamming_parity_tmp(4);
              -- out_buffer(16) <=  hamming_parity_tmp(5);
              -- out_buffer(32) <=  hamming_parity_tmp(6);
              -- out_buffer(64) <=  hamming_parity_tmp(7); 
              
              out_buffer(71 downto 64) <= hamming_parity_tmp;
              
              -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
              -------------------------------------------------------
              
              --if(rs_ram_rd_address(c_fec_ram_addr_width-3 downto 0) = RSin_msg_size(c_fec_msg_size_MAX_Bytes_width  - 1 downto 3)) then  
              --if(rs_ram_rd_address(c_fec_ram_addr_width-1 downto 0) = RSin_msg_size(c_fec_ram_addr_width- 1 downto 3)) then 
              if(rs_ram_rd_address = ram_addr_divMsg_size) then 
                 
                 -- finsihed sending first message
                 hamming_state       <= S_WAIT_ENOUGH_RS_PARITY_B1;
              
              elsif(unsigned(rs_ram_rd_address) = unsigned(ram_addr_origMsg_size)  ) then 
                
                -- we are done, HURRAY :) !!!!!!!!!!!!!!!!!!!
                hamming_state       <= S_ALL_HAMMED;

              elsif(unsigned(rs_ram_wr_address) > unsigned(rs_ram_rd_address)) then 
               
               if(mem_all_HAM_parity_bits_sent_b2 = '1'  or all_HAM_parity_bits_sent_b2 = '1') then  
                 
                 mem_all_HAM_parity_bits_sent_b2 <='0';
               
                 hamming_state                   <= S_HAMMING_RS_PARITY_MSG_B2;
                 hamming_in_data                 <= rs_ram_output;
                               
                 -------------------------------------------------------
                 -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                 -- this is how it should be....
                 -- but software implementation is different...
                 -- and maybe it's a better way                                
                 --out_buffer(75)                  <= rs_ram_output(0);
                 --out_buffer(79  downto 77)       <= rs_ram_output(3 downto 1);
                 --out_buffer(87  downto 81)       <= rs_ram_output(10 downto 4);
                 --out_buffer(103 downto 89)       <= rs_ram_output(25 downto 11);
                 --out_buffer(135 downto 105)      <= rs_ram_output(56 downto 26);
                 --out_buffer(143 downto 137)      <= rs_ram_output(63 downto 57);
                 
                 out_buffer(135 downto 72)       <= rs_ram_output;
                 
                 -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                 -------------------------------------------------------
               
                 rs_ram_rd_address <= std_logic_vector(unsigned(rs_ram_rd_address) + 1);
                 
               else
                 hamming_state       <= S_WAIT_ENOUGH_RS_PARITY_B2;
               end if;
                  
              else
              
                hamming_state       <= S_WAIT_ENOUGH_RS_PARITY_B2;
               
              end if;
              
            --end if;
          --=======================================================================================        
          when S_HAMMING_RS_PARITY_MSG_B2 =>  
          --=======================================================================================
            
              HAM_parity_bits_ready_B2 <= '1';
              
              -------------------------------------------------------
              -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
              -- this is how it should be....
              -- but software implementation is different...
              -- and maybe it's a better way  
              --out_buffer(72)  <=  hamming_parity_tmp(0); 
              --out_buffer(73)  <=  hamming_parity_tmp(1);
              --out_buffer(74)  <=  hamming_parity_tmp(2);                                      
              --out_buffer(76)  <=  hamming_parity_tmp(3);
              --out_buffer(80)  <=  hamming_parity_tmp(4);
              --out_buffer(88)  <=  hamming_parity_tmp(5);
              --out_buffer(104) <=  hamming_parity_tmp(6);
              --out_buffer(136) <=  hamming_parity_tmp(7); 
             
              out_buffer(143 downto 136) <=  hamming_parity_tmp;
              -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
              -------------------------------------------------------
             
              --if(rs_ram_rd_address(c_fec_ram_addr_width-3 downto 0) = RSin_msg_size(c_fec_msg_size_MAX_Bytes_width  - 1 downto 3)) then  
              --if(rs_ram_rd_address(c_fec_ram_addr_width-1 downto 0) = RSin_msg_size(c_fec_ram_addr_width- 1 downto 3)) then 
              if(rs_ram_rd_address = ram_addr_divMsg_size) then 
                 
                 if(mem_all_HAM_parity_bits_sent_b1 = '1' or all_HAM_parity_bits_sent_b1 = '1') then   
                 
                   mem_all_HAM_parity_bits_sent_b1 <='0';
                                 
                   hamming_state                   <= S_HAMMING_RS_PARITY_MSG_B1;
                   hamming_in_data                 <= rs_ram_output;
                   
                   -------------------------------------------------------
                   -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                   -- this is how it should be....
                   -- but software implementation is different...
                   -- and maybe it's a better way 
                   --out_buffer(3)                   <= rs_ram_output(0);
                   --out_buffer(7  downto 5)         <= rs_ram_output(3 downto 1);
                   --out_buffer(15 downto 9)         <= rs_ram_output(10 downto 4);
                   --out_buffer(31 downto 17)        <= rs_ram_output(25 downto 11);
                   --out_buffer(63 downto 33)        <= rs_ram_output(56 downto 26);
                   --out_buffer(71 downto 65)        <= rs_ram_output(63 downto 57);
                   
                   out_buffer(63 downto 0)        <= rs_ram_output;                   
                   
                   -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                   -------------------------------------------------------
                   
                   rs_ram_rd_address               <= std_logic_vector(unsigned(rs_ram_rd_address) + 1);
                 else
                   
                   hamming_state                   <= S_WAIT_ENOUGH_RS_PARITY_B1;       
                   
                 end if;
              
              elsif(unsigned(rs_ram_rd_address) = unsigned(ram_addr_origMsg_size)  ) then 
              
                hamming_state       <= S_ALL_HAMMED;

              elsif(unsigned(rs_ram_wr_address) > unsigned(rs_ram_rd_address)) then 
              
                if(mem_all_HAM_parity_bits_sent_b1 = '1' or all_HAM_parity_bits_sent_b1 = '1') then  
                
                  mem_all_HAM_parity_bits_sent_b1 <='0';
            
                  hamming_state                   <= S_HAMMING_RS_PARITY_MSG_B1;
                  hamming_in_data                 <= rs_ram_output;
                
                  -------------------------------------------------------
                  -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^              
                  -- this is how it should be....
                  -- but software implementation is different...
                  -- and maybe it's a better way                 
                  --out_buffer(3)                   <= rs_ram_output(0);
                  --out_buffer(7  downto 5)         <= rs_ram_output(3 downto 1);
                  --out_buffer(15 downto 9)         <= rs_ram_output(10 downto 4);
                  --out_buffer(31 downto 17)        <= rs_ram_output(25 downto 11);
                  --out_buffer(63 downto 33)        <= rs_ram_output(56 downto 26);
                  --out_buffer(71 downto 65)        <= rs_ram_output(63 downto 57);

                  out_buffer(63 downto 0)        <= rs_ram_output;
                  
                  -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                  -------------------------------------------------------
            
                  rs_ram_rd_address               <= std_logic_vector(unsigned(rs_ram_rd_address) + 1);
                else
                  hamming_state       <= S_WAIT_ENOUGH_RS_PARITY_B1;                  
                end if;
              else
              
                hamming_state       <= S_WAIT_ENOUGH_RS_PARITY_B1;
               
              end if;
              
          --=======================================================================================        
          when S_ALL_HAMMED => 
          --=======================================================================================             
               if(all_HAM_parity_bits_sent_b1 = '1' and all_HAM_parity_bits_sent_b2 = '1') then
                 hamming_state <= S_IDLE;
               end if;
          --=======================================================================================
          when others =>
          --=======================================================================================           
            hamming_state <= S_IDLE;
          --=======================================================================================   
        end case;
        

        
      end if;
    end if;
  end process;
  
  
 hamming_parity_tmp <= hamming(hamming_in_data, c_fec_Hamming_word_size);
 
 
 --===============================================================================================
 -- sending 
 --===============================================================================================
 fsm_sending : process(clk_i, rst_n_i)
 
 ----------------------------------------------------------------------------------------
 -- counting bits in the frame (message)
 -- which is currently being sent 
 variable sent_singleMsg_bit_cnt            : integer range 0 to c_fec_MSG_size_MAX_bits - 1;
 variable eth_header_size_bits              : integer range 0 to c_fec_Ethernet_header_size_MAX_bits - 1;
 variable sent_FECheader_bit_cnt            : integer range 0 to c_fec_FEC_header_size_bits;
 variable cnt_sent_frames                   : integer range 0 to c_fec_out_MSG_num_MAX - 1;
 ---------------------------------------------------------------------------------------- 
 
 begin
   if rising_edge(clk_i) then
     if(rst_n_i = '0' or  if_in_ctrl_i = c_FECIN_ABANDON) then --TODO: this is temporary solution
     --========================================
     output_words_cnt             <= (others => '0');
     output_words_cnt_mod9        <= (others => '0');
     ---
     if_byte_sel_o                <= (others => '0');
     all_HAM_parity_bits_sent_B1  <='0';
     all_HAM_parity_bits_sent_B2  <='0';
     if_out_ctrl_o                <= '0';
     
     if_out_frame_cyc             <='0';
     if_out_start_frame_o         <='0';
     if_out_end_of_frame_o        <='0';
     if_out_end_of_fec_o          <='0';
     
     if_data_o                    <=(others =>'0');
     current_hamming_buf_num      <= '0';
     header_ram_rd_address        <=(others =>'0');
     
     ----- variables
     sent_singleMsg_bit_cnt       := 0;
     eth_header_size_bits         := 0;

     sent_FECheader_bit_cnt       := 0;
     cnt_sent_frames              := 0;
     sending_state                <= S_IDLE;
     out_helper_ctrl_d            <='0';
     out_helper_buffer            <=(others =>'0');
     inc_fragmentID               <= '0';
     --========================================
     else
       
      

       -- main finite state machine
       case sending_state is

         --=======================================================================================
         when S_IDLE => -- doing nothing
         --=======================================================================================   
           
           output_words_cnt             <= (others => '0');
           output_words_cnt_mod9        <= (others => '0');
           ---
           if_byte_sel_o                <= (others => '0');
           all_HAM_parity_bits_sent_B1  <='0';
           all_HAM_parity_bits_sent_B2  <='0';
           if_out_ctrl_o                <= '0';
      
           if_out_frame_cyc             <='0';
           if_out_start_frame_o         <='0';
           if_out_end_of_frame_o        <='0';
           if_out_end_of_fec_o          <='0';
      
           if_data_o                    <=(others =>'0');
           current_hamming_buf_num      <= '0';
           header_ram_rd_address        <=(others =>'0');
      
           ----- variables
           sent_singleMsg_bit_cnt       := 0;
 
           sent_FECheader_bit_cnt       := 0;
           cnt_sent_frames              := 0;
           
           if(receive_state = S_PAYLOAD) then
           
             -- sending headers first
             sending_state                <= S_SEND_ETHERNET_HEADER;
             current_hamming_buf_num      <= '0';
             
             eth_header_size_bits         := to_integer(unsigned(eth_header_size));
             header_ram_rd_address        <=(others =>'0');
             sent_singleMsg_bit_cnt       := 0;
             all_HAM_parity_bits_sent_B1  <='1';
             all_HAM_parity_bits_sent_B2  <='1';
             
           end if;
              
           out_helper_ctrl_d              <='0';
           out_helper_buffer              <=(others =>'0');

         
         --=======================================================================================
         when S_SEND_ETHERNET_HEADER =>   -- [this state needed a lot of debugging, tricky]
         --=======================================================================================
    
         if(if_out_ctrl_i = '1') then
           --if_out_ctrl_o <='0';
           if(out_helper_ctrl_d = '0') then
             out_helper_buffer <= header_ram_output;
           end if;
         else
            if_out_end_of_frame_o        <='0';
            if_out_start_frame_o         <='0';
            
            -- here we need to increment the readout address of the RAM
            if(sent_singleMsg_bit_cnt <  (eth_header_size_bits - c_fec_engine_data_width)) then
              
              if(out_helper_ctrl_d = '1') then                  
                if_data_o             <= out_helper_buffer;
                
              else
                if_data_o             <= header_ram_output;
              end if;
              if_out_ctrl_o         <= '1';
              if_byte_sel_o         <= (others => '1');
              if_out_frame_cyc      <='1';
              if(if_out_frame_cyc = '0') then
                if_out_start_frame_o         <='1';
              end if;
              
              header_ram_rd_address <= std_logic_vector(unsigned(header_ram_rd_address) + 1);

            -- two steps before the end (the data is read 1 cycle after setting the address
            -- we don't need to increment the address any more              
            elsif(sent_singleMsg_bit_cnt <=  eth_header_size_bits) then
                                  
                if(out_helper_ctrl_d = '1') then                  
                  if_data_o             <= out_helper_buffer;
                else
                  if_data_o             <= header_ram_output;
                end if;
                if_out_ctrl_o         <= '1';
                if_byte_sel_o         <= (others => '1');
                
            -- NOTE, that here we already start to output FEC header!!!    
            else
              
              sending_state          <= S_SEND_FEC_HEADER;
              header_ram_rd_address  <= (others =>'0');
              sent_FECheader_bit_cnt := 0;
              sent_singleMsg_bit_cnt := 0;
              
              if_out_ctrl_o         <= '1';
              if_out_frame_cyc      <= '1';
              if_byte_sel_o         <= (others => '1');
              
              for i in 0 to (c_fec_engine_data_width-1) loop
                if_data_o(i)           <=  fec_header_buffer(sent_FECheader_bit_cnt);
                sent_FECheader_bit_cnt := sent_FECheader_bit_cnt + 1;
              end loop;
              
            end if;
            
            -- we alwasy add this !!!!
            sent_singleMsg_bit_cnt := sent_singleMsg_bit_cnt + c_fec_engine_data_width;
            
          end if;
            

         --=======================================================================================
         when S_SEND_FEC_HEADER =>   
         --=======================================================================================
         
         if(if_out_ctrl_i = '1') then
           --if_out_ctrl_o <='0';
           
         else
           
           if_out_end_of_frame_o        <='0';
           
           if(sent_FECheader_bit_cnt < (c_fec_FEC_header_size_bits - c_fec_engine_data_width)) then
  
             for i in 0 to (c_fec_engine_data_width-1) loop
               if_data_o(i)           <=  fec_header_buffer(sent_FECheader_bit_cnt);
               sent_FECheader_bit_cnt := sent_FECheader_bit_cnt + 1;
             end loop;
             
           else
             
             for i in 0 to (c_fec_engine_data_width-1) loop
               if_data_o(i)           <=  fec_header_buffer(sent_FECheader_bit_cnt);
               sent_FECheader_bit_cnt := sent_FECheader_bit_cnt + 1;
             end loop;
             
             sending_state            <= S_SEND_PAYLOAD;
             sent_FECheader_bit_cnt   := 0;
             sent_singleMsg_bit_cnt   := 0;
             
             inc_fragmentID               <= '1';
             output_words_cnt             <= (others => '0');
             output_words_cnt_mod9        <= (others => '0');
             
           end if;
          end if;             
         
         --=======================================================================================
         when S_SEND_PAYLOAD =>   
         --=======================================================================================
           inc_fragmentID               <='0';
           all_HAM_parity_bits_sent_B1  <='0';
           all_HAM_parity_bits_sent_B1  <='0';
           if_byte_sel_o                <= "11";
            
           if(if_out_ctrl_i = '1') then
            
              --sending_state             <= S_PAUSE;
              --if_out_ctrl_o             <='0';                  
           else -- sending data
              
              if_out_end_of_frame_o        <='0';
              if_out_ctrl_o               <='1';
              
              output_words_cnt_mod9      <= std_logic_vector(unsigned(output_words_cnt_mod9) + 1);
              output_words_cnt           <= std_logic_vector(unsigned(output_words_cnt) + 1);
             
                if(output_words_cnt_mod9 = x"0") then if_data_o <= out_buffer(15  downto 0); 
             elsif(output_words_cnt_mod9 = x"1") then if_data_o <= out_buffer(31  downto 16);
             elsif(output_words_cnt_mod9 = x"2") then if_data_o <= out_buffer(47  downto 32);
             elsif(output_words_cnt_mod9 = x"3") then if_data_o <= out_buffer(63  downto 48);
             elsif(output_words_cnt_mod9 = x"4") then if_data_o <= out_buffer(79  downto 64); 
                                     all_HAM_parity_bits_sent_B1 <= '1'; 
             elsif(output_words_cnt_mod9 = x"5") then if_data_o <= out_buffer(95  downto 80);
             elsif(output_words_cnt_mod9 = x"6") then if_data_o <= out_buffer(111 downto 96);
             elsif(output_words_cnt_mod9 = x"7") then if_data_o <= out_buffer(127 downto 112);
             elsif(output_words_cnt_mod9 = x"8") then if_data_o <= out_buffer(143 downto 128);
                                          output_words_cnt_mod9 <= (others =>'0');
                                    all_HAM_parity_bits_sent_B2 <= '1';
             else                         output_words_cnt_mod9 <= (others =>'0');
             end if;


             if( output_words_cnt = end_of_outmsg ) then 
                if(output_words_cnt_mod9 = "0100") then -- 4
                  if_byte_sel_o <= "01";
                else
                  if_byte_sel_o <= "11";
                end if;
                output_words_cnt      <= (others => '0');
                output_words_cnt_mod9 <= (others => '0');
                sending_state         <= S_NEXT_FRAME;
                if_out_end_of_frame_o <= '1';
                if(cnt_sent_frames = 3) then 
                  if_out_end_of_fec_o    <='1';
                end if;
                
-- bug(?)[26/09] with eating words between messages                
--                all_HAM_parity_bits_sent_B1 <= '1';
--                all_HAM_parity_bits_sent_B2 <= '1';
                
                
                
             end if;

             
--             elsif(all_HAM_parity_bits_sent_b1 = '1' and all_HAM_parity_bits_sent_b2 = '1') then
--               sending_state       <= S_WAIT_DATA;
--             else
--               sending_state      <= S_SEND_PAYLOAD;           
--             end if;
             
           end if;
           
         --=======================================================================================
         when S_WAIT_DATA =>   
         --======================================================================================= 

           if(current_hamming_buf_num = '0') then 
             if(HAM_parity_bits_ready_B1 = '1' and if_out_ctrl_i = '0') then
               sending_state <= S_SEND_PAYLOAD;
             end if;
           else
             if(HAM_parity_bits_ready_B2 = '1' and if_out_ctrl_i = '0') then
               sending_state <= S_SEND_PAYLOAD;             
             end if;
             
          
           end if;           
         --=======================================================================================        
         when S_NEXT_FRAME =>  
         --=======================================================================================  
           if_byte_sel_o                <= (others => '0');
           if_out_ctrl_o                <= '0';
           all_HAM_parity_bits_sent_B1  <= '0';
           all_HAM_parity_bits_sent_B1  <= '0';
           if_out_frame_cyc             <= '0';
           if_out_end_of_frame_o        <= '0';
           
           if(cnt_sent_frames = 3) then 
             sending_state          <= S_ALL_SENT;
             --if_out_end_of_fec_o    <='1';
           --else
           elsif(if_out_ctrl_i = '0') then
             sending_state   <= S_SEND_ETHERNET_HEADER;
             cnt_sent_frames := cnt_sent_frames + 1;
             
-- bug(?)[26/09] it cause one buffer (64bits) to be skipped
-- why did I put the condition here?             
--             if(cnt_sent_frames = 2) then
--               if(all_HAM_parity_bits_sent_B1 = '0') then
--                 all_HAM_parity_bits_sent_B1 <='1';
--               end if;
--               if(all_HAM_parity_bits_sent_B2 = '0') then
--                 all_HAM_parity_bits_sent_B2 <='1';
--               end if;
--             end if;
           end if;
         --=======================================================================================        
         when S_PAUSE =>  
         --=======================================================================================
         --=======================================================================================        
         when S_ALL_SENT => 
         --=======================================================================================             

            sending_state          <= S_IDLE;
            if_out_end_of_fec_o    <='0';
            cnt_sent_frames        :=0;
         --=======================================================================================
         when others =>
         --======================================================================================= 
           sending_state <= S_IDLE;
                   
         --=======================================================================================   
       end case;
       
       if (all_HAM_parity_bits_sent_b1 = '1') then -- and (hamming_state = S_HAMMING_RS_PARITY_MSG_b1 or hamming_state = S_HAMMING_ORIGINAL_MSG_b1)) then
          all_HAM_parity_bits_sent_b1     <='0';
       end if;
       if (all_HAM_parity_bits_sent_b2 = '1') then -- and (hamming_state = S_HAMMING_RS_PARITY_MSG_b2 or hamming_state = S_HAMMING_ORIGINAL_MSG_b2)) then
          all_HAM_parity_bits_sent_b2     <='0';
       end if;
       
       -- for the purpose of header output
       out_helper_ctrl_d <= if_out_ctrl_i;
              
     end if;
   end if;
 end process;

 if_out_frame_cyc_o <= if_out_frame_cyc;
   
  

  
end rtl;
