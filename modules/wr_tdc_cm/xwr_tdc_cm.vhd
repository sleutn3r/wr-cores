-------------------------------------------------------------------------------
-- Title      : Delaychain based TDC Control Module
-- Project    : CUTE-WR
-------------------------------------------------------------------------------
-- File       : xwr_tdc_cm.vhd
-- Author     : hongming
-- Company    : tsinghua
-- Created    : 2016-04-19
-- Last update: 2016-04-19
-- Platform   : FPGA-generics
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2010 hongming
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-04-19  1.0      hongming        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gencores_pkg.all;
use work.wishbone_pkg.all;

entity xwr_tdc_cm is
  generic(
    g_interface_mode       : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity  : t_wishbone_address_granularity := WORD
  );
  port (
    clk_ref_i           : in std_logic;
    clk_sys_i           : in std_logic;

    rst_n_i             : in std_logic;

    slave_i             : in  t_wishbone_slave_in;
    slave_o             : out t_wishbone_slave_out;

    tdc_rst_o           : out std_logic;
    tdc_en_o            : out std_logic;
    tdc_cal_sel_o       : out std_logic;
    tdc_fifo_empty_ch_i : in  std_logic_vector(7 downto 0);
    tdc_fifo_full_ch_i  : in  std_logic_vector(7 downto 0);
    tdc_buf_empty_i     : in  std_logic;
    tdc_buf_full_i      : in  std_logic
    );
end xwr_tdc_cm;

architecture behavioral of xwr_tdc_cm is

component wr_tdc_cm is
generic(
    g_interface_mode       : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity  : t_wishbone_address_granularity := WORD
);
port (
    clk_ref_i           : in std_logic;
    clk_sys_i           : in std_logic;

    rst_n_i             : in std_logic;

    wb_adr_i            : in  std_logic_vector(4 downto 0);
    wb_dat_i            : in  std_logic_vector(31 downto 0);
    wb_dat_o            : out std_logic_vector(31 downto 0);
    wb_cyc_i            : in  std_logic;
    wb_sel_i            : in  std_logic_vector(3 downto 0);
    wb_stb_i            : in  std_logic;
    wb_we_i             : in  std_logic;
    wb_ack_o            : out std_logic;
    wb_stall_o          : out std_logic;

    tdc_rst_o           : out std_logic;
    tdc_en_o            : out std_logic;
    tdc_cal_sel_o       : out std_logic;
    tdc_fifo_empty_ch_i : in  std_logic_vector(7 downto 0);
    tdc_fifo_full_ch_i  : in  std_logic_vector(7 downto 0);
    tdc_buf_empty_i     : in  std_logic;
    tdc_buf_full_i      : in  std_logic
    );
end component;
  
begin  -- behavioral

  
  WRAPPED_TDC_CM : wr_tdc_cm
    generic map(
      g_interface_mode       => g_interface_mode,
      g_address_granularity  => g_address_granularity
      )
    port map(
      clk_ref_i           => clk_ref_i,
      clk_sys_i           => clk_sys_i,
      rst_n_i             => rst_n_i,
      wb_adr_i            => slave_i.adr(4 downto 0),
      wb_dat_i            => slave_i.dat,
      wb_dat_o            => slave_o.dat,
      wb_cyc_i            => slave_i.cyc,
      wb_sel_i            => slave_i.sel,
      wb_stb_i            => slave_i.stb,
      wb_we_i             => slave_i.we,
      wb_ack_o            => slave_o.ack,
      wb_stall_o          => slave_o.stall,

      tdc_rst_o           => tdc_rst_o,
      tdc_en_o            => tdc_en_o,
      tdc_cal_sel_o       => tdc_cal_sel_o,
      tdc_fifo_empty_ch_i => tdc_fifo_empty_ch_i,
      tdc_fifo_full_ch_i  => tdc_fifo_full_ch_i,
      tdc_buf_empty_i     => tdc_buf_empty_i,
      tdc_buf_full_i      => tdc_buf_full_i
      );

  slave_o.err <= '0';
  slave_o.rty <= '0';
  slave_o.int <= '0';
  
end behavioral;
