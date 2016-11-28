library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wishbone_pkg.all;

package wr_board_pkg is

  component xwrc_board_vfchd is
    generic (
      g_simulation     : integer := 0;
      g_fabric_iface   : string  := "plain";
      g_streamer_width : integer := 32;
      g_dpram_initf    : string  := "default");
    port (
      clk_board_125m_i  : in    std_logic;
      clk_board_20m_i   : in    std_logic;
      areset_n_i        : in    std_logic;
      clk_sys_62m5_o    : out   std_logic;
      clk_ref_125m_o    : out   std_logic;
      rst_sys_62m5_o    : out   std_logic;
      dac_ref_sync_n_o  : out   std_logic;
      dac_dmtd_sync_n_o : out   std_logic;
      dac_din_o         : out   std_logic;
      dac_sclk_o        : out   std_logic;
      sfp_tx_o          : out   std_logic;
      sfp_rx_i          : in    std_logic;
      sfp_det_valid_i   : in    std_logic;
      sfp_data_i        : in    std_logic_vector (127 downto 0);
      eeprom_sda_b      : inout std_logic;
      eeprom_scl_o      : out   std_logic;
      onewire_i         : in    std_logic;
      onewire_oen_o     : out   std_logic;
      wb_adr_i          : in    std_logic_vector(c_wishbone_address_width-1 downto 0)   := (others => '0');
      wb_dat_i          : in    std_logic_vector(c_wishbone_data_width-1 downto 0)      := (others => '0');
      wb_dat_o          : out   std_logic_vector(c_wishbone_data_width-1 downto 0);
      wb_sel_i          : in    std_logic_vector(c_wishbone_address_width/8-1 downto 0) := (others => '0');
      wb_we_i           : in    std_logic                                               := '0';
      wb_cyc_i          : in    std_logic                                               := '0';
      wb_stb_i          : in    std_logic                                               := '0';
      wb_ack_o          : out   std_logic;
      wb_int_o          : out   std_logic;
      wb_err_o          : out   std_logic;
      wb_rty_o          : out   std_logic;
      wb_stall_o        : out   std_logic;
      wrf_src_adr       : out   std_logic_vector(1 downto 0);
      wrf_src_dat       : out   std_logic_vector(15 downto 0);
      wrf_src_cyc       : out   std_logic;
      wrf_src_stb       : out   std_logic;
      wrf_src_we        : out   std_logic;
      wrf_src_sel       : out   std_logic_vector(1 downto 0);
      wrf_src_ack       : in    std_logic;
      wrf_src_stall     : in    std_logic;
      wrf_src_err       : in    std_logic;
      wrf_src_rty       : in    std_logic;
      wrf_snk_adr       : in    std_logic_vector(1 downto 0);
      wrf_snk_dat       : in    std_logic_vector(15 downto 0);
      wrf_snk_cyc       : in    std_logic;
      wrf_snk_stb       : in    std_logic;
      wrf_snk_we        : in    std_logic;
      wrf_snk_sel       : in    std_logic_vector(1 downto 0);
      wrf_snk_ack       : out   std_logic;
      wrf_snk_stall     : out   std_logic;
      wrf_snk_err       : out   std_logic;
      wrf_snk_rty       : out   std_logic;
      trans_tx_data_i   : in    std_logic_vector(g_streamer_width-1 downto 0)           := (others => '0');
      trans_tx_valid_i  : in    std_logic                                               := '0';
      trans_tx_dreq_o   : out   std_logic;
      trans_tx_last_i   : in    std_logic                                               := '1';
      trans_tx_flush_i  : in    std_logic                                               := '0';
      trans_rx_first_o  : out   std_logic;
      trans_rx_last_o   : out   std_logic;
      trans_rx_data_o   : out   std_logic_vector(g_streamer_width-1 downto 0);
      trans_rx_valid_o  : out   std_logic;
      trans_rx_dreq_i   : in    std_logic                                               := '0';
      tm_time_valid_o   : out   std_logic;
      led_link_o        : out   std_logic;
      led_act_o         : out   std_logic);
  end component;

end wr_board_pkg;
