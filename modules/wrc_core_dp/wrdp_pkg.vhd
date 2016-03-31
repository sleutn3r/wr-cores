library ieee;
use ieee.std_logic_1164.all;

library work;
use work.genram_pkg.all;
use work.wishbone_pkg.all;
use work.syscdp_wbgen2_pkg.all;
use work.wr_fabric_pkg.all;
use work.endpoint_pkg.all;
use work.softpll_pkg.all;

package wrdp_pkg is

  -----------------------------------------------------------------------------
  -- PERIPHERIALS
  -----------------------------------------------------------------------------
  component xwrdp_syscon_wb
    generic(
      g_interface_mode      : t_wishbone_interface_mode;
      g_address_granularity : t_wishbone_address_granularity
      );
    port (
      rst_n_i   : in std_logic;
      clk_sys_i : in std_logic;

      slave_i : in  t_wishbone_slave_in;
      slave_o : out t_wishbone_slave_out;

      regs_i : in  t_syscdp_in_registers;
      regs_o : out t_syscdp_out_registers
      );
  end component;

  constant c_wrdp_syscon_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
        vendor_id => x"0000000000001103",  -- THU
        device_id => x"ff07fc47",
        version   => x"00000001",
        date      => x"20160305",
        name      => "WR-DP-Syscon       ")));


  constant cc_unused_master_in : t_wishbone_master_in :=
    ('1', '0', '0', '0', '0', cc_dummy_data);
    
  component wrdp_periph is
    generic(
      g_phys_uart       : boolean := true;
      g_virtual_uart    : boolean := false;
      g_cntr_period     : integer := 62500;
      g_mem_words       : integer := 16384;
      g_vuart_fifo_size : integer := 1024
      );
    port(
      clk_sys_i   : in  std_logic;
      rst_n_i     : in  std_logic;
      rst_net_n_o : out std_logic;
      rst_wrc_n_o : out std_logic;
      led_link_o  : out std_logic;
      led_stat_o  : out std_logic;
      fpga_scl_o  : out std_logic;
      fpga_scl_i  : in  std_logic;
      fpga_sda_o  : out std_logic;
      fpga_sda_i  : in  std_logic;
      sfp0_scl_o  : out std_logic;
      sfp0_scl_i  : in  std_logic;
      sfp0_sda_o  : out std_logic;
      sfp0_sda_i  : in  std_logic;
      sfp0_det_i  : in  std_logic;
      sfp1_scl_o  : out std_logic;
      sfp1_scl_i  : in  std_logic;
      sfp1_sda_o  : out std_logic;
      sfp1_sda_i  : in  std_logic;
      sfp1_det_i  : in  std_logic;
      memsize_i   : in  std_logic_vector(3 downto 0);
      spi_sclk_o  : out std_logic;
      spi_ncs_o   : out std_logic;
      spi_mosi_o  : out std_logic;
      spi_miso_i  : in  std_logic;
      slave_i     : in  t_wishbone_slave_in_array(0 to 2);
      slave_o     : out t_wishbone_slave_out_array(0 to 2);
      uart_rxd_i  : in  std_logic;
      uart_txd_o  : out std_logic;
      owr_pwren_o : out std_logic_vector(1 downto 0);
      owr_en_o    : out std_logic_vector(1 downto 0);
      owr_i       : in  std_logic_vector(1 downto 0)
      );
  end component;

  component xcute_dp is
    generic(
      g_simulation                : integer                        := 0;
      g_phys_uart                 : boolean                        := true;
      g_virtual_uart              : boolean                        := true;
      g_with_external_clock_input : boolean                        := true;
      g_aux_clks                  : integer                        := 0;
      g_ep_rxbuf_size             : integer                        := 1024;
      g_tx_runt_padding           : boolean                        := true;
      g_dpram_initf               : string                         := "default";
      g_dpram_size                : integer                        := 131072/4;  --in 32-bit words
      g_interface_mode            : t_wishbone_interface_mode      := PIPELINED;
      g_address_granularity       : t_wishbone_address_granularity := BYTE;
      g_etherbone_cfg_sdb         : t_sdb_device                   := c_wrdp_syscon_sdb;
      g_aux1_sdb                  : t_sdb_device                   ;
      g_aux2_sdb                  : t_sdb_device                   ;
      g_softpll_enable_debugger   : boolean                        := false;
      g_vuart_fifo_size           : integer                        := 1024;
      g_pcs_16bit                 : boolean                        := false);
    port(
      clk_sys_i            : in std_logic;
      clk_dmtd_i           : in std_logic := '0';
      clk_ref_i            : in std_logic;
      clk_aux_i            : in std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
      clk_ext_mul_i        : in std_logic := '0';
      clk_ext_mul_locked_i : in std_logic := '1';
      clk_ext_stopped_i    : in std_logic := '0';
      clk_ext_rst_o        : out std_logic;
      clk_ext_i            : in std_logic := '0';
      pps_ext_i            : in std_logic := '0';
      rst_n_i              : in std_logic;

      dac_hpll_load_p1_o   : out std_logic;
      dac_hpll_data_o      : out std_logic_vector(15 downto 0);
      dac_dpll_load_p1_o   : out std_logic;
      dac_dpll_data_o      : out std_logic_vector(15 downto 0);

      phy0_ref_clk_i        : in  std_logic                    := '0';
      phy0_tx_data_o        : out std_logic_vector(f_pcs_data_width(g_pcs_16bit)-1 downto 0);
      phy0_tx_k_o           : out std_logic_vector(f_pcs_k_width(g_pcs_16bit)-1 downto 0);
      phy0_tx_disparity_i   : in  std_logic                    := '0';
      phy0_tx_enc_err_i     : in  std_logic                    := '0';
      phy0_rx_data_i        : in  std_logic_vector(f_pcs_data_width(g_pcs_16bit)-1 downto 0) := (others=>'0');
      phy0_rx_rbclk_i       : in  std_logic                    := '0';
      phy0_rx_k_i           : in  std_logic_vector(f_pcs_k_width(g_pcs_16bit)-1 downto 0) := (others=>'0');
      phy0_rx_enc_err_i     : in  std_logic                    := '0';
      phy0_rx_bitslide_i    : in  std_logic_vector(f_pcs_bts_width(g_pcs_16bit)-1 downto 0) := (others=>'0');
      phy0_rst_o            : out std_logic;
      phy0_rdy_i            : in  std_logic := '1';
      phy0_loopen_o         : out std_logic;
      phy0_loopen_vec_o     : out std_logic_vector(2 downto 0);
      phy0_tx_prbs_sel_o    : out std_logic_vector(2 downto 0);
      phy0_sfp_tx_fault_i   : in std_logic := '0';
      phy0_sfp_los_i        : in std_logic := '0';
      phy0_sfp_tx_disable_o : out std_logic;

      phy1_ref_clk_i        : in  std_logic                    := '0';
      phy1_tx_data_o        : out std_logic_vector(f_pcs_data_width(g_pcs_16bit)-1 downto 0);
      phy1_tx_k_o           : out std_logic_vector(f_pcs_k_width(g_pcs_16bit)-1 downto 0);
      phy1_tx_disparity_i   : in  std_logic                    := '0';
      phy1_tx_enc_err_i     : in  std_logic                    := '0';
      phy1_rx_data_i        : in  std_logic_vector(f_pcs_data_width(g_pcs_16bit)-1 downto 0) := (others=>'0');
      phy1_rx_rbclk_i       : in  std_logic                    := '0';
      phy1_rx_k_i           : in  std_logic_vector(f_pcs_k_width(g_pcs_16bit)-1 downto 0) := (others=>'0');
      phy1_rx_enc_err_i     : in  std_logic                    := '0';
      phy1_rx_bitslide_i    : in  std_logic_vector(f_pcs_bts_width(g_pcs_16bit)-1 downto 0) := (others=>'0');
      phy1_rst_o            : out std_logic;
      phy1_rdy_i            : in  std_logic := '1';
      phy1_loopen_o         : out std_logic;
      phy1_loopen_vec_o     : out std_logic_vector(2 downto 0);
      phy1_tx_prbs_sel_o    : out std_logic_vector(2 downto 0);
      phy1_sfp_tx_fault_i   : in std_logic := '0';
      phy1_sfp_los_i        : in std_logic := '0';
      phy1_sfp_tx_disable_o : out std_logic;

      sfp0_led_o  : out std_logic;
      sfp0_scl_o  : out std_logic;
      sfp0_scl_i  : in  std_logic := 'H';
      sfp0_sda_o  : out std_logic;
      sfp0_sda_i  : in  std_logic := 'H';
      sfp0_det_i  : in  std_logic := '1';
      
      sfp1_led_o  : out std_logic;
      sfp1_scl_o  : out std_logic;
      sfp1_scl_i  : in  std_logic := 'H';
      sfp1_sda_o  : out std_logic;
      sfp1_sda_i  : in  std_logic := 'H';
      sfp1_det_i  : in  std_logic := '1';

      fpga_scl_o      : out std_logic;
      fpga_scl_i      : in  std_logic := 'H';
      fpga_sda_o      : out std_logic;
      fpga_sda_i      : in  std_logic := 'H';
      
      spi_sclk_o : out std_logic;
      spi_ncs_o  : out std_logic;
      spi_mosi_o : out std_logic;
      spi_miso_i : in  std_logic := '0';

      uart_rxd_i : in  std_logic := 'H';
      uart_txd_o : out std_logic;

      owr_pwren_o : out std_logic_vector(1 downto 0);
      owr_en_o    : out std_logic_vector(1 downto 0);
      owr_i       : in  std_logic_vector(1 downto 0) := "HH";

      wrc_slave_i : in  t_wishbone_slave_in := cc_dummy_slave_in;
      wrc_slave_o : out t_wishbone_slave_out;

      aux1_master_o : out t_wishbone_master_out;
      aux1_master_i : in  t_wishbone_master_in := cc_unused_master_in;

      aux2_master_o : out t_wishbone_master_out;
      aux2_master_i : in  t_wishbone_master_in := cc_unused_master_in;

      etherbone_cfg_master_o : out t_wishbone_master_out;
      etherbone_cfg_master_i : in  t_wishbone_master_in := cc_unused_master_in;

      etherbone_src_o : out t_wrf_source_out;
      etherbone_src_i : in  t_wrf_source_in := c_dummy_src_in;
      etherbone_snk_o : out t_wrf_sink_out;
      etherbone_snk_i : in  t_wrf_sink_in   := c_dummy_snk_in;

      ext_src_o : out t_wrf_source_out;
      ext_src_i : in  t_wrf_source_in := c_dummy_src_in;
      ext_snk_o : out t_wrf_sink_out;
      ext_snk_i : in  t_wrf_sink_in   := c_dummy_snk_in;

      fc_tx_pause_req_i   : in  std_logic                     := '0';
      fc_tx_pause_delay_i : in  std_logic_vector(15 downto 0) := x"0000";
      fc_tx_pause_ready_o : out std_logic;

      tm_link_up_o         : out std_logic;
      tm_dac_value_o       : out std_logic_vector(23 downto 0);
      tm_dac_wr_o          : out std_logic_vector(g_aux_clks-1 downto 0);
      tm_clk_aux_lock_en_i : in  std_logic_vector(g_aux_clks-1 downto 0) := (others => '0');
      tm_clk_aux_locked_o  : out std_logic_vector(g_aux_clks-1 downto 0);
      tm_time_valid_o      : out std_logic;
      tm_tai_o             : out std_logic_vector(39 downto 0);
      tm_cycles_o          : out std_logic_vector(27 downto 0);
      pps_p_o              : out std_logic;
      pps_led_o            : out std_logic;

      rst_aux_n_o : out std_logic);
  end component;

end wrdp_pkg;

package body wrdp_pkg is

end package body wrdp_pkg;
