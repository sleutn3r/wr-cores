------------------------------------------------------------------------
-- Title      : Forward Error Correction
-- Project    : WhiteRabbit Node
-------------------------------------------------------------------------------
-- File       : wr_fec_de_engine.vhd
-- Author     : Maciej Lipinski
-- Company    : CERN BE-Co-HT
-- Created    : 2011-07-15
-- Last update: 2011-07-024
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-- TO BE DONE, unfinished
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

entity wr_fec_de_engine is
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
end wr_fec_de_engine;

architecture rtl of wr_fec_de_engine is

  
    
  --------------------------------------------------------------------------------------------------
  -- Reception FINITE STATE MACHINE
  --------------------------------------------------------------------------------------------------

  -- reception FSM
  type t_receive_state is (
       	S_IDLE,          -- doing nothing
        S_HEADER,        -- receiving header
	      S_PAYLOAD,       -- receiving payload to be encoded
        S_PAUSE,         -- pause in receiving header or payload
        S_WAIT_ENCODING  -- wait util encoding and sending of the message is 
			 -- finished
	);      

  -- declarations
  signal receive_state         : t_receive_state;

  -- input data
  signal if_data_i             : std_logic_vector(c_fec_engine_data_width  - 1 downto 0);
  
  signal input_round_buffer    : std_logic_vector(143 downto  0);
  signal input_buffer_low_ready: std_logic;
  signal input_buffer_high_ready: std_logic;
  
  signal hammed_fec_header     : std_logic_vector(71  downto 0);
  -- counting input words
  signal input_word_cnt: std_logic_vector(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);

  -- size of the received header
  signal eth_header_size :  std_logic_vector(c_fec_Ethernet_header_size_MAX_bits_width - 1 downto 0);
  
  -- header RAM
  signal header_ram_we         : std_logic;
  signal header_ram_rd_address : std_logic_vector(c_fec_Ethernet_header_ram_addr_width    - 1 downto 0);
  signal header_ram_wr_address : std_logic_vector(c_fec_Ethernet_header_ram_addr_width    - 1 downto 0);
  signal header_ram_input      : std_logic_vector(c_fec_engine_data_width - 1 downto 0);
  signal header_ram_output     : std_logic_vector(c_fec_engine_data_width - 1 downto 0);

  -- the msg ID of the message being decoded
  signal processed_msg_ID     : std_logic_vector(c_fec_FEC_header_FEC_ID_bits   - 1 downto 0);

  -- info from  currently process message
  signal fec_header_FEC_scheme : std_logic_vector(c_fec_FEC_header_Scheme_bits   - 1 downto 0);
  signal fec_header_frag_ID    : std_logic_vector(c_fec_FEC_header_FRAME_ID_bits - 1 downto 0);
  signal fec_header_msg_ID     : std_logic_vector(c_fec_FEC_header_FEC_ID_bits   - 1 downto 0);
  signal fec_header_orig_len   : std_logic_vector(c_fec_FEC_original_len_bits    - 1 downto 0);
  signal fec_header_frag_len   : std_logic_vecotr(c_fec_FEC_fragment_len_bits    - 1 downto 0);
  signal fec_header_etherType  : std_logic_vector(c_fec_FEC_header_etherType_bits- 1 downto 0);

  -- number of messages with fec-ed information and the same msg id
  signal fec_msg_cnt           : std_logic_vector(c_fec_out_MSG_num_MAX_width -1 downto 0);
  
  --------------------------------------------------------------------------------------------------
  -- Xxxx FINITE STATE MACHINE
  --------------------------------------------------------------------------------------------------
  
   
