------------------------------------------------------------------------
-- Title      : Forward Error Correction
-- Project    : WhiteRabbit Node
-------------------------------------------------------------------------------
-- File       : wr_fec_de_interface.vhd
-- Author     : Maciej Lipinski
-- Company    : CERN BE-Co-HT
-- Created    : 2011-07-15
-- Last update: 2011-07-27
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: not even started 
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
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wr_fec_pkg.all;
use work.genram_pkg.all; -- wrappers for RAM/FIFO by Tomek




entity wr_fec_de_interface is
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
end wr_fec_de_interface;

architecture rtl of wr_fec_de_interface is

--TODO

begin

--TODO
 
end rtl;



