-------------------------------------------------------------------------------
-- Title      : Module for LHAASO project
-- Project    : CUTE-WR
-------------------------------------------------------------------------------
-- File       : xwb_lhaaso_ed.vhd
-- Author     : hongming
-- Company    : tsinghua
-- Created    : 2016-03-24
-- Last update: 2016-03-24
-- Platform   : FPGA-generics
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2010 hongming
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-03-24  1.0      hongming        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;

entity xwb_pcn_module is
  generic(
    g_waveunion_enable  : boolean := true;
    g_raw_width        : integer := 8;
    g_interface_mode       : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity  : t_wishbone_address_granularity := WORD
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
		
    pcn_slave_i : in  t_wishbone_slave_in;
    pcn_slave_o : out t_wishbone_slave_out
    );
end xwb_pcn_module;

architecture behavioral of xwb_pcn_module is

component pcn_module is
  generic(
    g_waveunion_enable  : boolean := true;
    g_raw_width         : integer := 8
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
end component ; -- pcn_module
  
  signal wb_out       : t_wishbone_slave_out;
  signal wb_in        : t_wishbone_slave_in;
	
begin  -- behavioral
  
  U_Adapter : wb_slave_adapter
    generic map (
      g_master_use_struct  => true,
      g_master_mode        => CLASSIC,
      g_master_granularity => WORD,
      g_slave_use_struct   => true,
      g_slave_mode         => g_interface_mode,
      g_slave_granularity  => g_address_granularity)
    port map (
      clk_sys_i  => clk_sys_i,
      rst_n_i    => rst_n_i,
      master_i   => wb_out,
      master_o   => wb_in,
      slave_i    => pcn_slave_i,
      slave_o    => pcn_slave_o
      );

  WRAPPED_PCN_MODULE : pcn_module
    generic map(
      g_waveunion_enable=> g_waveunion_enable,
      g_raw_width       => g_raw_width
      )
    port map(
      clk_sys_i       => clk_sys_i,
      clk_ref_i       => clk_ref_i,
      clk_tdc_i       => clk_tdc_i,
      rst_n_i         => rst_n_i,
      tdc_insig_i     => tdc_insig_i,
      tdc_cal_i       => tdc_cal_i,
			tdc_fifo_wrreq_o=> tdc_fifo_wrreq_o, 
			tdc_fifo_wrdata_o => tdc_fifo_wrdata_o,
      wb_adr_i        => wb_in.adr(1 downto 0),
      wb_dat_i        => wb_in.dat,
      wb_dat_o        => wb_out.dat,
      wb_cyc_i        => wb_in.cyc,
      wb_sel_i        => wb_in.sel,
      wb_stb_i        => wb_in.stb,
      wb_we_i         => wb_in.we,
      wb_ack_o        => wb_out.ack,
      wb_stall_o      => wb_out.stall
      );

  wb_out.err <= '0';
  wb_out.rty <= '0';
  wb_out.int <= '0';
  
end behavioral;
