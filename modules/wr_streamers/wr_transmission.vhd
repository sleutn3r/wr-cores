-------------------------------------------------------------------------------
-- Title      : Btrain over White Rabbit
-- Project    : Btrain
-------------------------------------------------------------------------------
-- File       : wr_transmission.vhd
-- Author     : Maciej Lipinski
-- Company    : CERN
-- Platform   : FPGA-generics
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
--
-- This is a wrapper for xwr_transmission.vhd which is required for simulation
-- of the design using SystemVerilog. for detailed description see xwr_transmission.vhd 
-------------------------------------------------------------------------------
--
-- Copyright (c) 2016 CERN/BE-CO-HT
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
-- Date        Version  Author          Description
-- 2016-05-30  1.0      mlipinsk        created
---------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.wishbone_pkg.all;  -- needed for t_wishbone_slave_in, etc
use work.streamers_pkg.all; -- needed for streamers and  c_WR_TRANS_ARR_SIZE_*
use work.wr_fabric_pkg.all; -- needed for :t_wrf_source_in, etc
use work.wrcore_pkg.all;    -- needed for t_generic_word_array
use work.wr_transmission_wbgen2_pkg.all;

entity wr_transmission is
  generic (
    g_tx_data_width            : integer := 32;
    g_tx_threshold             : integer := 128;
    g_tx_max_words_per_frame   : integer := 128;
    g_tx_timeout               : integer := 1024;
    g_tx_escape_code_disable   : boolean := FALSE;
    g_rx_data_width            : integer := 32;
    g_rx_buffer_size           : integer := 16;
    g_rx_escape_code_disable   : boolean := FALSE;
    g_rx_expected_words_number : integer := 0;
    g_stats_cnt_width          : integer := 32;
    g_stats_acc_width          : integer := 64;
    g_slave_mode               : t_wishbone_interface_mode      := CLASSIC;
    g_slave_granularity        : t_wishbone_address_granularity := BYTE
    );
  port (
    clk_sys_i                  : in std_logic;
    rst_n_i                    : in std_logic;
    src_dat_o                  : out std_logic_vector(15 downto 0);
    src_adr_o                  : out std_logic_vector(1 downto 0);
    src_sel_o                  : out std_logic_vector(1 downto 0);
    src_cyc_o                  : out std_logic;
    src_stb_o                  : out std_logic;
    src_we_o                   : out std_logic;
    src_stall_i                : in  std_logic;
    src_ack_i                  : in  std_logic;
    src_err_i                  : in  std_logic;
    snk_dat_i                  : in  std_logic_vector(15 downto 0);
    snk_adr_i                  : in  std_logic_vector(1 downto 0);
    snk_sel_i                  : in  std_logic_vector(1 downto 0);
    snk_cyc_i                  : in  std_logic;
    snk_stb_i                  : in  std_logic;
    snk_we_i                   : in  std_logic;
    snk_stall_o                : out std_logic;
    snk_ack_o                  : out std_logic;
    snk_err_o                  : out std_logic;
    snk_rty_o                  : out std_logic;
    tx_data_i                  : in std_logic_vector(g_tx_data_width-1 downto 0);
    tx_valid_i                 : in std_logic;
    tx_dreq_o                  : out std_logic;
    tx_last_p1_i               : in std_logic := '1';
    tx_flush_p1_i              : in std_logic := '0';
    rx_first_p1_o              : out std_logic;
    rx_last_p1_o               : out std_logic;
    rx_data_o                  : out std_logic_vector(g_rx_data_width-1 downto 0);
    rx_valid_o                 : out std_logic;
    rx_dreq_i                  : in  std_logic;
    clk_ref_i                  : in std_logic := '0';
    tm_time_valid_i            : in std_logic := '0';
    tm_tai_i                   : in std_logic_vector(39 downto 0) := x"0000000000";
    tm_cycles_i                : in std_logic_vector(27 downto 0) := x"0000000";
    wb_slave_adr_i             : in  std_logic_vector(31 downto 0):= (others => 'X');
    wb_slave_dat_i             : in  std_logic_vector(31 downto 0):= (others => 'X');
    wb_slave_dat_o             : out std_logic_vector(31 downto 0);
    wb_slave_cyc_i             : in  std_logic                    := '0';
    wb_slave_sel_i             : in  std_logic_vector(3 downto 0) := (others => 'X');
    wb_slave_stb_i             : in  std_logic                    := '0';
    wb_slave_we_i              : in  std_logic                    := 'X';
    wb_slave_ack_o             : out std_logic;
    wb_slave_stall_o           : out std_logic;
    wb_slave_int_o             : out std_logic;
    snmp_array_o               : out std_logic_vector(c_WR_TRANS_ARR_SIZE_OUT*32-1 downto 0);
    snmp_array_i               : in  std_logic_vector(c_WR_TRANS_ARR_SIZE_IN *32-1 downto 0);
    tx_cfg_mac_local_i         : in std_logic_vector(47 downto 0) := x"000000000000";
    tx_cfg_mac_target_i        : in std_logic_vector(47 downto 0):= x"ffffffffffff";
    tx_cfg_ethertype_i         : in std_logic_vector(15 downto 0) := x"dbff";
    rx_cfg_mac_local_i         : in std_logic_vector(47 downto 0) := x"000000000000";
    rx_cfg_mac_remote_i        : in std_logic_vector(47 downto 0) := x"000000000000";
    rx_cfg_ethertype_i         : in std_logic_vector(15 downto 0) := x"dbff";
    rx_cfg_accept_broadcasts_i : in std_logic                     := '1';
    rx_cfg_filter_remote_i     : in std_logic                     := '0';
    rx_cfg_fixed_latency_i     : in std_logic_vector(27 downto 0) := x"0000000"
    );

