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
	    g_meas_channel_num  : integer := 2;
      g_timestamp_width   : integer := 40
	  );
  port (
    rst_n_i   : in std_logic:='1';
-- 62.5MHz system clock
    clk_sys_i : in std_logic:='0';
-- 125MHz reference clock
    clk_ref_i : in std_logic:='0';
-- 250MHz TDC clock
    clk_tdc_i : in std_logic:='0';

--  pps input
    pps_i               : in  std_logic:='0';
-- signals to be measured
    tdc_insig_i : in std_logic_vector(g_meas_channel_num-1 downto 0);
-- the calibration signals (< 62.5MHz)
    tdc_cal_i  : in std_logic;
		
    tdc_fifo_wrreq_o : out std_logic_vector(g_meas_channel_num-1 downto 0);
    tdc_fifo_wrdata_o: out std_logic_vector(g_meas_channel_num*g_timestamp_width-1 downto 0);
		
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
    wb_adr_i                                 : in     std_logic_vector(0 downto 0);
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

component tdc_module is
  generic(
    -- general
    g_meas_channel_num  : integer := 2;
    g_delaychain_length : integer := 128;  -- 7bit
--    g_dualedge_enable   : boolean := c_dualedge_enable;
    g_waveunion_enable  : boolean := false;
    -- timestamp data width = g_coarsecntr_width + g_fine_width
    g_timestamp_width   : integer := 40;
    g_coarsecntr_width  : integer := 32;    -- must be multiple of 8
    g_fine_width        : integer := 8;
    -- calibration count
    g_calib_cnt         : integer := 24;  -- 2**23 
		-- dnl data width = addr_width + data_width
    g_dnl_width         : integer := 32;
    g_dnl_addr_width    : integer := 8;
    g_dnl_data_width    : integer := 24
  );
  port(
    clk_sys_i           : in  std_logic;   -- 62.5MHz system clock
    clk_ref_i           : in  std_logic;   -- 125MHz reference clock
    clk_tdc_i           : in  std_logic;   -- 250MHz clock
    rst_n_i             : in  std_logic;   -- set '0' to reset

    pps_i               : in  std_logic:='0';
    tdc_cal_i           : in  std_logic:='0'; -- calibration signal input
    tdc_insig_i         : in  std_logic_vector(g_meas_channel_num-1 downto 0); -- signal to be measured
		
    -- timestamps data fifo output
    tdc_meas_en_i       : in std_logic_vector(g_meas_channel_num-1 downto 0);
    tm_output_wrreq_o   : out std_logic_vector(g_meas_channel_num-1 downto 0);
    tm_output_data_o    : out std_logic_vector(g_timestamp_width*g_meas_channel_num-1 downto 0);
    tm_output_edgepol_o : out std_logic_vector(g_meas_channel_num-1 downto 0);	
    
    -- calibration dnl data fifo output
    tdc_cali_en_i       : in std_logic_vector(g_meas_channel_num-1 downto 0);
    tdc_lut_build_i     : in std_logic_vector(g_meas_channel_num-1 downto 0);
    tdc_lut_done_o      : out std_logic_vector(g_meas_channel_num-1 downto 0);
    tdc_dnl_done_o      : out std_logic_vector(g_meas_channel_num-1 downto 0);
    dnl_output_req_i    : in std_logic_vector(g_meas_channel_num-1 downto 0);
    dnl_output_stall_i  : in std_logic_vector(g_meas_channel_num-1 downto 0);
    dnl_output_wrreq_o  : out std_logic_vector(g_meas_channel_num-1 downto 0);
    dnl_output_data_o   : out std_logic_vector(g_dnl_width*g_meas_channel_num-1 downto 0)
  );
end component;

signal pcn_wb_regs_in : t_pcn_in_registers;
signal pcn_wb_regs_out : t_pcn_out_registers;

signal tdc_rst_n           : std_logic;
signal tdc_en              : std_logic_vector(1 downto 0):=(others=>'0');
signal tdc_cal_sel         : std_logic_vector(1 downto 0):=(others=>'0'); 

signal tdc_meas_en_i       : std_logic_vector(g_meas_channel_num-1 downto 0);
signal tm_output_wrreq_o   : std_logic_vector(g_meas_channel_num-1 downto 0);
signal tm_output_data_o    : std_logic_vector(g_timestamp_width*g_meas_channel_num-1 downto 0);
signal tm_output_edgepol_o : std_logic_vector(g_meas_channel_num-1 downto 0);	
    
signal tdc_cali_en_i       : std_logic_vector(g_meas_channel_num-1 downto 0);
signal tdc_lut_build_i     : std_logic_vector(g_meas_channel_num-1 downto 0);
signal tdc_lut_done_o      : std_logic_vector(g_meas_channel_num-1 downto 0);
signal tdc_dnl_done_o      : std_logic_vector(g_meas_channel_num-1 downto 0);
signal dnl_output_req_i    : std_logic_vector(g_meas_channel_num-1 downto 0);
signal dnl_output_stall_i  : std_logic_vector(g_meas_channel_num-1 downto 0);
signal dnl_output_wrreq_o  : std_logic_vector(g_meas_channel_num-1 downto 0);
signal dnl_output_data_o   : std_logic_vector(32*g_meas_channel_num-1 downto 0);

begin
	
  u_pcn_wb_slave : pcn_wb_slave
  port map(
    rst_n_i   => rst_n_i,
    clk_sys_i => clk_sys_i,
    refclk_i  => clk_ref_i,
    wb_adr_i  => wb_adr_i(0 downto 0),
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

u_tdc_module : tdc_module
  port map(
    rst_n_i             => tdc_rst_n,
    clk_sys_i           => clk_sys_i,
    clk_ref_i           => clk_ref_i,
    clk_tdc_i           => clk_tdc_i,
     
    pps_i               => pps_i,
    tdc_insig_i         => tdc_insig_i,
    tdc_cal_i           => tdc_cal_i,
		
    tdc_meas_en_i       => tdc_meas_en_i,
    tm_output_wrreq_o   => tm_output_wrreq_o,
    tm_output_data_o    => tm_output_data_o,
    tm_output_edgepol_o => open,
		
    tdc_cali_en_i       => tdc_cali_en_i,
    tdc_lut_build_i     => tdc_lut_build_i,
    tdc_lut_done_o      => tdc_lut_done_o,
    tdc_dnl_done_o      => tdc_dnl_done_o,
    dnl_output_req_i    => dnl_output_req_i,
    dnl_output_stall_i  => dnl_output_stall_i,
    dnl_output_wrreq_o  => dnl_output_wrreq_o,
    dnl_output_data_o   => dnl_output_data_o
  );
	
  --tdc_fifo_wrreq_o <= dnl_output_wrreq_o(0);
  --tdc_fifo_wrdata_o <= dnl_output_data_o(31 downto 0);
	tdc_fifo_wrreq_o <= tm_output_wrreq_o;
  tdc_fifo_wrdata_o <= tm_output_data_o;

  --pcn_wb_regs_in.fifo_wr_req_i  <= dnl_output_wrreq_o(0);
  --pcn_wb_regs_in.fifo_wr_data_i <= dnl_output_data_o(31 downto 0);
  pcn_wb_regs_in.sr_dnl_done_i  <= tdc_dnl_done_o;
  pcn_wb_regs_in.sr_lut_done_i  <= tdc_lut_done_o;
  
  tdc_rst_n        <= not pcn_wb_regs_out.cr_rst_o;
  tdc_cali_en_i    <= pcn_wb_regs_out.cr_cali_en_o;
  tdc_meas_en_i    <= pcn_wb_regs_out.cr_meas_en_o;

  tdc_lut_build_i(0)  <= pcn_wb_regs_out.cr_lut_build_o;
  tdc_lut_build_i(1)  <= pcn_wb_regs_out.cr_lut_build_o;
  dnl_output_req_i(0) <= pcn_wb_regs_out.cr_dnl_req_o;
  dnl_output_req_i(1) <= pcn_wb_regs_out.cr_dnl_req_o;

end architecture ; -- behavioral
