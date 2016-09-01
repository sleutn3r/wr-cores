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
-- fifo data width
    g_data_width : natural := 32;
-- coincidence window, 16 ns * ( 2^g_windows_width -1 )
    g_window_width : natural := 10;
-- diff data width
    g_diff_width : natural := 16;
--    g_dualedge_enable   : boolean := c_dualedge_enable;
    g_waveunion_enable  : boolean := true;
--    g_correction_enable : boolean := c_correction_enable;
    g_hit_cnt           : integer := 65536;
    -- timestamp data width = g_coarsecntr_width + g_fine_width
    g_timestamp_width   : integer := 32;
    g_coarsecntr_width  : integer := 24;    -- must be multiple of 8
    g_fine_width        : integer := 8;
    -- dnl data width = addr_width + data_width
    g_dnl_width         : integer := 32;
    g_dnl_addr_width    : integer := 8;
    g_dnl_data_width    : integer := 24
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
-- utc time coming from wrpc
    utc_i               : in  std_logic_vector(39 downto 0):=(others=>'0'); -- time (>1s)
-- pps signal coming from wrpc
    pps_i               : in  std_logic;  -- pps input
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

-- component declaration
  component pcn_coincidence is

  generic(
-- clock frequency
    g_clk_freq : natural := 62500000;
-- fifo data width
    g_data_width : natural := 32;
-- coincidence window, 16 ns * ( 2^g_windows_width -1 )
    g_window_width : natural := 10;
-- diff data width
    g_diff_width : natural := 18
   );
  port (
    rst_n_i	  : in std_logic:='0';
    clk_sys_i : in std_logic:='0';
    
    fifoa_empty_i : in std_logic:='0';
    fifoa_rd_o    : out std_logic;
    fifoa_data_i  : in  std_logic_vector(g_data_width-1 downto 0):=(others=>'0');
    
    fifob_empty_i : in std_logic:='0';
    fifob_rd_o    : out std_logic;
    fifob_data_i  : in  std_logic_vector(g_data_width-1 downto 0):=(others=>'0');

    diff_fifo_wr_o   : out std_logic;
    diff_fifo_data_o : out std_logic_vector(g_diff_width downto 0);
    diff_fifo_full_i : in std_logic:='0'
  );

end component;

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

component tdc_module is
  generic(
    -- general
    g_meas_channel_num  : integer := 2;
    g_delaychain_length : integer := 128;
--    g_dualedge_enable   : boolean := c_dualedge_enable;
    g_waveunion_enable  : boolean := true;
--    g_correction_enable : boolean := c_correction_enable;
    g_hit_cnt           : integer := 65536;
    -- timestamp data width = g_coarsecntr_width + g_fine_width
    g_timestamp_width   : integer := 32;
    g_coarsecntr_width  : integer := 24;    -- must be multiple of 8
    g_fine_width        : integer := 8;
    -- dnl data width
    g_dnl_width         : integer := 32;
    g_dnl_addr_width    : integer := 8;
    g_dnl_data_width    : integer := 24
    -- correction channel output
    --g_corr_output_enable: boolean  := c_corr_output_enable;
    --g_corr_output_content: string  := c_corr_output_content
  );
  port(
    clk_sys_i           : in  std_logic;   -- 62.5MHz system clock
    clk_ref_i           : in  std_logic;   -- 125MHz reference clock
    clk_tdc_i           : in  std_logic;   -- 250MHz clock
    rst_n_i             : in  std_logic;   -- set '0' to reset

    tdc_cal_i           : in  std_logic:='0'; -- calibration signal input
    tdc_insig_i         : in  std_logic_vector(g_meas_channel_num-1 downto 0); -- signal to be measured
		
    -- another clock region
    utc_i               : in  std_logic_vector(39 downto 0):=(others=>'0'); -- time (>1s)
    pps_i               : in  std_logic;  -- pps input
		
    -- tdc data fifo output
    tm_output_wrreq_o   : out std_logic_vector(g_meas_channel_num-1 downto 0);
    tm_output_data_o    : out std_logic_vector(g_timestamp_width*g_meas_channel_num-1 downto 0);
    tm_output_edgepol_o : out std_logic_vector(g_meas_channel_num-1 downto 0);	

    dnl_output_wrreq_o  : out std_logic_vector(g_meas_channel_num-1 downto 0);
    dnl_output_data_o   : out std_logic_vector(g_dnl_width*g_meas_channel_num-1 downto 0);
    dnl_output_stall_i  : in  std_logic_vector(g_meas_channel_num-1 downto 0):=(others=>'0');

	  -- enable each channel 
    tdc_en_i            : in  std_logic_vector(g_meas_channel_num-1 downto 0):=(others=>'0');
    -- select the calibration or measured signal
    tdc_cal_sel_i       : in  std_logic_vector(g_meas_channel_num-1 downto 0):=(others=>'0'); 
    -- start build the lut&dnl
	tdc_lut_build_i     : in  std_logic_vector(g_meas_channel_num-1 downto 0):=(others=>'0');
    -- '1' = dnl table has been built
    tdc_dnl_done_o      : out std_logic_vector(g_meas_channel_num-1 downto 0);
    -- '1' = lut table has been built
    tdc_lut_done_o      : out std_logic_vector(g_meas_channel_num-1 downto 0)
  );
