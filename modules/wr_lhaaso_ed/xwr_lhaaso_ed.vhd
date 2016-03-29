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

entity xwr_lhaaso_ed is
  generic(
    g_interface_mode       : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity  : t_wishbone_address_granularity := WORD);
  port (
    clk_ref_i : in std_logic;
    clk_sys_i : in std_logic;
    rst_n_i   : in std_logic;

    slave_i : in  t_wishbone_slave_in;
    slave_o : out t_wishbone_slave_out;

    temperature_o        : out std_logic_vector(31 downto 0);
    temperature_valid_o  : out std_logic
    );
end xwr_lhaaso_ed;

architecture behavioral of xwr_lhaaso_ed is

  component wr_lhaaso_ed is
    generic(
      g_interface_mode       : t_wishbone_interface_mode      := CLASSIC;
      g_address_granularity  : t_wishbone_address_granularity := WORD
    );
    port (
      clk_ref_i : in std_logic;
      clk_sys_i : in std_logic;

      rst_n_i : in std_logic;

      wb_adr_i   : in  std_logic_vector(4 downto 0);
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
  end component;
  
begin  -- behavioral

  
  WRAPPED_LHAASO_ED : wr_lhaaso_ed
    generic map(
      g_interface_mode       => g_interface_mode,
      g_address_granularity  => g_address_granularity
      )
    port map(
      clk_ref_i       => clk_ref_i,
      clk_sys_i       => clk_sys_i,
      rst_n_i         => rst_n_i,
      wb_adr_i        => slave_i.adr(4 downto 0),
      wb_dat_i        => slave_i.dat,
      wb_dat_o        => slave_o.dat,
      wb_cyc_i        => slave_i.cyc,
      wb_sel_i        => slave_i.sel,
      wb_stb_i        => slave_i.stb,
      wb_we_i         => slave_i.we,
      wb_ack_o        => slave_o.ack,
      wb_stall_o      => slave_o.stall,
      temperature_o   => temperature_o,
      temperature_valid_o=>temperature_valid_o
      );

  slave_o.err <= '0';
  slave_o.rty <= '0';
  slave_o.int <= '0';
  
end behavioral;