begin 
  
  zeros(31 downto 0 ) <= (others => '0');
   
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
      eth_header_size        <= (others =>'0');
      eth_header_size_cnt    :=0;
      -- RAMs
      header_ram_we          <= '0';  
      header_ram_wr_address  <= (others =>'0');  
      header_ram_input       <= (others =>'0');  
      -- outputs
      if_busy_o             <= '0';
      if_in_ctrl_o          <= '0';
      receive_state         <= S_IDLE;
      input_buffer_low_ready<='0';
      input_buffer_high_ready<='0';
      hammed_fec_header     <= (others =>'0');
      input_round_buffer    <= (others =>'0');
      --========================================
      else

        -- main finite state machine
        case receive_state is

          --=======================================================================================
          when S_IDLE =>
          --=======================================================================================   
    	      
    	       input_payload_word_cnt <= (others => '0');
            eth_header_size        <= (others =>'0');
            eth_header_size_cnt    :=0;
            -- RAMs
            header_ram_we          <= '0';  
            header_ram_wr_address  <= (others =>'0');  
            header_ram_input       <= (others =>'0');  
    	      
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
               
       	       if_in_ctrl_o          <= '0'; 
       	       eth_header_size       <= (others =>'0');
       	       eth_header_size_cnt   := c_fec_engine_data_width;
               
               -- FEC header info
               fec_header_FEC_scheme <= (others => '0');
               fec_header_frag_ID    <= (others => '0');
               fec_header_msg_ID     <= (others => '0');
               fec_header_orig_len   <= (others => '0');
               fec_header_frag_len   <= (others => '0');
               fec_header_etherType  <= (others => '0');
       	       
            end if;

  

          --=======================================================================================
          when S_HEADER =>
          --=======================================================================================  
            
            if( if_in_ctrl_i = b"100") then 
               
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
   	          if(eth_header_size_cnt < 18 * 8) then
   	          
  	             -- remembering header size
   	            eth_header_size       <= x"00" & "01110000" ;--14 Bytes
   	            
 	            else
 	              
                -- remembering header size
                eth_header_size <= x"00" & "10010000" ;--18 Bytes
                
 	            end if;
              -----------------------------------------------------  
              header_ram_wr_address <= (others=>'0');
              header_ram_we         <= '0';              
              -----------------------------------------------------   	           
              --              payload start                      -- 
              ----------------------------------------------------- 	          
       	      receive_state             <= S_BARE_FEC_HEADER;

              fec_header_FEC_scheme         <= if_data_i(3  downto 0);
              fec_header_frag_ID            <= if_data_i(7  downto 4);
              fec_header_msg_ID(7 downto 0) <= if_data_i(15 downto 8);

              input_word_cnt               <= std_logic_vector(unsigned(input_word_cnt) + 1 );
               
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
          when S_BARE_FEC_HEADER =>
          --=======================================================================================

            -- input transfer finished
            if( if_in_ctrl_i = b"100") then 
               

            -- 3 = transfer pause
            elsif( if_in_ctrl_i = b"011") then 
               
              receive_state <= S_PAUSE;
              
            -- we can store in RAM  
            elsif(if_in_ctrl_i = b"010") then
              
              fec_header_msg_ID(15 downto 8) <= if_data_i( 7 downto 0);
              hammed_fec_header( 7 downto 0) <= if_data_i(15 downto 8);
              
              input_word_cnt                 <= std_logic_vector(unsigned(input_word_cnt) + 1 );
              output_words_cnt_mod9          <= (others =>'0');
              receive_state                  <= S_HAMMED_FEC_HEADER;
              
            else

              assert false
                 report "Payload: want to write too big header to the header buffer";

            end if;
            
          --=======================================================================================  
          when S_HAMMED_FEC_HEADER =>
          --=====================================================================================

            
            -- input transfer finished
            if( if_in_ctrl_i = b"100") then 
               

            -- 3 = transfer pause
            elsif( if_in_ctrl_i = b"011") then 
               
              receive_state <= S_PAUSE;
              
            -- we can store in RAM  
            elsif(if_in_ctrl_i = b"010") then
              

               output_words_cnt_mod9      <= std_logic_vector(unsigned(output_words_cnt_mod9) + 1);
              
                  if(output_words_cnt_mod9 = x"0") then hammed_fec_header(23 downto 8)  <= if_data_i; 
               elsif(output_words_cnt_mod9 = x"1") then hammed_fec_header(39 downto 24) <= if_data_i;
               elsif(output_words_cnt_mod9 = x"2") then hammed_fec_header(55 downto 40) <= if_data_i;
               elsif(output_words_cnt_mod9 = x"3") then hammed_fec_header(71 downto 56) <= if_data_i;
                                                        receive_state                   <= S_HAMMED_DATA;
                                                        output_words_cnt_mod9           <= (others =>'0');
               else                                     output_words_cnt_mod9           <= (others =>'0');
               end if;
              
            else

              assert false
                 report "Payload: want to write too big header to the header buffer";

            end if;

          --=======================================================================================  
          when S_HAMMED_DATA =>
          --=====================================================================================

            
            -- input transfer finished
            if( if_in_ctrl_i = b"100") then 
               

            -- 3 = transfer pause
            elsif( if_in_ctrl_i = b"011") then 
               
              receive_state <= S_PAUSE;
              
            -- we can store in RAM  
            elsif(if_in_ctrl_i = b"010") then
              

              output_words_cnt_mod9      <= std_logic_vector(unsigned(output_words_cnt_mod9) + 1);
              output_words_cnt           <= std_logic_vector(unsigned(output_words_cnt) + 1);
             
                  if(output_words_cnt_mod9 = x"0") then input_round_buffer(15  downto 0)  <= if_data_i; 
               elsif(output_words_cnt_mod9 = x"1") then input_round_buffer(31  downto 16) <= if_data_i;
               elsif(output_words_cnt_mod9 = x"2") then input_round_buffer(47  downto 32) <= if_data_i;
               elsif(output_words_cnt_mod9 = x"3") then input_round_buffer(63  downto 48) <= if_data_i;
               elsif(output_words_cnt_mod9 = x"4") then input_round_buffer(79  downto 64) <= if_data_i;
                                                        input_buffer_low_ready           <= '0';
               elsif(output_words_cnt_mod9 = x"5") then input_round_buffer(95  downto 80) <= if_data_i;
               elsif(output_words_cnt_mod9 = x"6") then input_round_buffer(111 downto 96) <= if_data_i;
               elsif(output_words_cnt_mod9 = x"7") then input_round_buffer(127 downto 112)<= if_data_i;
               elsif(output_words_cnt_mod9 = x"8") then input_round_buffer(143 downto 128)<= if_data_i;
                                                        input_buffer_high_ready          <= '0';
               else                         output_words_cnt_mod9 <= (others =>'0');
               end if;
              
            else

              assert false
                 report "Payload: want to write too big header to the header buffer";

            end if;




          --=======================================================================================
          when S_WAIT_NEXT_FRAME =>
          --=======================================================================================



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
  

  
     
  
end rtl;