end wr_transmission;

architecture rtl of wr_transmission is

  signal snk_in         : t_wrf_sink_in;
  signal snk_out        : t_wrf_sink_out;

  signal src_in         : t_wrf_source_in;
  signal src_out        : t_wrf_source_out;

  signal wb_in          : t_wishbone_slave_in;
  signal wb_out         : t_wishbone_slave_out;

  signal snmp_array_out : t_generic_word_array(c_WR_TRANS_ARR_SIZE_OUT-1 downto 0);
  signal snmp_array_in  : t_generic_word_array(c_WR_TRANS_ARR_SIZE_IN -1 downto 0);

begin

  U_Wrapped_transmission: xwr_transmission
    generic map (
      g_tx_data_width            => g_tx_data_width,
      g_tx_threshold             => g_tx_threshold,
      g_tx_max_words_per_frame   => g_tx_max_words_per_frame,
      g_tx_timeout               => g_tx_timeout,
      g_tx_escape_code_disable   => g_tx_escape_code_disable,
      g_rx_data_width            => g_rx_data_width,
      g_rx_buffer_size           => g_rx_buffer_size,
      g_rx_escape_code_disable   => g_rx_escape_code_disable,
      g_rx_expected_words_number => g_rx_expected_words_number,
      g_stats_cnt_width          => g_stats_cnt_width,
      g_stats_acc_width          => g_stats_acc_width,
      g_slave_mode               => g_slave_mode,
      g_slave_granularity        => g_slave_granularity
      )
    port map (
      clk_sys_i                  => clk_sys_i,
      rst_n_i                    => rst_n_i,
      src_i                      => src_in,
      src_o                      => src_out,
      snk_i                      => snk_in,
      snk_o                      => snk_out,
      tx_data_i                  => tx_data_i,
      tx_valid_i                 => tx_valid_i,
      tx_dreq_o                  => tx_dreq_o,
      tx_last_p1_i               => tx_last_p1_i,
      tx_flush_p1_i              => tx_flush_p1_i,
      rx_first_p1_o              => rx_first_p1_o,
      rx_last_p1_o               => rx_last_p1_o,
      rx_data_o                  => rx_data_o,
      rx_valid_o                 => rx_valid_o,
      rx_dreq_i                  => rx_dreq_i,
      clk_ref_i                  => clk_ref_i,
      tm_time_valid_i            => tm_time_valid_i,
      tm_tai_i                   => tm_tai_i,
      tm_cycles_i                => tm_cycles_i,
      wb_slave_i                 => wb_in,
      wb_slave_o                 => wb_out,
      snmp_array_o               => snmp_array_out,
      snmp_array_i               => snmp_array_in,
      tx_cfg_mac_local_i         => tx_cfg_mac_local_i,
      tx_cfg_mac_target_i        => tx_cfg_mac_target_i,
      tx_cfg_ethertype_i         => tx_cfg_ethertype_i,
      rx_cfg_mac_local_i         => rx_cfg_mac_local_i,
      rx_cfg_mac_remote_i        => rx_cfg_mac_remote_i,
      rx_cfg_ethertype_i         => rx_cfg_ethertype_i,
      rx_cfg_accept_broadcasts_i => rx_cfg_accept_broadcasts_i,
      rx_cfg_filter_remote_i     => rx_cfg_filter_remote_i,
      rx_cfg_fixed_latency_i     => rx_cfg_fixed_latency_i
      );

  src_adr_o    <= src_out.adr;
  src_dat_o    <= src_out.dat;
  src_sel_o    <= src_out.sel;
  src_stb_o    <= src_out.stb;
  src_we_o     <= src_out.we;
  src_cyc_o    <= src_out.cyc;
  src_in.ack   <= src_ack_i;
  src_in.stall <= src_stall_i;
  src_in.err   <= src_err_i;

  snk_in.dat  <= snk_dat_i;
  snk_in.adr  <= snk_adr_i;
  snk_in.sel  <= snk_sel_i;
  snk_in.cyc  <= snk_cyc_i;
  snk_in.stb  <= snk_stb_i;
  snk_in.we   <= snk_we_i;
  snk_stall_o <= snk_out.stall;
  snk_ack_o   <= snk_out.ack;
  snk_err_o   <= snk_out.err;
  snk_rty_o   <= snk_out.rty;


  wb_in.adr(31 downto 0) <= wb_slave_adr_i;
  wb_in.dat              <= wb_slave_dat_i;
  wb_in.cyc              <= wb_slave_cyc_i;
  wb_in.stb              <= wb_slave_stb_i;
  wb_in.sel              <= wb_slave_sel_i;
  wb_in.we               <= wb_slave_we_i;
  wb_slave_dat_o         <= wb_out.dat;
  wb_slave_ack_o         <= wb_out.ack;
  wb_slave_stall_o       <= wb_out.stall;
  wb_slave_int_o         <= wb_out.int;

  vectorize_snmp_array_out : for i in 0 to c_WR_TRANS_ARR_SIZE_OUT-1 generate
    snmp_array_o((i+1)*32-1  downto i*32) <= snmp_array_out(i);
  end generate vectorize_snmp_array_out;

  vectorize_snmp_array_in : for i in 0 to c_WR_TRANS_ARR_SIZE_IN-1 generate
    snmp_array_in(i) <= snmp_array_i((i+1)*32-1  downto i*32);
  end generate vectorize_snmp_array_in;

end rtl;