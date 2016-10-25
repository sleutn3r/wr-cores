-------------------------------------------------------------------------------
-- Title      : PCN Module
-- Project    : White Rabbit 
-------------------------------------------------------------------------------
-- File       : pcn_module.vhd
-- Author     : hongming
-- Company    : THU-DEP
-- Created    : 2016-08-30
-- Last update: 2016-08-30
-- Platform   : FPGA-generic
-- Standard   : VHDL '93
-------------------------------------------------------------------------------
-- Description: PCN module measures two PPS input signals using the carry-chain
-- based TDC. 
-------------------------------------------------------------------------------
--
-- Copyright (c) 2016 - 2017 THU / DEP
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gencores_pkg.all;
use work.genram_pkg.all;
use work.wishbone_pkg.all;
use work.pcn_wbgen2_pkg.all;

entity pcn_module is

  generic(
    g_waveunion_enable  : boolean := false;
    g_raw_width        : integer := 8
  );
  port (
    rst_n_i   : in std_logic:='1';
-- 62.5MHz system clock
    clk_sys_i : in std_logic:='0';
-- 125MHz reference clock
    clk_ref_i : in std_logic:='0';
-- 250MHz TDC clock
    clk_tdc_i : in std_logic:='0';

-- signals to be measured
    tdc_insig_i : in std_logic_vector(1 downto 0);
-- the calibration signals (< 62.5MHz)
    tdc_cal_i  : in std_logic;
		
		tdc_fifo_wrreq_o : out std_logic;
		tdc_fifo_wrdata_o: out std_logic_vector(g_raw_width-1 downto 0);
		
-- control & data wishbone interface
    wb_adr_i            : in     std_logic_vector(1 downto 0);
    wb_dat_i            : in     std_logic_vector(31 downto 0);
    wb_dat_o            : out    std_logic_vector(31 downto 0);
    wb_cyc_i            : in     std_logic;
    wb_sel_i            : in     std_logic_vector(3 downto 0);
    wb_stb_i            : in     std_logic;
    wb_we_i             : in     std_logic;
    wb_ack_o            : out    std_logic;
    wb_stall_o          : out    std_logic
  );
end entity ; -- pcn_module

architecture behavioral of pcn_module is

component pcn_wb_slave is
  port (
    clk_sys_i                                : in     std_logic;
    refclk_i                                 : in     std_logic;
    rst_n_i                                  : in     std_logic;
    wb_adr_i                                 : in     std_logic_vector(1 downto 0);
    wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    wb_stall_o                               : out    std_logic;
    regs_i                                   : in     t_pcn_in_registers;
    regs_o                                   : out    t_pcn_out_registers
  );
end component;

component tdc_raw is
  generic(
    -- general
    g_meas_channel_num  : integer := 2;
    g_delaychain_length : integer := 128;
--    g_dualedge_enable   : boolean := c_dualedge_enable;
    g_waveunion_enable  : boolean := true;
    g_raw_width         : integer := 8
  );
  port(
    clk_sys_i           : in  std_logic;   -- 62.5MHz system clock
    clk_ref_i           : in  std_logic;   -- 125MHz reference clock
    clk_tdc_i           : in  std_logic;   -- 250MHz clock
    rst_n_i             : in  std_logic;   -- set '0' to reset

    tdc_cal_i           : in  std_logic:='0'; -- calibration signal input
    tdc_insig_i         : in  std_logic_vector(g_meas_channel_num-1 downto 0); -- signal to be measured
		
    -- tdc data fifo output
    raw_output_wrreq_o   : out std_logic_vector(g_meas_channel_num-1 downto 0);
    raw_output_data_o    : out std_logic_vector(g_raw_width*g_meas_channel_num-1 downto 0);
    raw_output_edgepol_o : out std_logic_vector(g_meas_channel_num-1 downto 0);	

	  -- enable each channel 
    tdc_en_i            : in  std_logic_vector(g_meas_channel_num-1 downto 0):=(others=>'0');
    -- select the calibration or measured signal
    tdc_cal_sel_i       : in  std_logic_vector(g_meas_channel_num-1 downto 0):=(others=>'0')
  );
end component;

-- signals declaration
signal fifo_select : std_logic_vector(1 downto 0);

signal pcn_wb_regs_in : t_pcn_in_registers;
signal pcn_wb_regs_out : t_pcn_out_registers;

    -- tdc data fifo output
signal raw_output_wrreq   : std_logic_vector(2-1 downto 0);
signal raw_output_data    : std_logic_vector(g_raw_width*2-1 downto 0);
signal raw_output_edgepol : std_logic_vector(2-1 downto 0);	

signal tdc_rst_n           : std_logic;
signal tdc_en              : std_logic_vector(1 downto 0):=(others=>'0');
signal tdc_cal_sel         : std_logic_vector(1 downto 0):=(others=>'0'); 

begin
	
  u_pcn_wb_slave : pcn_wb_slave
  port map(
    rst_n_i   => rst_n_i,
    clk_sys_i => clk_sys_i,
    refclk_i  => clk_ref_i,
    wb_adr_i  => wb_adr_i,
    wb_dat_i  => wb_dat_i,
    wb_dat_o  => wb_dat_o,
    wb_cyc_i  => wb_cyc_i,
    wb_sel_i  => wb_sel_i,
    wb_stb_i  => wb_stb_i,
    wb_we_i   => wb_we_i,
    wb_ack_o  => wb_ack_o,
    wb_stall_o=> wb_stall_o,
    regs_i    => pcn_wb_regs_in,
    regs_o    => pcn_wb_regs_out
  );

u_tdc_module : tdc_raw
  generic map(
-- general
    g_meas_channel_num  => 2,
    g_delaychain_length => 128,
    g_waveunion_enable  => g_waveunion_enable,
    g_raw_width         => g_raw_width
  )
  port map(
    rst_n_i             => tdc_rst_n,
    clk_sys_i           => clk_sys_i,
    clk_ref_i           => clk_ref_i,
    clk_tdc_i           => clk_tdc_i,

    tdc_insig_i         => tdc_insig_i,
    tdc_cal_i           => tdc_cal_i,
		
    raw_output_wrreq_o   => raw_output_wrreq,
    raw_output_data_o    => raw_output_data,
    raw_output_edgepol_o => open,

    tdc_en_i            => tdc_en,
    tdc_cal_sel_i       => tdc_cal_sel
  );
	
	tdc_fifo_wrreq_o <= raw_output_wrreq(0) when tdc_en = "01" else
	                    raw_output_wrreq(1) when tdc_en = "10" else
											'0';
	tdc_fifo_wrdata_o <= raw_output_data(g_raw_width-1 downto 0) when tdc_en = "01" else
	                     raw_output_data(2*g_raw_width-1 downto g_raw_width) when tdc_en = "10" else
											(others=>'0');
											
  pcn_wb_regs_in.fifo_wr_req_i  <= '0';
  pcn_wb_regs_in.fifo_wr_data_i <= (others=>'0');
  pcn_wb_regs_in.sr_dnl_done_i  <= (others=>'0');
  pcn_wb_regs_in.sr_lut_done_i  <= (others=>'0');
  
  tdc_rst_n        <= not pcn_wb_regs_out.cr_rst_o;
  tdc_en           <= pcn_wb_regs_out.cr_en_o;
  tdc_cal_sel      <= pcn_wb_regs_out.cr_cal_sel_o;

end architecture ; -- behavioral
