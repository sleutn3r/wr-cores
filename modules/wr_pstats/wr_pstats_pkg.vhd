-------------------------------------------------------------------------------
-- Title      : Port monitoring system
-- Project    : White Rabbit 
-------------------------------------------------------------------------------
-- File       : xwr_pstats_pkg.vhd
-- Author     : Cesar Prados
-- Company    : GSI
-- Created    : 2015-08-11
-- Platform   : FPGA-generic
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- Stats package
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

package wr_pstats_pkg is
  
  constant c_events  : integer   := 29;
  constant c_L1_cnt_density  : integer := 32; -- bits
  constant c_L2_cnt_density  : integer := 16; -- bits

  type t_cnt is
    record
      L1_cnt  : std_logic_vector(c_L1_cnt_density - 1 downto 0);
      L2_cnt  : std_logic_vector(c_L2_cnt_density - 1 downto 0);
      cnt_ovf : std_logic;
    end record;

  type t_cnt_events is array (c_events - 1 downto 0) of t_cnt;

  component xwr_pstats
    port(
      clk_i       : in  std_logic;
      rstn_i      : in  std_logic;
      events_i    : in  std_logic_vector(c_events - 1 downto 0); 
      wb_slave_o  : out t_wishbone_slave_out;
      wb_slave_i  : in  t_wishbone_slave_in);
  end component;

  component port_cntr
    port(
      clk_i       : in  std_logic;
      rstn_i      : in  std_logic;
      cnt_eo_i    : in  std_logic;
      cnt_ovf_o   : out std_logic;
      cnt_o       : out t_cnt);
  end component;

  component pstats_wb_slave
    port (
      clk_i       : in  std_logic;
      rstn_i      : in  std_logic;
      reg_i       : in  t_cnt_events;
      cnt_ovf_i   : in  std_logic_vector(c_events - 1 downto 0);
      cnt_rst_o   : out std_logic;
      wb_slave_o  : out t_wishbone_slave_out;
      wb_slave_i  : in  t_wishbone_slave_in);
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
      name      => "WR-PSTATS          ")));

end wr_pstats_pkg;
