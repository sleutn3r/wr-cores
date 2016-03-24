-------------------------------------------------------------------------------
-- Title      : Module for LHAASO Electron Detector
-- Project    : CUTE-WR
-------------------------------------------------------------------------------
-- File       : wr_lhaaso_ed.vhd
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
-- 2010-09-02  1.0      hongming        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gencores_pkg.all;
use work.genram_pkg.all;
use work.wishbone_pkg.all;

entity wr_lhaaso_ed is
  generic(
    g_interface_mode       : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity  : t_wishbone_address_granularity := WORD
  );
  port (
    clk_ref_i : in std_logic;
    clk_sys_i : in std_logic;

    rst_n_i : in std_logic;

    wb_adr_i   : in  std_logic_vector(0 downto 0);
    wb_dat_i   : in  std_logic_vector(31 downto 0);
    wb_dat_o   : out std_logic_vector(31 downto 0);
    wb_cyc_i   : in  std_logic;
    wb_sel_i   : in  std_logic_vector(3 downto 0);
    wb_stb_i   : in  std_logic;
    wb_we_i    : in  std_logic;
    wb_ack_o   : out std_logic;
    wb_stall_o : out std_logic;

    temperature_o        : out std_logic_vector(31 downto 0);
    temperature_valid_o  : out std_logic
    );
end wr_lhaaso_ed;

architecture behavioral of wr_lhaaso_ed is

component lhaaso_ed_wb is
  port (
    rst_n_i                                  : in     std_logic;
    clk_sys_i                                : in     std_logic;
    wb_adr_i                                 : in     std_logic_vector(0 downto 0);
    wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    wb_stall_o                               : out    std_logic;
    refclk_i                                 : in     std_logic;
-- Port for asynchronous (clock: refclk_i) std_logic_vector field: 'Temperature register' in reg: 'Board temperature register'
    lhaaso_ed_temperature_o                  : out    std_logic_vector(31 downto 0);
-- Port for asynchronous (clock: refclk_i) BIT field: 'Temperature Valid register' in reg: 'Temperature Valid Register'
    lhaaso_ed_tempvalid_o                    : out    std_logic
  );
end component;

  signal resized_addr : std_logic_vector(c_wishbone_address_width-1 downto 0);
  signal wb_out       : t_wishbone_slave_out;
  signal wb_in        : t_wishbone_slave_in;

  signal temperature       : std_logic_vector(31 downto 0);
  signal temperature_valid : std_logic;

begin  -- behavioral


  resized_addr(0 downto 0)                          <= wb_adr_i;
  resized_addr(c_wishbone_address_width-1 downto 5) <= (others => '0');

  U_Adapter : wb_slave_adapter
    generic map (
      g_master_use_struct  => true,
      g_master_mode        => CLASSIC,
      g_master_granularity => WORD,
      g_slave_use_struct   => false,
      g_slave_mode         => g_interface_mode,
      g_slave_granularity  => g_address_granularity)
    port map (
      clk_sys_i  => clk_sys_i,
      rst_n_i    => rst_n_i,
      master_i   => wb_out,
      master_o   => wb_in,
      sl_adr_i   => resized_addr,
      sl_dat_i   => wb_dat_i,
      sl_sel_i   => wb_sel_i,
      sl_cyc_i   => wb_cyc_i,
      sl_stb_i   => wb_stb_i,
      sl_we_i    => wb_we_i,
      sl_dat_o   => wb_dat_o,
      sl_ack_o   => wb_ack_o,
      sl_stall_o => wb_stall_o);

  U_wb_slave : lhaaso_ed_wb
    port map (
      rst_n_i                => rst_n_i,
      clk_sys_i              => clk_sys_i,
      wb_adr_i               => wb_in.adr(0 downto 0),
      wb_dat_i               => wb_in.dat,
      wb_dat_o               => wb_out.dat,
      wb_cyc_i               => wb_in.cyc,
      wb_sel_i               => wb_in.sel,
      wb_stb_i               => wb_in.stb,
      wb_we_i                => wb_in.we,
      wb_ack_o               => wb_out.ack,
      refclk_i               => clk_ref_i,
      lhaaso_ed_temperature_o=> temperature,
      lhaaso_ed_tempvalid_o  => temperature_valid);

    temperature_o <= temperature;
    temperature_valid_o <= temperature_valid;
    
end behavioral;
