------------------------------------------------------------------------
-- Title      : Forward Error Correction
-- Project    : WhiteRabbit Node
-------------------------------------------------------------------------------
-- File       : wr_fec_en_interface.vhd
-- Author     : Maciej Lipinski
-- Company    : CERN BE-Co-HT
-- Created    : 2011-04-12
-- Last update: 2011-07-27
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This is an interface to the FEC engine, i does:
-- * Rx Wishbone pipelined Slave
-- * Tx Wishbone pipelined Master
-- * recognition of to-be-FECed incoming frame transmission (first write
--   to the FEC address), 
-- * MUX of data/bypass of FEC engine, if the frame is not to be FECed, it
--   it just connets inputs to outputs 
-- * it recognizes the kind of ethernet frame header (VLAN-tagged/untagged)
-- * it strips incoming messages from FEC/STATUS/OOB data and adds the 
--   STATUS/OOB data to the outcoming (FECed) data:
--   -> non-error STATUS is always added to the beginning of all the outcoming
--      frames, regarding incoming frames, we assume that non-error STATUS is 
--      received at the beginning of the frame, but other cases are also possible
--   -> error STATUS is added to the outcoming frame directly after reception
--      on the input, its reception stops FECing
--   -> OOB is assumed to be received at the end of the incoming frame, but
--      other cases are possible (including having many OOB words spread 
--      through the frame. All the OOB words are collected, and added to the
--      end of the last FECed frame
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
-- 2011-04-0 2 1.0      mlipinsk Created
-- 2011-07-27  1.0      mlipinsk debugged
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wr_fec_pkg.all;
use work.genram_pkg.all; -- wrappers for RAM/FIFO by Tomek




entity wr_fec_en_interface is
  port (
     clk_i   : in std_logic;
     rst_n_i : in std_logic;
    
     ---------------------------------------------------------------------------------------
     -- talk with outside word
     ---------------------------------------------------------------------------------------
     -- 32 bits wide wishbone slave RX input
     wbs_dat_i	  : in  std_logic_vector(wishbone_data_width_in-1 downto 0);
     wbs_adr_i	  : in  std_logic_vector(wishbone_address_width_in-1 downto 0);
     wbs_sel_i	  : in  std_logic_vector((wishbone_data_width_in/8)-1 downto 0);
     wbs_cyc_i	  : in  std_logic;
     wbs_stb_i	  : in  std_logic;
     wbs_we_i	   : in  std_logic;
     wbs_err_o	  : out std_logic;
     wbs_stall_o	: out std_logic;
     wbs_ack_o	  : out std_logic;

    
     -- 32 bits wide wishbone Master TX input
      
     wbm_dat_o 	: out std_logic_vector(wishbone_data_width_out-1 downto 0);
     wbm_adr_o	 : out std_logic_vector(wishbone_address_width_out-1 downto 0);
     wbm_sel_o	 : out std_logic_vector((wishbone_data_width_in/8)-1 downto 0);
     wbm_cyc_o	 : out std_logic;
     wbm_stb_o	 : out std_logic;
     wbm_we_o	  : out std_logic;
     wbm_err_i	 : in std_logic;
     wbm_stall_i: in  std_logic;
     wbm_ack_i	 : in  std_logic; 
     
     ---------------------------------------------------------------------------------------
     -- talk with FEC ENGINE
     ---------------------------------------------------------------------------------------
    
     -- input data to be encoded
     if_data_o         : out  std_logic_vector(c_fec_engine_data_width  - 1 downto 0);
     
     -- input data byte sel
     if_byte_sel_o     : out std_logic_vector(c_fec_engine_Byte_sel_num  - 1 downto 0);
     
     -- encoded data
     if_data_i         : in std_logic_vector(c_fec_engine_data_width  - 1 downto 0);
     
     -- indicates which Bytes of the output data have valid data
     if_byte_sel_i     : in std_logic_vector(c_fec_engine_Byte_sel_num  - 1 downto 0);
     
     -- size of the incoming message to be encoded (entire Control Message)
     if_msg_size_o     : out  std_logic_vector(c_fec_msg_size_MAX_Bytes_width     - 1 downto 0);
     
     
     -- tells FEC whether use FEC_ID provided from outside word (HIGH)
     -- or generate it internally (LOW)
     if_FEC_ID_ena_o   : out std_logic;
     
     -- ID of the message to be FECed, used only if if_FEC_ID_ena_i=HIGH
     if_FEC_ID_o       : out  std_logic_vector(c_fec_FEC_header_FEC_ID_bits     - 1 downto 0);
     -- information what the engine is supposed to do:
     -- 0 = do nothing
     -- 1 = header is being transfered
     -- 2 = payload to be encoded is being transfered
     -- 3 = transfer pause
     -- 4 = message end
     if_in_ctrl_o         : out  std_logic_vector(2 downto 0);

     -- strobe when settings (msg size and output msg number) available
     if_in_settngs_ena_o  : out std_logic;
     
     -- it provides to the FEC engine original etherType, which should be 
     -- added to the FEC header, the interface remembers the original etherType 
     -- and sends to the FEC engine the frame header with already replaced 
     -- etherType (FEC etherType).
     -- this output is assumed to be valid on the finish of header trasmission
     -- so starting with the first word of the PAYLOAD
     if_in_etherType_o : out std_logic_vector(15 downto 0);
          
     -- kind-of-flow control:
     -- 0 = ready for data
     -- 1 = pause
     if_in_ctrl_i         : in std_logic;

     -- indicates whether engine is ready to encode new Control Message
     -- 0 = idle
     -- 1 = busy
     if_busy_i         : in std_logic;

     -- info about output data
     -- 0 = no data ready
     -- 1 = outputing header 
     -- 2 = outputing payload
     -- 3 = output pause 
     --if_out_ctrl_o         : out  std_logic_vector(1 downto 0);
     
     -- 0 = data not available
     -- 1 data valid
     if_out_ctrl_i         : in  std_logic;
     
     -- is like cyc in WB, high thourhout single frame sending
     if_out_frame_cyc_i    : in std_logic;
     
     -- frame start (needs to be used with if_out_ctrl_o)
     if_out_start_frame_i  : in std_logic;      
     
     -- last (half)word of the frame
     if_out_end_of_frame_i : in std_logic;
     
     -- the end of the last frame
     if_out_end_of_fec_i   : in std_logic;
     
     -- indicates whether output interface is ready to take data
     -- 0 = ready
     -- 1 = busy     
     if_out_ctrl_o         : out  std_logic;
     
     -- '1' => VLAN-taged frame
     -- '0' => untagged frame
     --if_in_vlan_tagged_frame_o  : out std_logic;
     
     -- info on desired number of output messages, should be available 
     -- at the same time as
     if_out_MSG_num_o  : out  std_logic_vector(c_fec_out_MSG_num_MAX_width - 1 downto 0)     

  );
end wr_fec_en_interface;

architecture rtl of wr_fec_en_interface is


signal header_word_cnt : std_logic_vector(4 downto 0); -- max: 16

-- high if FECing is enabled (which is done by writing at the beginning of the frame
-- tranmission (cycle) payload's size to WBP_FEC address (the size is checked for sanity)
signal fec_enabled           : std_logic;

-- controls the mux of WBp Master output signals (input or FEC engine)
signal bypass_fec            : std_logic;


signal msg_size              : std_logic_vector(wishbone_data_width_in-1 downto 0);

-- signals to control WBp Slave
signal fec_2_wbs_err	        : std_logic;
signal fec_2_wbs_stall	      : std_logic;
signal fec_2_wbs_ack  	      : std_logic;

-- signals to control WBp Master
signal fec_2_wbm_dat        	: std_logic_vector(wishbone_data_width_out-1 downto 0);
signal fec_2_wbm_adr       	 : std_logic_vector(wishbone_address_width_out-1 downto 0);
signal fec_2_wbm_sel       	 : std_logic_vector((wishbone_data_width_out/8)-1 downto 0);
signal fec_2_wbm_cyc  	      : std_logic;
signal fec_2_wbm_stb  	      : std_logic;
signal fec_2_wbm_we  	       : std_logic;

-- used when RX slave (after FEC) asserts STALL, we need to remember data from FEC engine
-- before the FEC engine is stopped.... seems the same as if_out_ctrl
signal dummy           : std_logic;

-- WBp Slave
type t_rx_state is (
      S_IDLE,                -- doing nothing
      S_FEC_REG,             -- save size of the msg-to-be FECed
      S_RECEIVE_TO_FEC,      -- save the incoming message in FEC's memory
      S_BYPASS_FEC,          -- no FECing, input=output
      S_ERROR,               -- WBP_STATUS with error message received, abandon FECing
      S_DONE                 -- entire msg received by FEC engine, wait till FEC finishes
);      
-- WBp Master
type t_tx_state is (
      S_IDLE,                -- doing nothing
      S_SEND_FROM_FEC,       -- send messages produced by FEC 
      S_SEND_EXEPT_FEC_END,  -- if the stall happens at the very end of the last fec_frame
      S_SEND_EXEPT_FRAME_END,-- if the stall happens at the very end of the non-last fec_frame
      S_NEXT_CYC,            -- create a gap between two WBP cycles (to frames)
      S_WAIT_NEXT_CYC,       -- hmm, wait for stall on the last word, similar to the next, remove?
      S_SEND_LAST_WORD,      -- write the last word of a non-last frame or the last frame as well if there is no OOB to be added
      S_SEND_STATUS,         -- send WBP_STATUS
      S_SEND_OOB,            -- send WBP_OOB
      S_SEND_ERR,            -- send WBP_STATUS with error (directly after receiving it on the FEC's input, FECing is abandoned
      S_BYPASS_FEC,          -- no FECing, input=output
      S_DONE                 -- all FECed messages sent, wait for the FEC engine to be idle 
);  
type t_wbp_oob_dat_array     is array (c_oob_max_size - 1 downto 0) of std_logic_vector(wishbone_data_width_out-1 downto 0);
type t_wbp_oob_sel_array     is array (c_oob_max_size - 1 downto 0) of std_logic_vector((wishbone_data_width_out/8)-1  downto 0);

-- remember input WBP_STATUS data
signal wbp_status_reg       : std_logic_vector(wishbone_data_width_out-1 downto 0);
signal wbp_status_rx        : std_logic_vector(1 downto 0);

-- remember input WBP_OOB data
signal wbp_oob_dat_array    : t_wbp_oob_dat_array;
signal wbp_oob_sel_array    : t_wbp_oob_sel_array;

signal wbp_oob_cnt          : std_logic_vector(c_oob_max_size_width -1 downto 0);
signal wbp_obb_rx           : std_logic_vector(1 downto 0);

signal rx_state             : t_rx_state;
signal tx_state             : t_tx_state;

-- to control FEC engine output
signal if_out_ctrl          : std_logic;

-- saves data from FEC engine output eg. when the RX slave assersts STALL, 
-- this is because the output of WBP Master is delayed with regards to FEC engien output
-- bad name....
signal first_word_out       : std_logic_vector(wishbone_data_width_out-1 downto 0);
signal first_bsel_out       : std_logic_vector(1 downto 0);

-- we have Ethernet Frame header type (VLAN-tagged/untagged) detection
signal vlan_tagged_frame   : std_logic;

-- contols FEC's input
signal if_in_ctrl           : std_logic_vector(2 downto 0);

begin

if_out_MSG_num_o <=(others =>'0'); -- not implemented in wr_fec_engine

-- if the first world of the input  WB write is not to FEC address, then
-- there is no FEC performed and we just connect inputs to outputs
bypass_fec <= '1' when(if_busy_i              = '0'       and
                       fec_enabled            = '0'       and 
                       wbs_adr_i(1 downto 0) /= c_WBP_FEC and 
                       rx_state              /= S_FEC_REG)else 
              '0';

-- FEC Engine needs to know the size of the FECed message in advance,
-- the write to the FEC address should contain the size
if_msg_size_o <= msg_size(c_fec_msg_size_MAX_Bytes_width - 1 downto 0);

-- WB MUX
wbm_dat_o 	<= wbs_dat_i    when (bypass_fec = '1') else fec_2_wbm_dat;
wbm_adr_o	 <= wbs_adr_i    when (bypass_fec = '1') else fec_2_wbm_adr;
wbm_sel_o	 <= wbs_sel_i    when (bypass_fec = '1') else fec_2_wbm_sel;
wbm_cyc_o	 <= wbs_cyc_i    when (bypass_fec = '1') else fec_2_wbm_cyc;
wbm_stb_o	 <= wbs_stb_i    when (bypass_fec = '1') else fec_2_wbm_stb;
wbm_we_o	  <= wbs_we_i     when (bypass_fec = '1') else fec_2_wbm_we;

wbs_stall_o<= wbm_stall_i  when (bypass_fec = '1') else fec_2_wbs_stall;
wbs_ack_o	 <= wbm_ack_i    when (bypass_fec = '1') else fec_2_wbs_ack;
wbs_err_o  <= wbm_err_i    when (bypass_fec = '1') else fec_2_wbs_err;

-- control FEC engine
if_out_ctrl_o              <= if_out_ctrl;
if_in_ctrl_o               <=if_in_ctrl;
--if_in_vlan_tagged_frame_o <= vlan_tagged_frame; -- TODO: change name to if_*


  -- FSM for receiving data by WBp Slave interface and writing it into FEC Engine
  -- or just streaming it to the WBp Master output
  fsm_rx : process(clk_i, rst_n_i)
 
  --------------- variables--------------
  variable oob_cnt  : integer range 0 to c_oob_max_size ;
  begin
   if rising_edge(clk_i) then
     if(rst_n_i = '0') then
     --========================================
     header_word_cnt     <= (others => '0');
     fec_enabled         <='0';
     
     -- WB Slave
     fec_2_wbs_ack       <='0';
     fec_2_wbs_err       <='0';
     fec_2_wbs_stall     <='0';
     
     -- FEC Engine
     msg_size            <= (others =>'0');
     if_data_o           <= (others =>'0');
     if_byte_sel_o       <= (others =>'0');
     if_FEC_ID_ena_o     <='0';
     if_FEC_ID_o         <= (others =>'0');
     if_in_ctrl          <= c_FECIN_NO_DATA;
     if_in_settngs_ena_o <= '0';
     -- 
     
     wbp_status_reg       <= (others=>'0');
     wbp_status_rx        <= c_WBP_STATUS_EMPTY;

     for i in 0 to (c_oob_max_size -1) loop
       wbp_oob_dat_array(i)   <= (others =>'0');
       wbp_oob_sel_array(i)   <= (others =>'0');
     end loop;
     
     wbp_obb_rx           <= c_WBP_OOB_EMPTY;
     wbp_oob_cnt          <= (others =>'0');
     
     oob_cnt              :=0;
     vlan_tagged_frame  <= '0';
     if_in_etherType_o   <= (others=>'0');
     --========================================
     else
       -- by default '0', only strobe high
       if_in_settngs_ena_o <='0';
       fec_2_wbs_ack       <='0';
       fec_2_wbs_err       <='0';
       -- main finite state machine
       case rx_state is
         --=======================================================================================
         when S_IDLE => -- wait for write requiest from the Etherbone's WB Master
         --=======================================================================================   
         
            oob_cnt              :=0;
            wbp_oob_cnt          <=(others=>'0');
            vlan_tagged_frame   <= '0';
            if_in_etherType_o    <=(others=>'0');
            if_in_ctrl           <= c_FECIN_NO_DATA;
            
            if(wbs_cyc_i = '1' and wbs_stb_i = '1' and wbs_adr_i(1 downto 0) /= c_WBP_FEC) then
              
              -- no write to the FEC reg received, so the message will not be FECed
              fec_enabled  <='0';
              --next state
              rx_state     <= S_BYPASS_FEC;
                            
            elsif(wbs_cyc_i = '1' and wbs_stb_i = '1' and wbs_adr_i(1 downto 0) = c_WBP_FEC) then
              
              -- sanity check
              if(unsigned(wbs_dat_i) > to_unsigned(c_min_fec_size,wishbone_data_width_in)) then
                
                -- these two go togother -----
                msg_size        <= wbs_dat_i;
                fec_2_wbs_ack   <='1';
                -----------------------------
                --next state
                rx_state     <= S_FEC_REG;
              else
                fec_enabled  <='0';
                fec_2_wbs_err<='1';
                --next state
                rx_state     <= S_IDLE;
              end if;
              
            else
              
              header_word_cnt <= (others => '0');
              fec_enabled         <='0';
              
            end if;
            
            
         --=======================================================================================
         when S_FEC_REG => -- Etherbone indicates that msg should be FECed, make  size sanity check
         --=======================================================================================  

              fec_enabled         <='1';
              if_in_settngs_ena_o <='1';
            
            if(wbs_cyc_i = '1' and wbs_stb_i = '1' and wbs_adr_i(1 downto 0) /= c_WBP_FEC) then
            
              if(wbs_adr_i(1 downto 0) = c_WBP_STATUS) then
                
                -- detect error indication by the Master
                if((wbs_dat_i and c_WBP_STATUS_ERR_MASK) = c_WBP_STATUS_ERR_MASK) then
                  rx_state        <= S_ERROR;
                  wbp_status_rx   <= c_WBP_STATUS_RX_ERR;
                  if_in_ctrl      <= c_FECIN_ABANDON;
                else -- normal STATUS info
                  rx_state        <= S_RECEIVE_TO_FEC;
                  wbp_status_rx   <=c_WBP_STATUS_RX_INF;
                end if;
                -- these two go togother -----
                wbp_status_reg  <= wbs_dat_i;
                fec_2_wbs_ack   <='1';
                -----------------------------
                
              -- start of OOB transfer (it is assumed that OOB is at the end of the cycle  
              elsif(wbs_adr_i(1 downto 0) = c_WBP_OOB) then
                
                -- these two go togother -----
                wbp_oob_dat_array(0)   <= wbs_dat_i;
                wbp_oob_sel_array(0)   <= wbs_sel_i;
                fec_2_wbs_ack   <='1';
                -----------------------------
                
                wbp_obb_rx           <= c_WBP_OOB_RECEIVING;
                wbp_oob_cnt          <= std_logic_vector(unsigned(wbp_oob_cnt)+1);
                oob_cnt              :=oob_cnt+1;
                
              elsif(wbs_adr_i(1 downto 0) = c_WBP_DATA) then
                
                -- these two go togother -----
                if_data_o       <= wbs_dat_i;
                if_byte_sel_o   <= wbs_sel_i;
                fec_2_wbs_ack   <='1';
                -----------------------------
           
                -- starting with header reception, FEC Engine requires to indicate
                -- the header/payload transmission
                header_word_cnt <= std_logic_vector(unsigned(header_word_cnt) + 2);
                if_in_ctrl      <= c_FECIN_HEADER; 
                
                --next state              
                rx_state        <= S_RECEIVE_TO_FEC;
              end if;
            end if;
            

         --=======================================================================================
         when S_RECEIVE_TO_FEC => -- receive Ethernet frame from the Etherbone WB Master
         --=======================================================================================  

            -- valid data on the input
            if(wbs_cyc_i = '1' and wbs_stb_i = '1' and wbs_adr_i(1 downto 0) /= c_WBP_FEC) then
            
              -- receiving STATUS info
              if(wbs_adr_i(1 downto 0) = c_WBP_STATUS) then
                
                if((wbs_dat_i and c_WBP_STATUS_ERR_MASK) = c_WBP_STATUS_ERR_MASK) then
                  rx_state        <= S_ERROR;
                  wbp_status_rx   <= c_WBP_STATUS_RX_ERR;
                  if_in_ctrl      <= c_FECIN_ABANDON; 
                  
                else
                  rx_state        <= S_RECEIVE_TO_FEC;
                  wbp_status_rx   <=c_WBP_STATUS_RX_INF;
                end if;
                -- these two go togother -----
                wbp_status_reg  <= wbs_dat_i;
                fec_2_wbs_ack   <='1';
                -----------------------------
              
              -- receivingi OOB info  
              elsif(wbs_adr_i(1 downto 0) = c_WBP_OOB) then
                
                -- these two go togother -----
                wbp_oob_dat_array(oob_cnt)   <= wbs_dat_i;
                wbp_oob_sel_array(oob_cnt)   <= wbs_sel_i;
                fec_2_wbs_ack            <='1';
                -----------------------------
                
                wbp_obb_rx           <= c_WBP_OOB_RECEIVING;
                wbp_oob_cnt          <= std_logic_vector(unsigned(wbp_oob_cnt)+1);
                oob_cnt              :=oob_cnt+1;
                
               -- TODO: some sanity check would be nice                
                if_in_ctrl       <= c_FECIN_MSG_END;
                
              -- receiving DATA  
              elsif(wbs_adr_i(1 downto 0) = c_WBP_DATA) then
                
                -- these two go togother -----
                if_data_o       <= wbs_dat_i;
                if_byte_sel_o   <= wbs_sel_i;
                fec_2_wbs_ack   <='1';
                -----------------------------
                
                -- if the header is started to be transmitted (if_in_ctrl = c_FECIN_NO_DATA, 
                -- there was STALL in FEC_REG state) or the header is already trasmitted
                -- look for ETHERTYPE and check whether the header transfer is suppose to 
                -- be finished (recognition by size)
                if(if_in_ctrl = c_FECIN_HEADER or if_in_ctrl = c_FECIN_NO_DATA) then
                
                  -- ether type detectino
                  if(header_word_cnt = c_ETHERTYPE_ADDR_noVLAN and wbs_dat_i(15 downto 0) = c_VLAN_ETHERTYPE) then
                    vlan_tagged_frame  <='1';
                  elsif(header_word_cnt = c_ETHERTYPE_ADDR_noVLAN and wbs_dat_i(15 downto 0) /= c_VLAN_ETHERTYPE) then
                    if_in_etherType_o <= wbs_dat_i;
                    if_data_o         <= c_FEC_ETH_TYPE;
                    if_byte_sel_o     <= "11";
                  elsif(vlan_tagged_frame = '1' and header_word_cnt = c_ETHERTYPE_ADDR_VLAN) then 
                    if_in_etherType_o <= wbs_dat_i;
                    if_data_o         <= c_FEC_ETH_TYPE;
                    if_byte_sel_o     <= "11";
                  end if;
                  
                  header_word_cnt <= std_logic_vector(unsigned(header_word_cnt) + 2);
                  
                  -- depending on the etherType, the frame header can have different size,
                  -- check whether the header transmission is finished
                  if(vlan_tagged_frame = '1') then
                  
                    if(unsigned(header_word_cnt) < unsigned(c_eth_header_size_tagged) ) then
                      if_in_ctrl      <= c_FECIN_HEADER;
                    else
                      if_in_ctrl      <= c_FECIN_PAYLOAD;               
                    end if;
                  else
                    if(unsigned(header_word_cnt) < unsigned(c_eth_header_size_untagged) ) then
                      if_in_ctrl      <= c_FECIN_HEADER;
                    else
                      if_in_ctrl      <= c_FECIN_PAYLOAD;               
                    end if;
                 end if;
                
              -- pause in transmission from the WBp Master's side (stb=LOW) causes the
              -- FEC Engine to pause the input, it is done by setting in_ctrl=PAUSE.
              -- if there was a puase, and now it's not any more, we need to check
              -- whether we still transmit header.... or already payload  
              elsif(if_in_ctrl = c_FECIN_PAUSE ) then
         
                if(vlan_tagged_frame = '1') then
                  if(unsigned(header_word_cnt) <= unsigned(c_eth_header_size_tagged) ) then
                    if_in_ctrl      <= c_FECIN_HEADER;
                    header_word_cnt <= std_logic_vector(unsigned(header_word_cnt) + 2);
                  else
                    if_in_ctrl      <= c_FECIN_PAYLOAD;               
                  end if;
                else
                  if(unsigned(header_word_cnt) <= unsigned(c_eth_header_size_untagged) ) then
                    if_in_ctrl      <= c_FECIN_HEADER;
                    header_word_cnt <= std_logic_vector(unsigned(header_word_cnt) + 2);
                  else
                    if_in_ctrl      <= c_FECIN_PAYLOAD;               
                  end if;
                end if;  
                   
               end if;
                           
                --next state              
                rx_state        <= S_RECEIVE_TO_FEC;
              end if;
              
              -- if we werer receiving WBP_OOP and now we are not, it means that the 
              -- transfer has finished and the OOB is available to be sent (this is 
              -- the unusual case when we have OOB in the middle of the message...
              if(wbs_adr_i(1 downto 0) /= c_WBP_OOB and  wbp_obb_rx = c_WBP_OOB_RECEIVING) then
                wbp_obb_rx           <= c_WBP_OOB_AVAILABLE;
              end if;
             
            -- we should not have this, error 
            elsif(wbs_cyc_i = '1' and wbs_stb_i = '1' and wbs_adr_i(1 downto 0) = c_WBP_FEC) then

              rx_state        <= S_ERROR;
            
            -- break in the input caused by the master must be propagated to the FEC Engine by setting in_ctrl to PAUSE,
            -- only if we transmit staff which is to be inputted to the Engine (header/payload)
            elsif(wbs_cyc_i = '1' and wbs_stb_i = '0' and (if_in_ctrl = c_FECIN_HEADER or if_in_ctrl = c_FECIN_PAYLOAD)) then
            
              if_in_ctrl      <=c_FECIN_PAUSE;
            
            -- we are done with the input, usually at the end of the transfer three is OOB, so finish the
            elsif(wbs_cyc_i = '0' and wbs_stb_i = '0') then
            
              rx_state         <= S_DONE;
              fec_2_wbs_stall  <= '1';
              --usually at the end of the transfer three is OOB. check and make avalable
              if(wbp_obb_rx = c_WBP_OOB_RECEIVING) then
                 wbp_obb_rx           <= c_WBP_OOB_AVAILABLE;
              end if;
              
              if_in_ctrl       <= c_FECIN_MSG_END;
              
              
            end if;
            
         --=======================================================================================
         when S_BYPASS_FEC => -- bypass FEC, input=output
         --=======================================================================================  
             if(wbs_cyc_i = '0' and wbs_stb_i = '0') then
               -- next state
               rx_state     <= S_IDLE;
               fec_enabled  <='0';
             end if;

         --=======================================================================================
         when S_ERROR => -- error, discard transmission
         --=======================================================================================
             -- if the FEC engine has already "reseted", just go to idle
             if(wbs_cyc_i = '0' and wbs_stb_i = '0' and if_busy_i = '0' and fec_2_wbm_cyc = '0') then

               rx_state         <= S_IDLE;
               fec_enabled      <= '0';
               fec_2_wbs_stall  <= '0';             
               if_in_ctrl       <= c_FECIN_NO_DATA;
             -- in the case the engine is in the process of abandoning fecking, go to DONE (which 
             -- basically waits for FEC Engine to be idle, and set STALL, so there is no 
             -- attempt to write
             elsif(wbs_cyc_i = '0' and wbs_stb_i = '0' and if_busy_i = '1' ) then 
                rx_state         <= S_DONE;
                fec_2_wbs_stall  <= '1';
              end if;

         --=======================================================================================
         when S_DONE => -- entire Ethernet frame received
         --=======================================================================================
             -- as soon as FEC Engine is done, and TX master is not transmitting any more,
             -- the new data can be awaited (in idle state)
             if(if_busy_i = '0' and fec_2_wbm_cyc = '0') then 
                rx_state         <= S_IDLE;
                fec_enabled      <= '0';
                fec_2_wbs_stall  <= '0';
                if_in_ctrl       <= c_FECIN_NO_DATA;
              end if;
         --=======================================================================================
         when others =>
         --=======================================================================================           
 
         --=======================================================================================   
       end case;
        
        
     end if;
   end if;
 end process;
 
   fsm_tx : process(clk_i, rst_n_i)
 
  --------------- variables--------------
  variable oob_cnt  : integer range 0 to c_oob_max_size ;
  begin
   if rising_edge(clk_i) then
     if(rst_n_i = '0') then
     --========================================
     
     -- WB Master
     fec_2_wbm_dat       <= (others =>'0');
     fec_2_wbm_adr  	    <= (others =>'0');
     fec_2_wbm_sel  	    <= (others =>'0');
     fec_2_wbm_cyc  	    <='0';
     fec_2_wbm_stb  	    <='0';
     fec_2_wbm_we  	     <='0';
     
     if_out_ctrl         <='0';
     
     oob_cnt             := 0;
     dummy               <='0';
     
     first_word_out       <= (others =>'0');
     first_bsel_out       <= (others =>'0');
     --========================================
     else
       -- main finite state machine

     
       
       case tx_state is
         --=======================================================================================
         when S_IDLE =>          -- wait for the FEC engine to have message available on the output
         --=======================================================================================  
         
           oob_cnt :=0;
           
           -- no FECking
           if(rx_state  = S_IDLE and wbs_cyc_i             = '1' and 
              wbs_stb_i = '1'    and wbs_adr_i(1 downto 0) = c_WBP_DATA) then
              
              -- next state
              tx_state      <= S_BYPASS_FEC;
              
           -- there is a valid frame on the output of the FEC engine
           elsif(if_out_ctrl_i = '1' and if_out_start_frame_i = '1') then

              fec_2_wbm_stb <= '1';
              fec_2_wbm_cyc <= '1';
              fec_2_wbm_we  <= '1';
              tx_state      <=  S_SEND_FROM_FEC;

              -- we've already received an error message (written to STATUS) address on the
              -- RX Slave 
              if(wbp_status_rx =c_WBP_STATUS_RX_ERR) then
              
                fec_2_wbm_adr <= c_WBP_STATUS;
                fec_2_wbm_dat <= wbp_status_reg;
                fec_2_wbm_sel <= "11";
                tx_state      <=S_DONE;

              -- the input frame came with a Status (we expect the status at the 
              -- beginning of the frame, but should work for general location)
              -- so we need to add status, we always do it at the beginning of the
              -- output frame
              elsif(wbp_status_rx =c_WBP_STATUS_RX_INF) then
                
                fec_2_wbm_dat <= wbp_status_reg;
                fec_2_wbm_adr <= c_WBP_STATUS;
                fec_2_wbm_sel <= "11";
                
                --if_out_ctrl   <='1'; -- cannot receive data   
                -- well, the FEC engine already started outputing data,
                -- so we need to remember it
                dummy         <= '1';
                first_word_out<= if_data_i;
                first_bsel_out<=if_byte_sel_i;
                
              -- we don't need to add any speciall crap to the frame, just
              -- stream put what the FEC is throwing                  
              else
                
                fec_2_wbm_dat <= if_data_i;
                fec_2_wbm_sel <= if_byte_sel_i;
                fec_2_wbm_adr <= c_WBP_DATA;

                if(wbm_stall_i = '0' ) then
                  if_out_ctrl<='0'; -- no problem with receiving data 
                  
                else
                  if_out_ctrl<='1'; -- cannot receive data               
                end if;
                
              end if;
              
           end if;
           
         --=======================================================================================
         when S_SEND_FROM_FEC => -- produce WBp Master stream out of the FEC
         --=======================================================================================  

            if_out_ctrl   <='0';
            fec_2_wbm_adr <= c_WBP_DATA;
            ---------------------------------- controling data transfer --------------------------------------
            
            -- normal case, we just pass data from the FEC Engine to the outputs
            if(if_out_frame_cyc_i = '1' and if_out_ctrl_i ='1' and if_out_ctrl = '0' and wbm_stall_i = '0') then
              fec_2_wbm_dat <= if_data_i;
              fec_2_wbm_sel <= if_byte_sel_i;
              fec_2_wbm_stb <= '1';                
            
            -- we have stall, so we need to stop the FEC Engine output but it will happen in the next 
            -- cycle, so store the currently available data
            elsif(if_out_frame_cyc_i = '1' and if_out_ctrl_i ='1'  and wbm_stall_i = '1' and wbm_ack_i = '1') then
              if_out_ctrl   <='1';
              first_word_out<= if_data_i;
              first_bsel_out<= if_byte_sel_i;
              dummy         <= '1';
            
            -- this is in case of long stall (more then single cycle), we need to pro-long the stop of the FEC
            -- engine output
            elsif(if_out_frame_cyc_i = '1' and if_out_ctrl_i ='1'  and wbm_stall_i = '1' and wbm_ack_i = '0') then              
            
              if_out_ctrl   <='1';
              
            -- so, we had a stall, the fec engine was stopped, we rememberd the data... now we take the data 
            -- not from  FEC output but from the helper register  
            elsif(dummy='1' and wbm_stall_i = '0') then
              dummy         <='0';
              fec_2_wbm_dat <= first_word_out;
              fec_2_wbm_sel <= first_bsel_out;
              fec_2_wbm_stb <= '1';  
            
            -- in the rear case that the engine has no data available.... we need to 
            -- put stall to low  
            elsif(if_out_ctrl_i ='1' and wbm_stall_i = '0') then  
              fec_2_wbm_stb <= '0';           
            end if;
                             
            ------------------------- controlling state machine and FEC engine -------------------------------------
            
            -- error on the output, screw other staff
            if(wbp_status_rx =c_WBP_STATUS_RX_ERR) then
              
                tx_state      <=S_SEND_ERR;
            
            -- we have valid data from the Engine
            elsif(if_out_frame_cyc_i = '1' and if_out_ctrl_i ='1') then 
                
              -- this is the last word of a frame   
              if(if_out_end_of_frame_i = '1') then 
              
                -- by default, assert if_out_ctrl after end_of_frame, we need some
                -- time before starting transfer of a new frame, it could be optimized
                -- by making staff even more complex
                if_out_ctrl<='1';
                
                -- it means the WBp Master needs to keep available the same data
                if((if_out_ctrl = '1' or wbm_stall_i = '1') and if_out_end_of_fec_i = '0') then  
                
                  tx_state       <=S_SEND_EXEPT_FRAME_END; 
                  first_word_out <= if_data_i;
                  first_bsel_out <= if_byte_sel_i;
                  --if_out_ctrl    <='1';
                  
                -- this also means that the WBp Master needs to keep available the same data
                -- but since there is end_of_fec, it needs later to send OOB (if there is any)  
                elsif((if_out_ctrl = '1' or wbm_stall_i = '1') and if_out_end_of_fec_i = '1') then  
                                  
                  tx_state        <=S_SEND_EXEPT_FEC_END;                 
                  first_word_out  <= if_data_i;
                  first_bsel_out  <= if_byte_sel_i;
                  --if_out_ctrl     <='1';
                
                -- more "normal" case, we are at the end of the last frame and we need 
                -- to send OOB                  
                elsif(if_out_end_of_fec_i = '1' and wbp_obb_rx = c_WBP_OOB_AVAILABLE) then 
                  tx_state    <= S_SEND_OOB;
                  oob_cnt :=0;
                  
                -- more "normal" case, we are at the end of the last frame and there is no OOB
                elsif(if_out_end_of_fec_i = '1' and wbp_obb_rx /= c_WBP_OOB_AVAILABLE) then 
                  tx_state    <=S_DONE;
                  
                -- jus a normal end of frame, TODO: more debugging here
                else
                  if(wbm_stall_i = '1') then 
                    tx_state  <= S_WAIT_NEXT_CYC;
                  else
                    tx_state    <= S_SEND_LAST_WORD;--S_NEXT_CYC;
                  end if;
                  
                end if;
              end if;
            end if;

            -- if there is stall, we need to stop the FEC engine...
            if(wbm_stall_i = '1' and if_out_frame_cyc_i = '1' and if_out_end_of_frame_i = '0' and if_out_end_of_fec_i = '0' ) then   
              if_out_ctrl<='1'; -- cannot receive data    
            end if; 

         --=======================================================================================
         when S_SEND_LAST_WORD => -- 
         --=======================================================================================    
         
           -- the last word of a frame, if there is stall, we need to wait
           if(wbm_stall_i = '0') then 
             fec_2_wbm_stb <= '0';
             fec_2_wbm_cyc <= '0';
             fec_2_wbm_we  <= '0';
             if_out_ctrl   <= '0';
             tx_state      <= S_NEXT_CYC;
           end if;
                    
         --=======================================================================================
         when S_SEND_EXEPT_FRAME_END => -- at the very end of the frame (end_of_frame=1) STALL was high
         --=======================================================================================                 
            if(wbm_stall_i = '0') then
              fec_2_wbm_dat <= first_word_out;
              fec_2_wbm_sel <= first_bsel_out;
              fec_2_wbm_stb <= '1';
              tx_state  <= S_SEND_LAST_WORD;
              if_out_ctrl     <='1';
            end if;
            
         --=======================================================================================
         when S_SEND_EXEPT_FEC_END => -- at the very end of the last frame (end_of_fec=1) STALL was high
         --======================================================================================= 
            if(wbm_stall_i = '0') then
              fec_2_wbm_dat <= first_word_out;
              fec_2_wbm_sel <= first_bsel_out;
              fec_2_wbm_stb <= '1';
              if_out_ctrl     <='1';
              if(wbp_obb_rx = c_WBP_OOB_AVAILABLE) then 
                tx_state    <= S_SEND_OOB;
                oob_cnt :=0;
              else
                tx_state    <=S_DONE;
              end if;
              
            end if;
         
         --=======================================================================================
         when S_SEND_OOB =>          -- sending OOB
         --======================================================================================= 
           if_out_ctrl <='1';
           
           
           if(wbm_stall_i = '0') then
             if(oob_cnt < to_integer(unsigned(wbp_oob_cnt))) then 
               fec_2_wbm_dat <= wbp_oob_dat_array(oob_cnt);
               fec_2_wbm_sel <= wbp_oob_sel_array(oob_cnt);
               fec_2_wbm_stb <= '1';   
               oob_cnt       := oob_cnt+1;
               fec_2_wbm_adr <= c_WBP_OOB;
             else
               tx_state      <=S_DONE;
               fec_2_wbm_stb <= '0';
               fec_2_wbm_cyc <= '0';
               fec_2_wbm_we  <= '0';
               if_out_ctrl   <= '0';
               fec_2_wbm_adr <= (others=>'0');
               fec_2_wbm_sel <= (others=>'0');
             end if;
           end if;
           
           
         --=======================================================================================
         when S_SEND_ERR =>    -- error, just finish the transmission by sending error msg in STATUS
         --======================================================================================= 
           
         if(wbm_stall_i = '0') then 

           fec_2_wbm_adr <= c_WBP_STATUS;
           fec_2_wbm_dat <= wbp_status_reg;
           fec_2_wbm_sel <= "11";
           fec_2_wbm_stb <= '1';
           fec_2_wbm_cyc <= '1';
           fec_2_wbm_we  <= '1';
           
           tx_state      <= S_DONE;
         end if;
           
           
         --=======================================================================================
         when S_WAIT_NEXT_CYC =>   -- wait for nexgt cycle... (might be not needed)
         --======================================================================================= 
         if(wbm_stall_i = '0') then 
           fec_2_wbm_stb <= '0';
           fec_2_wbm_cyc <= '0';
           fec_2_wbm_we  <= '0';
           if_out_ctrl   <= '0';
           tx_state      <= S_NEXT_CYC;
         end if;
         
         --=======================================================================================
         when S_NEXT_CYC =>      -- waiting for the transion from the FEC engine of a new frame
         --======================================================================================= 
         fec_2_wbm_stb <= '0';
         fec_2_wbm_cyc <= '0';
         fec_2_wbm_we  <= '0';
         oob_cnt       :=0;
         if(if_out_ctrl_i = '1' and if_out_start_frame_i = '1') then

              fec_2_wbm_stb <= '1';
              fec_2_wbm_cyc <= '1';
              fec_2_wbm_we  <= '1';
              tx_state      <=  S_SEND_FROM_FEC;
              if(wbp_status_rx =c_WBP_STATUS_RX_INF) then
                fec_2_wbm_dat <= wbp_status_reg;
                first_word_out<= if_data_i;
                first_bsel_out<=if_byte_sel_i;
                fec_2_wbm_adr <= c_WBP_STATUS;
                fec_2_wbm_sel <= "11";
                
                if_out_ctrl<='1'; -- cannot receive data   
                dummy         <= '1';
              else
                fec_2_wbm_dat <= if_data_i;
                if(wbm_stall_i = '0' ) then
                  if_out_ctrl<='0'; -- no problem with receiving data 
                else
                  if_out_ctrl<='1'; -- cannot receive data               
                end if;
              end if;
           end if;
           
         --=======================================================================================
         when S_BYPASS_FEC =>    -- bypass FEC, input = output
         --=======================================================================================  
           if(wbs_cyc_i = '0' and wbs_stb_i = '0') then
             -- next state
             tx_state <= S_IDLE;
           end if;
         
         --=======================================================================================
         when S_DONE =>          -- entire Ethernet frame received
         --=======================================================================================
           -- in case the last word in S_SEND_FROM_FEC was stalled
           if(wbm_stall_i = '0') then
             fec_2_wbm_stb <= '0';
             fec_2_wbm_cyc <= '0';
             fec_2_wbm_we  <= '0';
             if_out_ctrl   <= '0';
             fec_2_wbm_dat <= (others=>'0');
             fec_2_wbm_sel <= (others=>'0');
           end if;
           
           if(if_busy_i = '0' and fec_2_wbm_cyc = '0') then 
             tx_state <= S_IDLE;
           end if;
         --=======================================================================================
         when others =>
         --=======================================================================================           
 
         --=======================================================================================   
       end case;
        
        
     end if;
   end if;
 end process;
 
 
end rtl;