end component;

-- signals declaration
signal fifoa_empty : std_logic:='0';
signal fifoa_full  : std_logic:='0';
signal fifoa_rd    : std_logic;
signal fifoa_data  : std_logic_vector(g_data_width-1 downto 0):=(others=>'0');

signal fifob_empty : std_logic:='0';
signal fifob_full  : std_logic:='0';
signal fifob_rd    : std_logic;
signal fifob_data  : std_logic_vector(g_data_width-1 downto 0):=(others=>'0');

signal diff_fifo_wr   : std_logic;
signal diff_fifo_data : std_logic_vector(g_diff_width downto 0);
signal diff_fifo_full : std_logic:='0';

signal pcb_wb_regs_in : t_pcn_in_registers;
signal pcb_wb_regs_out : t_pcn_out_registers;

    -- tdc data fifo output
signal tm_output_wrreq   : std_logic_vector(2-1 downto 0);
signal tm_output_data    : std_logic_vector(g_timestamp_width*2-1 downto 0);
signal tm_output_full    : std_logic_vector(2-1 downto 0);
signal tm_output_edgepol : std_logic_vector(2-1 downto 0);	

signal dnl_output_wrreq  : std_logic_vector(2-1 downto 0);
signal dnl_output_data   : std_logic_vector(g_dnl_width*2-1 downto 0);
signal dnl_output_stall  : std_logic_vector(2-1 downto 0):=(others=>'0');

signal tdc_rst_n           : std_logic;
signal tdc_en              : std_logic_vector(1 downto 0):=(others=>'0');
signal tdc_cal_sel         : std_logic_vector(1 downto 0):=(others=>'0'); 
signal tdc_lut_build       : std_logic_vector(1 downto 0):=(others=>'0');
signal tdc_dnl_done        : std_logic_vector(1 downto 0);
signal tdc_lut_done        : std_logic_vector(1 downto 0);

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
    regs_i    => pcb_wb_regs_in,
    regs_o    => pcb_wb_regs_out
  );

  u_pcn_coincidence: pcn_coincidence
  generic map(
-- clock frequency
    g_clk_freq => 62500000,
-- fifo data width
    g_data_width => g_data_width,
-- coincidence window, 16 ns * ( 2^g_windows_width -1 )
    g_window_width => g_window_width,
-- diff data width
    g_diff_width => g_diff_width
   )
  port map(
    rst_n_i      => rst_n_i,
    clk_sys_i    => clk_sys_i,
    
    fifoa_empty_i=> fifoa_empty,
    fifoa_rd_o   => fifoa_rd,
    fifoa_data_i => fifoa_data,
    
    fifob_empty_i=> fifob_empty,
    fifob_rd_o   => fifob_rd,
    fifob_data_i => fifob_data,

    diff_fifo_wr_o    => diff_fifo_wr,
    diff_fifo_data_o  => diff_fifo_data,
    diff_fifo_full_i  => diff_fifo_full
  );

