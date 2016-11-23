-------------------------------------------------------------------------------
-- Title      : WRPC Wrapper for VFC-HD
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : xwrc_board_vfchd.vhd
-- Author(s)  : Dimitrios Lampridis  <dimitrios.lampridis@cern.ch>
-- Company    : CERN (BE-CO-HT)
-- Created    : 2016-07-26
-- Last update: 2016-11-23
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top-level wrapper for WR PTP core including all the modules
-- needed to operate the core on the VFC-HD board.
-- http://www.ohwr.org/projects/vfc-hd/
-------------------------------------------------------------------------------
-- Copyright (c) 2016 CERN
-------------------------------------------------------------------------------
-- GNU LESSER GENERAL PUBLIC LICENSE
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
--use ieee.numeric_std.all;

library work;
use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wishbone_pkg.all;
use work.wr_fabric_pkg.all;
use work.endpoint_pkg.all;
use work.wr_altera_pkg.all;

entity xwrc_board_vfchd is
  generic(
    g_simulation  : integer := 0;
    g_dpram_initf : string  := "default"
    );
  port (
    ---------------------------------------------------------------------------
    -- Clocks/resets
    ---------------------------------------------------------------------------

    -- Clock inputs from the board
    clk_board_125m_i : in std_logic;
    clk_board_20m_i  : in std_logic;

    -- Reset input (active low, can be async)
    areset_n_i : in std_logic;

    -- 62.5MHz sys clock output
    clk_sys_62m5_o : out std_logic;

    -- 125MHz ref clock output
    clk_ref_125m_o : out std_logic;

    -- active high reset output, synchronous to clk_sys_62m5_o
    rst_sys_62m5_o : out std_logic;

    ---------------------------------------------------------------------------
    -- SPI interfaces to DACs
    ---------------------------------------------------------------------------

    dac_ref_sync_n_o  : out std_logic;
    dac_dmtd_sync_n_o : out std_logic;
    dac_din_o         : out std_logic;
    dac_sclk_o        : out std_logic;

    ---------------------------------------------------------------------------
    -- SFP I/O for transceiver
    ---------------------------------------------------------------------------

    sfp_tx_o : out std_logic;
    sfp_rx_i : in  std_logic;

    ---------------------------------------------------------------------------
    -- I2C EEPROM
    ---------------------------------------------------------------------------

    eeprom_sda_b : inout std_logic;
    -- VFC-HD defines SCL as output, which works because the EEPROM is the
    -- only device connected on this I2C bus.
    eeprom_scl_o : out std_logic;

    ---------------------------------------------------------------------------
    -- External WB interface
    ---------------------------------------------------------------------------

    wb_adr_i   : in  std_logic_vector(c_wishbone_address_width-1 downto 0)   := (others => '0');
    wb_dat_i   : in  std_logic_vector(c_wishbone_data_width-1 downto 0)      := (others => '0');
    wb_dat_o   : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_sel_i   : in  std_logic_vector(c_wishbone_address_width/8-1 downto 0) := (others => '0');
    wb_we_i    : in  std_logic                                               := '0';
    wb_cyc_i   : in  std_logic                                               := '0';
    wb_stb_i   : in  std_logic                                               := '0';
    wb_ack_o   : out std_logic;
    wb_int_o   : out std_logic;
    wb_err_o   : out std_logic;
    wb_rty_o   : out std_logic;
    wb_stall_o : out std_logic;

    ---------------------------------------------------------------------------
    -- WRPC timing interface and status
    ---------------------------------------------------------------------------

    tm_time_valid_o : out std_logic;
    led_link_o      : out std_logic;
    led_act_o       : out std_logic);

end entity xwrc_board_vfchd;


architecture struct of xwrc_board_vfchd is

  -----------------------------------------------------------------------------
  -- Constants
  -----------------------------------------------------------------------------

  -- This is used to ignore (for now) the g_pcs_16bit value, since PCS16 is not
  -- supported yet.
  constant c_pcs_16bit : boolean := FALSE;

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- PLLs
  signal clk_pll_62m5 : std_logic;
  signal clk_pll_125m : std_logic;
  signal clk_pll_dmtd : std_logic;
  signal pll_locked   : std_logic;

  -- Reset logic
  signal rst_62m5_n       : std_logic;
  signal rstlogic_arst_n  : std_logic;
  signal rstlogic_clk_in  : std_logic_vector(0 downto 0);
  signal rstlogic_rst_out : std_logic_vector(0 downto 0);

  -- PLL DAC ARB
  signal dac_sync_n       : std_logic_vector(1 downto 0);
  signal dac_hpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_load_p1 : std_logic;
  signal dac_dpll_data    : std_logic_vector(15 downto 0);

  -- I2C EEPROM
  signal eeprom_sda_in  : std_logic;
  signal eeprom_sda_out : std_logic;

  -- PHY
  signal phy_ready        : std_logic;
  signal phy_loopen       : std_logic;
  signal phy_rst          : std_logic;
  signal phy_tx_clk       : std_logic;
  signal phy_tx_data      : std_logic_vector(f_pcs_data_width(c_pcs_16bit)-1 downto 0);
  signal phy_tx_k         : std_logic_vector(f_pcs_k_width(c_pcs_16bit)-1 downto 0);
  signal phy_tx_disparity : std_logic;
  signal phy_tx_enc_err   : std_logic;
  signal phy_rx_rbclk     : std_logic;
  signal phy_rx_data      : std_logic_vector(f_pcs_data_width(c_pcs_16bit)-1 downto 0);
  signal phy_rx_k         : std_logic_vector(f_pcs_k_width(c_pcs_16bit)-1 downto 0);
  signal phy_rx_enc_err   : std_logic;
  signal phy_rx_bitslide  : std_logic_vector(f_pcs_bts_width(c_pcs_16bit)-1 downto 0);

  -- External WB interface
  signal wb_slave_out : t_wishbone_slave_out;
  signal wb_slave_in  : t_wishbone_slave_in;

