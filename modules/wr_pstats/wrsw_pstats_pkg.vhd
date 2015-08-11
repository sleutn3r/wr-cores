-------------------------------------------------------------------------------
-- Title      : Per-port monitoring system
-- Project    : White Rabbit 
-------------------------------------------------------------------------------
-- File       : xwrsw_pstats_pkg.vhd
-- Author     : Cesar Prados
-- Company    : GSI
-- Created    : 2013-11-08
-- Platform   : FPGA-generic
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- Per-port monitoring system package
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Cesar Prados c.prados@gsi.de / GSI
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.wishbone_pkg.all;

package wrsw_pstats_pkg is

  component xwrsw_pstats
    generic(
      g_interface_mode      : t_wishbone_interface_mode      := PIPELINED;
      g_address_granularity : t_wishbone_address_granularity := BYTE;
      g_nports : integer := 2;
      g_cnt_pp : integer := 16; 
      g_cnt_pw : integer := 4); 
   port(
      rst_n_i : in std_logic;
      clk_i   : in std_logic;

      events_i : in std_logic_vector(g_nports*g_cnt_pp-1 downto 0); 

      wb_i : in  t_wishbone_slave_in;
      wb_o : out t_wishbone_slave_out );
  end component;

 constant c_xwr_pstats_sdb : t_sdb_device := (
      abi_class     => x"0000",              -- undocumented device
      abi_ver_major => x"01",
      abi_ver_minor => x"01",
      wbd_endian    => c_sdb_endian_big,
      wbd_width     => x"7",                 -- 8/16/32-bit port granularity
      sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
      vendor_id => x"000000000000CE42",  -- CERN
      device_id => x"6a0c4d4d",
      version   => x"00000001",
      date      => x"20131116",
      name      => "wr-node-monitor    ")));

end wrsw_pstats_pkg;