u_tdc_module : tdc_module
  generic map(
-- general
    g_meas_channel_num  => 2,
    g_delaychain_length => 128,
-- g_dualedge_enable   : boolean := c_dualedge_enable;
    g_waveunion_enable  => g_waveunion_enable,
-- g_correction_enable : boolean := c_correction_enable;
    g_hit_cnt           => g_hit_cnt,
-- timestamp data width
    g_timestamp_width   => g_timestamp_width,
    g_coarsecntr_width  => g_coarsecntr_width,
    g_fine_width        => g_fine_width,
-- dnl data width
    g_dnl_width         => g_dnl_width,
    g_dnl_addr_width    => g_dnl_addr_width,
    g_dnl_data_width    => g_dnl_data_width
  )
  port map(
    rst_n_i             => tdc_rst_n,
    clk_sys_i           => clk_sys_i,
    clk_ref_i           => clk_ref_i,
    clk_tdc_i           => clk_tdc_i,

    tdc_insig_i         => tdc_insig_i,
    tdc_cal_i           => tdc_cal_i,
    
    utc_i               => utc_i,
    pps_i               => pps_i,

    -- tdc data fifo output
    tm_output_wrreq_o   => tm_output_wrreq,
    tm_output_data_o    => tm_output_data,
    tm_output_edgepol_o => tm_output_edgepol,

    dnl_output_wrreq_o  => dnl_output_wrreq,
    dnl_output_data_o   => dnl_output_data,
    dnl_output_stall_i  => dnl_output_stall,

	-- enable each channel
    tdc_en_i            => tdc_en,
    -- select the calibration or measured signal
    tdc_cal_sel_i       => tdc_cal_sel,
    -- start build the lut&dnl
	tdc_lut_build_i     => tdc_lut_build,
    -- '1' = dnl table has been built
    tdc_dnl_done_o      => tdc_dnl_done,
    -- '1' = lut table has been built
    tdc_lut_done_o      => tdc_lut_done
  );

  U_FIFOA : generic_async_fifo
  generic map (
    g_data_width      => g_timestamp_width,
    g_size            => 32,
    g_with_rd_empty   => true,
    g_with_rd_count   => true)
  port map (
    rst_n_i           => tdc_rst_n,
    clk_wr_i          => clk_ref_i,
    d_i               => tm_output_data(g_timestamp_width-1 downto 0),
    we_i              => tm_output_wrreq(0),
    wr_empty_o        => open,
    wr_full_o         => tm_output_full(0),
    clk_rd_i          => clk_sys_i,
    q_o               => fifoa_data,
    rd_i              => fifoa_rd,
    rd_empty_o        => fifoa_empty,
    rd_full_o         => fifoa_full,
    rd_count_o        => open
    );

  U_FIFOB : generic_async_fifo
  generic map (
    g_data_width      => g_timestamp_width,
    g_size            => 32,
    g_with_rd_empty   => true,
    g_with_rd_count   => true)
  port map (
    rst_n_i           => tdc_rst_n,
    clk_wr_i          => clk_ref_i,
    d_i               => tm_output_data(2*g_timestamp_width-1 downto g_timestamp_width),
    we_i              => tm_output_wrreq(1),
    wr_empty_o        => open,
    wr_full_o         => tm_output_full(1),
    clk_rd_i          => clk_sys_i,
    q_o               => fifob_data,
    rd_i              => fifob_rd,
    rd_empty_o        => fifob_empty,
    rd_full_o         => fifob_full,
    rd_count_o        => open
    );

  pcb_wb_regs_in.sr_dnl_done_i <= tdc_dnl_done;
  pcb_wb_regs_in.sr_lut_done_i <= tdc_lut_done;
  pcb_wb_regs_in.tsdf_wr_req_i <= diff_fifo_wr;
  pcb_wb_regs_in.tsdf_val_i    <= diff_fifo_data;
  
  tdc_rst_n        <= not pcb_wb_regs_out.cr_rst_o;
  tdc_en           <= pcb_wb_regs_out.cr_en_o;
  tdc_cal_sel      <= pcb_wb_regs_out.cr_cal_sel_o;
  tdc_lut_build(0) <= pcb_wb_regs_out.cr_lut_build_o;
  tdc_lut_build(1) <= pcb_wb_regs_out.cr_lut_build_o;
  diff_fifo_full   <= pcb_wb_regs_out.tsdf_wr_full_o;

end architecture ; -- behavioral