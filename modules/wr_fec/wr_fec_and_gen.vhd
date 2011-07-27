------------------------------------------------------------------------
-- Title      : Forward Error Correction
-- Project    : WhiteRabbit Node
-------------------------------------------------------------------------------
-- File       : wr_fec_and_gen.vhd
-- Author     : Maciej Lipinski
-- Company    : CERN BE-Co-HT
-- Created    : 2011-07-24
-- Last update: 2011-07-24
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
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
-- 2011-07-24 1.0      mlipinsk Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wr_fec_pkg.all;

entity wr_fec_and_gen is
  port (
     clk_i   : in std_logic;
     rst_n_i : in std_logic;
    
     ---------------------------------------------------------------------------------------
     -- talk with outside word
     ---------------------------------------------------------------------------------------
     -- 32 bits wide wishbone Master TX input
      
     wbm_dat_o 	: out std_logic_vector(wishbone_data_width_out-1 downto 0);
     wbm_adr_o	 : out std_logic_vector(wishbone_address_width_out-1 downto 0);
     wbm_sel_o	 : out std_logic_vector((wishbone_data_width_out/8)-1 downto 0);
     wbm_cyc_o	 : out std_logic;
     wbm_stb_o	 : out std_logic;
     wbm_we_o	  : out std_logic;
     wbm_err_i	 : in std_logic;
     wbm_stall_i: in  std_logic;
     wbm_ack_i	 : in  std_logic;
     
     -- control generator
     wb_clk_i   : in     std_logic;
     wb_addr_i  : in     std_logic_vector(2 downto 0);
     wb_data_i  : in     std_logic_vector(31 downto 0);
     wb_data_o  : out    std_logic_vector(31 downto 0);
     wb_cyc_i   : in     std_logic;
     wb_sel_i   : in     std_logic_vector(3 downto 0);
     wb_stb_i   : in     std_logic;
     wb_we_i    : in     std_logic;
     wb_ack_o   : out    std_logic     
  );
end wr_fec_and_gen;

architecture rtl of wr_fec_and_gen is

  signal wbm_dat 	: std_logic_vector(wishbone_data_width_out-1 downto 0);
  signal wbm_adr	 : std_logic_vector(wishbone_address_width_out-1 downto 0);
  signal wbm_sel	 : std_logic_vector((wishbone_data_width_in/8)-1 downto 0);
  signal wbm_cyc	 : std_logic;
  signal wbm_stb	 : std_logic;
  signal wbm_we	  : std_logic;
  signal wbm_err	 : std_logic;
  signal wbm_stall: std_logic;
  signal wbm_ack	 : std_logic; 


begin
  
  FEC: wr_fec_en 
    port map (
       clk_i      => clk_i,
       rst_n_i    => rst_n_i,
      
       ---------------------------------------------------------------------------------------
       -- talk with outside word
       ---------------------------------------------------------------------------------------
       -- 32 bits wide wishbone slave RX input
       wbs_dat_i	 => wbm_dat,
       wbs_adr_i	 => wbm_adr,
       wbs_sel_i	 => wbm_sel,
       wbs_cyc_i	 => wbm_cyc,
       wbs_stb_i	 => wbm_stb,
       wbs_we_i	  => wbm_we,
       wbs_err_o	 => wbm_err,
       wbs_stall_o=> wbm_stall,
       wbs_ack_o	 => wbm_ack,
      
       -- 32 bits wide wishbone Master TX input
        
       wbm_dat_o 	=> wbm_dat_o,
       wbm_adr_o	 => wbm_adr_o,
       wbm_sel_o	 => wbm_sel_o,
       wbm_cyc_o	 => wbm_cyc_o,
       wbm_stb_o	 => wbm_stb_o,
       wbm_we_o	  => wbm_we_o,
       wbm_err_i	 => wbm_err_i,
       wbm_stall_i=> wbm_stall_i,
       wbm_ack_i	 => wbm_ack_i
    );  

    
  GEN: wr_fec_dummy_pck_gen
    port map(
       clk_i      => clk_i,
       rst_n_i    => rst_n_i,
      
       ---------------------------------------------------------------------------------------
       -- talk with outside word
       ---------------------------------------------------------------------------------------
  
      
       -- 32 bits wide wishbone Master TX input
        
       wbm_dat_o 	=> wbm_dat,
       wbm_adr_o	 => wbm_adr,
       wbm_sel_o	 => wbm_sel,
       wbm_cyc_o	 => wbm_cyc,
       wbm_stb_o	 => wbm_stb,
       wbm_we_o	  => wbm_we,
       wbm_err_i	 => wbm_err,
       wbm_stall_i=> wbm_stall,
       wbm_ack_i	 => wbm_ack,
       
       ---------------------------------------------------------------------------------------
       -- ctrl_regs -> to be controlled by WB
       ---------------------------------------------------------------------------------------
       
       wb_clk_i   => wb_clk_i,
       wb_addr_i  => wb_addr_i,
       wb_data_i  => wb_data_i,
       wb_data_o  => wb_data_o,
       wb_cyc_i   => wb_cyc_i,
       wb_sel_i   => wb_sel_i,
       wb_stb_i   => wb_stb_i,
       wb_we_i    => wb_we_i,
       wb_ack_o   => wb_ack_o
         ); 
  
   
end rtl;