begin  -- architecture struct

  -----------------------------------------------------------------------------
  -- Platform-dependent part (PHY, PLLs, etc)
  -----------------------------------------------------------------------------

  cmp_xwrc_platform : xwrc_platform_altera
    generic map (
      g_fpga_family               => "arria5",
      g_with_external_clock_input => FALSE,
      g_use_default_plls          => TRUE,
      g_pcs_16bit                 => c_pcs_16bit)
    port map (
      areset_n_i         => areset_n_i,
      clk_20m_i          => clk_board_20m_i,
      clk_125m_i         => clk_board_125m_i,
      pad_tx_o           => sfp_tx_o,
      pad_rx_i           => sfp_rx_i,
      clk_62m5_sys_o     => clk_pll_62m5,
      clk_125m_ref_o     => clk_pll_125m,
      clk_62m5_dmtd_o    => clk_pll_dmtd,
      pll_locked_o       => pll_locked,
      phy_ready_o        => phy_ready,
      phy_loopen_i       => phy_loopen,
      phy_rst_i          => phy_rst,
      phy_tx_clk_o       => phy_tx_clk,
      phy_tx_data_i      => phy_tx_data,
      phy_tx_k_i         => phy_tx_k,
      phy_tx_disparity_o => phy_tx_disparity,
      phy_tx_enc_err_o   => phy_tx_enc_err,
      phy_rx_rbclk_o     => phy_rx_rbclk,
      phy_rx_data_o      => phy_rx_data,
      phy_rx_k_o         => phy_rx_k,
      phy_rx_enc_err_o   => phy_rx_enc_err,
      phy_rx_bitslide_o  => phy_rx_bitslide);

  clk_sys_62m5_o <= clk_pll_62m5;
  clk_ref_125m_o <= clk_pll_125m;

  -----------------------------------------------------------------------------
  -- Reset logic
  -----------------------------------------------------------------------------

  -- logic AND of all async reset sources (active low)
  rstlogic_arst_n <= pll_locked and areset_n_i;

  -- concatenation of all clocks required to have synced resets
  rstlogic_clk_in(0) <= clk_pll_62m5;

  cmp_rstlogic_reset : gc_reset
    generic map (
      g_clocks    => 1,                           -- 62.5MHz
      g_logdelay  => 4,                           -- 16 clock cycles
      g_syncdepth => 3)                           -- length of sync chains
    port map (
      free_clk_i => clk_board_125m_i,
      locked_i   => rstlogic_arst_n,
      clks_i     => rstlogic_clk_in,
      rstn_o     => rstlogic_rst_out);

  -- distribution of resets (already synchronized to their clock domains)
  rst_62m5_n <= rstlogic_rst_out(0);

  rst_sys_62m5_o <= not rst_62m5_n;

  -----------------------------------------------------------------------------
  -- SPI DAC (2-channel)
  -----------------------------------------------------------------------------

  cmp_spi_dac : spec_serial_dac_arb
    generic map (
      g_invert_sclk    => FALSE,
      g_num_extra_bits => 8)
    port map (
      clk_i       => clk_pll_62m5,
      rst_n_i     => rst_62m5_n,
      val1_i      => dac_dpll_data,
      load1_i     => dac_dpll_load_p1,
      val2_i      => dac_hpll_data,
      load2_i     => dac_hpll_load_p1,
      dac_clr_n_o => open,
      dac_cs_n_o  => dac_sync_n,
      dac_sclk_o  => dac_sclk_o,
      dac_din_o   => dac_din_o);

  dac_ref_sync_n_o  <= dac_sync_n(0);
  dac_dmtd_sync_n_o <= dac_sync_n(1);

  -----------------------------------------------------------------------------
  -- Tristates for I2C EEPROM
  -----------------------------------------------------------------------------

  eeprom_sda_b  <= '0' when (eeprom_sda_out = '0') else 'Z';
  eeprom_sda_in <= eeprom_sda_b;

  -----------------------------------------------------------------------------
  -- The WR PTP core itself
  -----------------------------------------------------------------------------

  cmp_xwr_core : xwr_core
    generic map (
      g_simulation          => g_simulation,
      g_phys_uart           => TRUE,
      g_aux_clks            => 1,
      g_interface_mode      => CLASSIC,
      g_address_granularity => WORD,
      g_pcs_16bit           => c_pcs_16bit,
      g_dpram_initf         => g_dpram_initf)
    port map (
      clk_sys_i            => clk_pll_62m5,
      clk_dmtd_i           => clk_pll_dmtd,
      clk_ref_i            => clk_pll_125m,
      clk_aux_i            => (others => '0'),
      clk_ext_i            => '0',
      clk_ext_mul_i        => '0',
      clk_ext_mul_locked_i => '0',
      clk_ext_stopped_i    => '1',
      clk_ext_rst_o        => open,
      pps_ext_i            => '0',
      rst_n_i              => rst_62m5_n,
      dac_hpll_load_p1_o   => dac_hpll_load_p1,
      dac_hpll_data_o      => dac_hpll_data,
      dac_dpll_load_p1_o   => dac_dpll_load_p1,
      dac_dpll_data_o      => dac_dpll_data,
      phy_ref_clk_i        => phy_tx_clk,
      phy_tx_data_o        => phy_tx_data,
      phy_tx_k_o           => phy_tx_k,
      phy_tx_disparity_i   => phy_tx_disparity,
      phy_tx_enc_err_i     => phy_tx_enc_err,
      phy_rx_data_i        => phy_rx_data,
      phy_rx_rbclk_i       => phy_rx_rbclk,
      phy_rx_k_i           => phy_rx_k,
      phy_rx_enc_err_i     => phy_rx_enc_err,
      phy_rx_bitslide_i    => phy_rx_bitslide,
      phy_rst_o            => phy_rst,
      phy_loopen_o         => phy_loopen,
      phy_rdy_i            => phy_ready,
      phy_loopen_vec_o     => open,
      phy_tx_prbs_sel_o    => open,
      phy_sfp_tx_fault_i   => '0',
      phy_sfp_los_i        => '0',
      phy_sfp_tx_disable_o => open,
      led_act_o            => led_act_o,
      led_link_o           => led_link_o,
      scl_o                => eeprom_scl_o,
      scl_i                => '1',
      sda_o                => eeprom_sda_out,
      sda_i                => eeprom_sda_in,
      sfp_scl_o            => open,
      sfp_scl_i            => '1',
      sfp_sda_o            => open,
      sfp_sda_i            => '1',
      sfp_det_i            => '1',                -- TODO: replace with actual signal
      btn1_i               => '1',
      btn2_i               => '1',
      spi_sclk_o           => open,
      spi_ncs_o            => open,
      spi_mosi_o           => open,
      spi_miso_i           => '0',
      uart_rxd_i           => '0',
      uart_txd_o           => open,
      owr_pwren_o          => open,
      owr_en_o             => open,
      owr_i                => (others => '1'),
      slave_i              => wb_slave_in,
      slave_o              => wb_slave_out,
      aux_master_o         => open,
      aux_master_i         => cc_dummy_master_in,
      wrf_src_o            => open,
      wrf_src_i            => c_dummy_src_in,
      wrf_snk_o            => open,
      wrf_snk_i            => c_dummy_snk_in,
      timestamps_o         => open,
      timestamps_ack_i     => '1',
      fc_tx_pause_req_i    => '0',
      fc_tx_pause_delay_i  => (others => '0'),
      fc_tx_pause_ready_o  => open,
      tm_link_up_o         => open,
      tm_dac_value_o       => open,
      tm_dac_wr_o          => open,
      tm_clk_aux_lock_en_i => (others => '0'),
      tm_clk_aux_locked_o  => open,
      tm_time_valid_o      => tm_time_valid_o,
      tm_tai_o             => open,
      tm_cycles_o          => open,
      pps_p_o              => open,
      pps_led_o            => open,
      dio_o                => open,
      rst_aux_n_o          => open,
      link_ok_o            => open);

  wb_slave_in.cyc <= wb_cyc_i;
  wb_slave_in.stb <= wb_stb_i;
  wb_slave_in.adr <= wb_adr_i;
  wb_slave_in.sel <= wb_sel_i;
  wb_slave_in.we  <= wb_we_i;
  wb_slave_in.dat <= wb_dat_i;

  wb_ack_o   <= wb_slave_out.ack;
  wb_err_o   <= wb_slave_out.err;
  wb_rty_o   <= wb_slave_out.rty;
  wb_stall_o <= wb_slave_out.stall;
  wb_int_o   <= wb_slave_out.int;
  wb_dat_o   <= wb_slave_out.dat;


end architecture struct;
