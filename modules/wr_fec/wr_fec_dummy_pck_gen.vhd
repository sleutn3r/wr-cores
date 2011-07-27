------------------------------------------------------------------------
-- Title      : Forward Error Correction
-- Project    : WhiteRabbit Node
-------------------------------------------------------------------------------
-- File       : wr_fec_dummy_pck_gen.vhd
-- Author     : Maciej Lipinski
-- Company    : CERN BE-Co-HT
-- Created    : 2011-07-22
-- Last update: 2011-07-22
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: this is a dummy ethernet frame generator with WB pipelined 
-- output and WB control registers.
-- It is meant to feed FEC Encoder with dummy frames of known content and 
-- payload's length. It's solely for testing purpose.
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




entity wr_fec_dummy_pck_gen is
  port (
     clk_i   : in std_logic;
     rst_n_i : in std_logic;
    
     ---------------------------------------------------------------------------------------
     -- talk with outside word
     ---------------------------------------------------------------------------------------

    
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
     -- ctrl_regs -> to be controlled by WB
     ---------------------------------------------------------------------------------------
     
       wb_clk_i                                 : in     std_logic;
       wb_addr_i                                : in     std_logic_vector(2 downto 0);
       wb_data_i                                : in     std_logic_vector(31 downto 0);
       wb_data_o                                : out    std_logic_vector(31 downto 0);
       wb_cyc_i                                 : in     std_logic;
       wb_sel_i                                 : in     std_logic_vector(3 downto 0);
       wb_stb_i                                 : in     std_logic;
       wb_we_i                                  : in     std_logic;
       wb_ack_o                                 : out    std_logic
     
     -- the size of the payload we wnat to have in the generated frame
     -- if we do increment the size, this is the starting size
     --payload_size_i    : in std_logic_vector(15 downto 0);
     
     -- we can increment the size of the generated frame each time, this is th
     -- incremental step
     --increment_size_i  : in std_logic_vector(8  downto 0);
     
     -- how many frames should we generated in one go
     -- gen_frame_number_i: in std_logic_vector(15 downto 0);
     
     -- control register: 
     -- * [0] start 
     -- * [1] stop
     -- * [2] fec/non
     -- * [3] single/continuous
     -- * [4] vlan-tagged
     --ctrl_reg_i          : in std_logic_vector(8  downto 0);
     
     -- status register
     -- * [0] running 
     -- * [1] done 
     -- * [2] fec/non
     -- * [3] single/continuous
     -- * [4] vlan-tagged
     -- * [5] error              
     --stat_reg_o          : out std_logic_vector(8  downto 0)
     
  );
end wr_fec_dummy_pck_gen;

architecture rtl of wr_fec_dummy_pck_gen is

-- the size of the payload we wnat to have in the generated frame
-- if we do increment the size, this is the starting size
signal payload_size_i         : std_logic_vector(15 downto 0);

-- we can increment the size of the generated frame each time, this is th
-- incremental step
signal increment_size_i       : std_logic_vector(7  downto 0);

-- how many frames should we generated in one go
signal gen_frame_number_i     : std_logic_vector(15 downto 0);

-- control register: 
-- * [0] start 
-- * [1] stop
-- * [2] fec/non
-- * [3] single/continuous
-- * [4] vlan-tagged
signal ctrl_reg_i             : std_logic_vector(7  downto 0);

-- status register
-- * [0] running 
-- * [1] done 
-- * [2] fec/non
-- * [3] single/continuous
-- * [4] vlan-tagged
-- * [5] error
          
signal stat_reg_o            : std_logic_vector(15  downto 0);

signal payload_size          : std_logic_vector(15 downto 0);
signal increment_size        : std_logic_vector(7  downto 0);
signal gen_frame_number      : std_logic_vector(15 downto 0);
signal ctrl_reg              : std_logic_vector(7  downto 0);

signal stat_reg              : std_logic_vector(7  downto 0);

signal payload_current_size  : std_logic_vector(15 downto 0);

signal msg_size_cnt          : std_logic_vector(15 downto 0);
signal msg_cnt               : std_logic_vector(15 downto 0);
-- signals to control WBp Master
signal wbm_dat              	: std_logic_vector(wishbone_data_width_out-1 downto 0);
signal wbm_adr             	 : std_logic_vector(wishbone_address_width_out-1 downto 0);
signal wbm_sel             	 : std_logic_vector((wishbone_data_width_out/8)-1 downto 0);
signal wbm_cyc  	            : std_logic;
signal wbm_stb  	            : std_logic;
signal wbm_we  	             : std_logic;


-- WBp Master
type t_tx_state is (
      S_IDLE,                -- doing nothing
      S_SEND_WBP_FEC,        -- sending size of payload to WBP_FEC address to indicate the FECing should be done
      S_SEND_HEADER,         -- sending ethernet header
      S_SEND_PAYLOAD,        -- sending the payload
      S_NEXT_FRAME,          -- checking whether to send another frame, incrementing parameters, etc
      S_ERROR,               -- upssss
      S_DONE                 -- work done, wait for the process to be stopped
      );  

signal tx_state             : t_tx_state;


   begin
   
WB_IF: wr_fec_dummy_pck_gen_if
port map(
  rst_n_i                                 =>rst_n_i,
  wb_clk_i                                =>clk_i,
  wb_addr_i                               =>wb_addr_i,
  wb_data_i                               =>wb_data_i,
  wb_data_o                               =>wb_data_o,
  wb_cyc_i                                =>wb_cyc_i,
  wb_sel_i                                =>wb_sel_i,
  wb_stb_i                                =>wb_stb_i,
  wb_we_i                                 =>wb_we_i,
  wb_ack_o                                =>wb_ack_o,
  clk_i                                   =>clk_i,
  wr_fec_dummy_pck_gen_payload_size_o     =>payload_size_i ,
  wr_fec_dummy_pck_gen_increment_size_o   =>increment_size_i,
  wr_fec_dummy_pck_gen_gen_frame_number_o =>gen_frame_number_i, 
  wr_fec_dummy_pck_gen_ctrl_start_o       =>ctrl_reg_i(0), 
  wr_fec_dummy_pck_gen_ctrl_stop_o        =>ctrl_reg_i(1), 
  wr_fec_dummy_pck_gen_ctrl_fec_o         =>ctrl_reg_i(2), 
  wr_fec_dummy_pck_gen_ctrl_continuous_o  =>ctrl_reg_i(3),
  wr_fec_dummy_pck_gen_ctrl_vlan_o        =>ctrl_reg_i(4), 
  wr_fec_dummy_pck_gen_status_i           =>stat_reg_o 
);

  ctrl_reg_i(7 downto 5) <=(others=>'0');

  -- WB MUX
  wbm_dat_o 	<= wbm_dat;
  wbm_adr_o	 <= wbm_adr;
  wbm_sel_o	 <= wbm_sel;
  wbm_cyc_o	 <= wbm_cyc;
  wbm_stb_o	 <= wbm_stb;
  wbm_we_o	  <= wbm_we;

  stat_reg_o(15 downto 8) <= x"EB";   -- magic number
  stat_reg_o(7  downto 0) <= stat_reg;
 
  fsm_tx : process(clk_i, rst_n_i)
 
  --------------- variables--------------
  variable oob_cnt  : integer range 0 to c_oob_max_size ;
  begin
   if rising_edge(clk_i) then
     if(rst_n_i = '0') then
     --========================================
     
     -- WB Master
     wbm_dat              <= (others =>'0');
     wbm_adr  	           <= (others =>'0');
     wbm_sel  	           <= (others =>'0');
     wbm_cyc  	           <='0';
     wbm_stb  	           <='0';
     wbm_we  	            <='0';
     
     msg_size_cnt         <= (others =>'0');     
     msg_cnt              <= (others =>'0');     
      
     ctrl_reg             <= (others =>'0');
     payload_current_size <= (others =>'0');
     payload_size         <= (others =>'0');
     increment_size       <= (others =>'0');
     gen_frame_number     <= (others =>'0');
     stat_reg             <= (others =>'0');
     --========================================
     else
       -- main finite state machine

     
       
       case tx_state is
         --=======================================================================================
         when S_IDLE =>          -- 
         --=======================================================================================  
         
         stat_reg               <= (others => '0');
         msg_cnt                <= (others => '0');
         -- start
         if(ctrl_reg_i(0) = '1') then 

           --remember the input settings:
           ctrl_reg             <= ctrl_reg_i;
           payload_current_size <= payload_size_i;
           payload_size         <= payload_size_i;
           increment_size       <= increment_size_i;
           gen_frame_number     <= gen_frame_number_i;
           
           stat_reg(0)          <= '1';
           
           -- send frame to be FECed 
           if(ctrl_reg_i(2) = '1') then 
            
             tx_state      <= S_SEND_WBP_FEC;
           
           else -- no FECing  
             
             tx_state      <= S_SEND_HEADER;
             
           end if;
         end if;
           
         --=======================================================================================
         when S_SEND_WBP_FEC =>         
         --=======================================================================================  
         
           if(wbm_stall_i = '0') then 
           
             wbm_stb       <= '1';
             wbm_cyc       <= '1';
             wbm_we        <= '1';
             wbm_sel       <= "11";
             wbm_adr       <= c_WBP_FEC;
             wbm_dat       <= payload_size;
                                     
             tx_state      <= S_SEND_HEADER;
           end if;
            
          
         --=======================================================================================
         when S_SEND_HEADER => -- 
         --=======================================================================================  
           
           wbm_cyc       <= '1';
           wbm_we        <= '1';
           wbm_sel       <= "11";
           wbm_adr       <= c_WBP_DATA;

           if(wbm_stall_i = '0') then 
           
             wbm_stb       <= '1';             
             msg_size_cnt  <= std_logic_vector(unsigned(msg_size_cnt) + 1);      
             
             case msg_size_cnt(3 downto 0) is
               when x"0" => wbm_dat <= c_eth_header_dst_addr(15 downto 0);
               when x"1" => wbm_dat <= c_eth_header_dst_addr(31 downto 16);
               when x"2" => wbm_dat <= c_eth_header_dst_addr(47 downto 32);
               when x"3" => wbm_dat <= c_eth_header_src_addr(15 downto 0);
               when x"4" => wbm_dat <= c_eth_header_src_addr(31 downto 16);
               when x"5" => wbm_dat <= c_eth_header_src_addr(47 downto 32);
               when x"6" => 
                            if(ctrl_reg(4) = '0') then
                              wbm_dat            <= c_fec_header_etherType;
                              tx_state           <= S_SEND_PAYLOAD;
                              msg_size_cnt       <= (others =>'0'); 
                            else
                              wbm_dat            <= c_VLAN_ETHERTYPE;
                            end if;
               when x"7" => wbm_dat(2  downto 0) <= c_vlan_priority;
                            wbm_dat(3)           <= '0'; 
                            wbm_dat(15 downto 4) <= c_vlan_identifier;
               when x"8" => wbm_dat              <= c_VLAN_ETHERTYPE;
                            tx_state             <= S_SEND_PAYLOAD;
                            msg_size_cnt         <= (others =>'0');                                                
               when others => assert false report "ERROR: input case, default";  
                            tx_state             <= S_ERROR;
                            wbm_cyc              <= '0';
                            wbm_we               <= '0';
                            wbm_stb              <= '0';
             end case;

           end if;

         --=======================================================================================
         when S_SEND_PAYLOAD => -- 
         --=======================================================================================    
           
           if(wbm_stall_i = '0') then 
             
             if(msg_size_cnt(15 downto 0) = payload_current_size(15 downto 0)) then -- finished
             
               tx_state            <= S_NEXT_FRAME;
               
               -- the size of the next msg's payload
               payload_current_size  <= std_logic_vector(unsigned(payload_current_size) + unsigned(increment_size));
               -- the number of sent msgs
               msg_cnt               <= std_logic_vector(unsigned(msg_cnt) + 1);  
               
               if(payload_current_size(0) = '1') then
                 wbm_stb             <= '1';
                 wbm_sel             <= "10";
                 wbm_dat(15 downto 8)<= (others => '0');
                 wbm_dat( 7 downto 0)<= msg_size_cnt(8 downto 1);
               else
                 wbm_stb             <= '0';
                 wbm_sel             <= "00";
                 wbm_cyc             <= '0';
                 wbm_we              <= '0';
               end if;
             else -- sending payload
               
               wbm_dat       <= '0' & msg_size_cnt(15 downto 1);
               wbm_stb       <= '1';
             
               msg_size_cnt  <= std_logic_vector(unsigned(msg_size_cnt) + 2);             
               
             end if;
             
           end if;
         
         --=======================================================================================
         when S_NEXT_FRAME =>      -- waiting for the transion from the FEC engine of a new frame
         --======================================================================================= 
         msg_size_cnt          <= (others =>'0');
         
         if((wbm_stb = '1' and wbm_stall_i = '0') or  wbm_stb = '0') then
           
           wbm_dat             <= (others => '0');
           wbm_stb             <= '0';
           wbm_sel             <= "00";
           wbm_cyc             <= '0';
           wbm_we              <= '0';
           
           -- sending single message/frame
           if(unsigned(msg_cnt)      = unsigned(c_zeros)  and 
              unsigned(msg_size_cnt) = unsigned(c_zeros)) then
             
             tx_state          <= S_DONE;
             stat_reg(0)       <= '0';
             stat_reg(1)       <= '1';
             
            -- sending many frames but only one cycle
            elsif(unsigned(msg_cnt)      < unsigned(gen_frame_number) and 
                  unsigned(msg_size_cnt) < unsigned(c_fec_input_payload_max_size)) then
                
                if(ctrl_reg_i(2) = '1') then 
                 
                  tx_state      <= S_SEND_WBP_FEC;
                
                else -- no FECing  
                  
                  tx_state      <= S_SEND_HEADER;
                  
                end if;
                
             else
               
               -- sending many frames but only one cycle
               if(ctrl_reg(3) = '0') then 
                 tx_state             <= S_DONE;
                 stat_reg(0)          <= '0';
                 stat_reg(1)          <= '1';
               else
                 payload_current_size <= payload_size;
                 msg_cnt              <= (others =>'0');
                 tx_state             <= S_SEND_HEADER;
               end if;
               
             end if; 
           end if;
         --=======================================================================================
         when S_ERROR =>    -- error, just finish the transmission by sending error msg in STATUS
         --======================================================================================= 
           
           stat_reg(5)     <= '1';
           
           if(ctrl_reg_i(1) = '1') then
             tx_state      <= S_IDLE;
             stat_reg(5)   <= '0';
           end if;
         
         --=======================================================================================
         when S_DONE =>          -- entire Ethernet frame received
         --=======================================================================================
           
           stat_reg(1)     <= '1';
           
           if(ctrl_reg_i(1) = '1') then
             tx_state      <= S_IDLE;
             stat_reg(1)   <= '0';
           end if;
         
         --=======================================================================================
         when others =>
         --=======================================================================================           
           tx_state            <= S_ERROR;
           wbm_dat             <= (others => '0');
           wbm_stb             <= '0';
           wbm_sel             <= "00";
           wbm_cyc             <= '0';
           wbm_we              <= '0';
         --=======================================================================================   
       end case;
        
        
     end if;
   end if;
 end process;
 
 
end rtl;



