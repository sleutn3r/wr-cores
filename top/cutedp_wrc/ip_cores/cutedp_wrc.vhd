library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gn4124_core_pkg.all;
use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wr_fabric_pkg.all;
use work.wr_xilinx_pkg.all;
use work.wishbone_pkg.all;
use work.etherbone_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity cutedp_wrc is
  generic
    (
      g_etherbone_enable: boolean:= true;
      g_multiboot_enable: boolean:= true
     );
  port
    (
      clk_20m_i     : in std_logic;
      clk_sys_i     : in std_logic;     -- 62.5m system clock, from pll drived by clk_125m_pllref
      clk_dmtd_i    : in std_logic;     -- 62.5m dmtd clock, from pll drived by clk_20m_vcxo
      clk_ref_i     : in std_logic;     -- 125m reference clock
--      clk_gtp0_i     : in std_logic;     -- dedicated clock for xilinx gtp transceiver
      clk_gtp1_i     : in std_logic;     -- dedicated clock for xilinx gtp transceiver

      rst_n_i  		: in std_logic;

      -- font panel leds
      sfp0_led_o : out std_logic;
      sfp1_led_o : out std_logic;

      dac_sclk_o  : out std_logic;
      dac_din_o   : out std_logic;
      dac_clr_n_o : out std_logic;
      dac_ldac_n_o : out std_logic;
      dac_sync_n_o : out std_logic;

      fpga_scl_i : in  std_logic;
      fpga_scl_o : out std_logic;
      fpga_sda_i : in  std_logic;
      fpga_sda_o : out std_logic;

      --button1_i : in std_logic := 'h';
      --button2_i : in std_logic := 'h';

      ----------------------------------------
      -- Flash memory SPI
      ---------------------------------------
      fpga_prom_cclk_o       : out std_logic;
      fpga_prom_cso_b_n_o    : out std_logic;
      fpga_prom_mosi_o       : out std_logic;
      fpga_prom_miso_i       : in  std_logic:='1';

      thermo_id_i : in  std_logic;
      thermo_id_o : out std_logic;      -- 1-wire interface to ds18b20

      -------------------------------------------------------------------------
      -- sfp pins
      -------------------------------------------------------------------------
      --sfp0_txp_o : out std_logic;
      --sfp0_txn_o : out std_logic;
      --sfp0_rxp_i : in std_logic;
      --sfp0_rxn_i : in std_logic;
      --sfp0_mod_def0_i    : in    std_logic;  -- sfp detect
      --sfp0_mod_def1_i    : in std_logic;  -- scl
      --sfp0_mod_def1_o    : out std_logic;  -- scl
      --sfp0_mod_def2_i    : in std_logic;  -- sda
      --sfp0_mod_def2_o    : out std_logic;  -- sda
      --sfp0_rate_select_i : in std_logic;
      --sfp0_rate_select_o : out std_logic;
      --sfp0_tx_fault_i    : in    std_logic;
      --sfp0_tx_disable_o  : out   std_logic;
      --sfp0_los_i         : in    std_logic;

      sfp1_txp_o : out std_logic;
      sfp1_txn_o : out std_logic;
      sfp1_rxp_i : in std_logic;
      sfp1_rxn_i : in std_logic;
      sfp1_mod_def0_i    : in    std_logic;  -- sfp detect
      sfp1_mod_def1_i    : in std_logic;  -- scl
      sfp1_mod_def1_o    : out std_logic;  -- scl
      sfp1_mod_def2_i    : in std_logic;  -- sda
      sfp1_mod_def2_o    : out std_logic;  -- sda
      sfp1_rate_select_i : in std_logic;
      sfp1_rate_select_o : out std_logic;
      sfp1_tx_fault_i    : in    std_logic;
      sfp1_tx_disable_o  : out   std_logic;
      sfp1_los_i         : in    std_logic;

      pps_o : out std_logic;
      tm_time_valid_o      : out std_logic;
      tm_tai_o             : out std_logic_vector(39 downto 0);
      tm_cycles_o          : out std_logic_vector(27 downto 0);

      -----------------------------------------
      --uart
      -----------------------------------------
      uart_rxd_i : in  std_logic;
      uart_txd_o : out std_logic;

      ------------------------------------------
      -- external module
      ------------------------------------------
      ext_snk_i : in  t_wrf_sink_in;
      ext_snk_o : out t_wrf_sink_out;

      ext_src_o : out t_wrf_source_out;
      ext_src_i : in  t_wrf_source_in;

      ext_master_i : in t_wishbone_master_in:=cc_unused_master_in;
      ext_master_o : out t_wishbone_master_out
      );

end cutedp_wrc;

architecture rtl of cutedp_wrc is

  ------------------------------------------------------------------------------
  -- components declaration
  ------------------------------------------------------------------------------
  component ext_pll_10_to_125m
    port (
      clk_ext_i     : in  std_logic;
      clk_ext_mul_o : out std_logic;
      rst_a_i       : in  std_logic;
      clk_in_stopped_o: out  std_logic;
      locked_o      : out std_logic);
  end component;

  -- MultiBoot component
  -- use: remotely reprogram the FPGA
  component wb_xil_multiboot is
    port
    (
      -- Clock and reset input ports
      clk_i   : in  std_logic;
      rst_n_i : in  std_logic;

      -- Wishbone ports
      wbs_i   : in  t_wishbone_slave_in;
      wbs_o   : out t_wishbone_slave_out;

      -- SPI ports
      spi_cs_n_o : out std_logic;
      spi_sclk_o : out std_logic;
      spi_mosi_o : out std_logic;
      spi_miso_i : in  std_logic
    );
  end component wb_xil_multiboot;

  ------------------------------------------------------------------------------
  -- signals declaration
  ------------------------------------------------------------------------------
  -- reset
  signal rst_a : std_logic;
  signal rst   : std_logic;

  signal dac_rst_n        : std_logic;
  signal led_divider      : unsigned(23 downto 0);

  signal dac_hpll_load_p1 : std_logic;
  signal dac_dpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_data    : std_logic_vector(15 downto 0);

  signal owr_en : std_logic_vector(1 downto 0);
  signal owr_i  : std_logic_vector(1 downto 0);

  signal pps     : std_logic;
  signal pps_led : std_logic;
  
  signal led_red : std_logic;
  signal led_green : std_logic;

  --signal phy0_tx_data      : std_logic_vector(7 downto 0);
  --signal phy0_tx_k         : std_logic_vector(0 downto 0);
  --signal phy0_tx_disparity : std_logic;
  --signal phy0_tx_enc_err   : std_logic;
  --signal phy0_rx_data      : std_logic_vector(7 downto 0);
  --signal phy0_rx_rbclk     : std_logic;
  --signal phy0_rx_k         : std_logic_vector(0 downto 0);
  --signal phy0_rx_enc_err   : std_logic;
  --signal phy0_rx_bitslide  : std_logic_vector(3 downto 0);
  --signal phy0_rst          : std_logic;
  --signal phy0_loopen       : std_logic;
  --signal phy0_loopen_vec   : std_logic_vector(2 downto 0);
  --signal phy0_prbs_sel     : std_logic_vector(2 downto 0);
  --signal phy0_rdy          : std_logic;

  signal phy1_tx_data      : std_logic_vector(7 downto 0);
  signal phy1_tx_k         : std_logic_vector(0 downto 0);
  signal phy1_tx_disparity : std_logic;
  signal phy1_tx_enc_err   : std_logic;
  signal phy1_rx_data      : std_logic_vector(7 downto 0);
  signal phy1_rx_rbclk     : std_logic;
  signal phy1_rx_k         : std_logic_vector(0 downto 0);
  signal phy1_rx_enc_err   : std_logic;
  signal phy1_rx_bitslide  : std_logic_vector(3 downto 0);
  signal phy1_rst          : std_logic;
  signal phy1_loopen       : std_logic;
  signal phy1_loopen_vec   : std_logic_vector(2 downto 0);
  signal phy1_prbs_sel     : std_logic_vector(2 downto 0);
  signal phy1_rdy          : std_logic;

  --signal button1_synced : std_logic_vector(2 downto 0);

  signal wrc_slave_i : t_wishbone_slave_in;
  signal wrc_slave_o : t_wishbone_slave_out;

  signal etherbone_rst_n   : std_logic;
  signal etherbone_src_o : t_wrf_source_out;
  signal etherbone_src_i  : t_wrf_source_in;
  signal etherbone_snk_o : t_wrf_sink_out;
  signal etherbone_snk_i  : t_wrf_sink_in;
  signal etherbone_wb_o  : t_wishbone_master_out;
  signal etherbone_wb_i   : t_wishbone_master_in;
  signal etherbone_cfg_slave_i  : t_wishbone_slave_in;
  signal etherbone_cfg_slave_o : t_wishbone_slave_out:=cc_unused_master_in;

  signal multiboot_in  : t_wishbone_slave_in;
  signal multiboot_out : t_wishbone_slave_out;
  signal multiboot_wb_in   : t_wishbone_master_in;
  signal multiboot_wb_out  : t_wishbone_master_out;

  --signal ext_pll_reset : std_logic;
  --signal clk_ext, clk_ext_mul       : std_logic;
  --signal clk_ext_mul_locked         : std_logic;
  --signal clk_ext_stopped            : std_logic;
  --signal clk_ext_rst                : std_logic;
  --signal clk_ref_div2               : std_logic;

constant c_ext_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4",                 -- 8/16/32-bit port granularity
    sdb_component => (
    addr_first  => x"0000000000000000",
    addr_last   => x"00000000000000ff",
    product     => (
    vendor_id => x"0000000000001103",  -- thu
    device_id => x"c0413599",
    version   => x"00000001",
    date      => x"20160424",
    name      => "WR-Ext-Config      ")));

constant c_wrc_multiboot_sdb : t_sdb_device := (
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
      device_id => x"deadbeaf",
      version   => x"00000001",
      date      => x"20141115",
      name      => "SPI-flash+Multiboot")));

begin

  --u_ext_pll : ext_pll_10_to_125m
  --  port map (
  --    clk_ext_i        => clk_ext,
  --    clk_ext_mul_o    => clk_ext_mul,
  --    rst_a_i          => ext_pll_reset,
  --    clk_in_stopped_o => clk_ext_stopped,
  --    locked_o         => clk_ext_mul_locked);

  --u_extend_ext_reset : gc_extend_pulse
  --  generic map (
  --    g_width => 1000)
  --  port map (
  --    clk_i      => clk_sys_i,
  --    rst_n_i    => rst_n_i,
  --    pulse_i    => clk_ext_rst,
  --    extended_o => ext_pll_reset);

process(clk_sys_i)
begin
  if rising_edge(clk_sys_i) then
    led_divider <= led_divider + 1;
  end if;
end process;

  thermo_id_o <= owr_en(0);
  owr_i(0)    <= thermo_id_i;
  owr_i(1)    <= '0';

  pps_o <= pps;
  sfp0_led_o <= led_red;
  sfp1_led_o <= led_green;

u_wr_core : xcute_core
generic map (
    g_simulation                => 0,
    g_with_external_clock_input => true,
    --
    g_phys_uart                 => true,
    g_virtual_uart              => true,
    g_aux_clks                  => 0,
    g_ep_rxbuf_size             => 512,
    g_tx_runt_padding           => true,
    g_pcs_16bit                 => false,
    g_dpram_initf               => "",
    g_etherbone_enable          => g_etherbone_enable,
    g_etherbone_sdb             => c_etherbone_sdb,
    g_ext_sdb                   => c_ext_sdb,
    g_aux_sdb                   => c_wrc_multiboot_sdb,
    g_dpram_size                => 131072/4,
    g_interface_mode            => pipelined,
    g_address_granularity       => byte)
port map (
    clk_sys_i             => clk_sys_i,
    clk_dmtd_i            => clk_dmtd_i,
    clk_ref_i             => clk_ref_i,
    clk_aux_i             => (others => '0'),
    clk_ext_i             => '0',
    clk_ext_mul_i         => '0',
    clk_ext_mul_locked_i  => '1',
    clk_ext_stopped_i     => '0',
    clk_ext_rst_o         => open,
    pps_ext_i             => '0',
    rst_n_i               => rst_n_i,

    dac_hpll_load_p1_o    => dac_hpll_load_p1,
    dac_hpll_data_o       => dac_hpll_data,
    dac_dpll_load_p1_o    => dac_dpll_load_p1,
    dac_dpll_data_o       => dac_dpll_data,

--    phy_ref_clk_i      => clk_ref_i,
--    phy_tx_data_o      => phy0_tx_data,
--    phy_tx_k_o         => phy0_tx_k,
--    phy_tx_disparity_i => phy0_tx_disparity,
--    phy_tx_enc_err_i   => phy0_tx_enc_err,
--    phy_rx_data_i      => phy0_rx_data,
--    phy_rx_rbclk_i     => phy0_rx_rbclk,
--    phy_rx_k_i         => phy0_rx_k,
--    phy_rx_enc_err_i   => phy0_rx_enc_err,
--    phy_rx_bitslide_i  => phy0_rx_bitslide,
--    phy_rst_o          => phy0_rst,
--    phy_loopen_o       => phy0_loopen,
--    phy_loopen_vec_o   => phy0_loopen_vec,
--    phy_rdy_i          => phy0_rdy,
--    phy_sfp_tx_fault_i => sfp0_tx_fault_i,
--    phy_sfp_los_i      => sfp0_los_i,
--    phy_sfp_tx_disable_o => sfp0_tx_disable_o,
--    phy_tx_prbs_sel_o  =>  phy0_prbs_sel,

    phy_ref_clk_i      => clk_ref_i,
    phy_tx_data_o      => phy1_tx_data,
    phy_tx_k_o         => phy1_tx_k,
    phy_tx_disparity_i => phy1_tx_disparity,
    phy_tx_enc_err_i   => phy1_tx_enc_err,
    phy_rx_data_i      => phy1_rx_data,
    phy_rx_rbclk_i     => phy1_rx_rbclk,
    phy_rx_k_i         => phy1_rx_k,
    phy_rx_enc_err_i   => phy1_rx_enc_err,
    phy_rx_bitslide_i  => phy1_rx_bitslide,
    phy_rst_o          => phy1_rst,
    phy_loopen_o       => phy1_loopen,
    phy_loopen_vec_o   => phy1_loopen_vec,
    phy_rdy_i          => phy1_rdy,
    phy_sfp_tx_fault_i => sfp1_tx_fault_i,
    phy_sfp_los_i      => sfp1_los_i,
    phy_sfp_tx_disable_o => sfp1_tx_disable_o,
    phy_tx_prbs_sel_o  =>  phy1_prbs_sel,

    led_act_o  => led_red,
    led_link_o => led_green,

    scl_o      => fpga_scl_o,
    scl_i      => fpga_scl_i,
    sda_o      => fpga_sda_o,
    sda_i      => fpga_sda_i,
    btn1_i     => open,
    btn2_i     => open,
    spi_sclk_o  => open,
    spi_ncs_o   => open,
    spi_mosi_o  => open,
    spi_miso_i  => '0',

--    sfp_scl_o  => sfp0_mod_def1_o,
--    sfp_scl_i  => sfp0_mod_def1_i,
--    sfp_sda_o  => sfp0_mod_def2_o,
--    sfp_sda_i  => sfp0_mod_def2_i,
--    sfp_det_i  => sfp0_mod_def0_i,

    sfp_scl_o  => sfp1_mod_def1_o,
    sfp_scl_i  => sfp1_mod_def1_i,
    sfp_sda_o  => sfp1_mod_def2_o,
    sfp_sda_i  => sfp1_mod_def2_i,
    sfp_det_i  => sfp1_mod_def0_i,

    uart_rxd_i => uart_rxd_i,
    uart_txd_o => uart_txd_o,

    owr_en_o => owr_en,
    owr_i    => owr_i,

    slave_i => wrc_slave_i,
    slave_o => wrc_slave_o,

    etherbone_master_o=> etherbone_cfg_slave_i,
    etherbone_master_i=> etherbone_cfg_slave_o,
    etherbone_src_o => etherbone_snk_i,
    etherbone_src_i => etherbone_snk_o,
    etherbone_snk_o => etherbone_src_i,
    etherbone_snk_i => etherbone_src_o,

    ext_master_o => ext_master_o,
    ext_master_i => ext_master_i,
    ext_src_o => ext_src_o,
    ext_src_i => ext_src_i,
    ext_snk_o => ext_snk_o,
    ext_snk_i => ext_snk_i,

    aux_master_o => multiboot_in,
    aux_master_i => multiboot_out,

    tm_dac_value_o       => open,
    tm_dac_wr_o          => open,
    tm_clk_aux_lock_en_i => (others => '0'),
    tm_clk_aux_locked_o  => open,
    tm_time_valid_o      => tm_time_valid_o,
    tm_tai_o             => tm_tai_o,
    tm_cycles_o          => tm_cycles_o,
    pps_p_o              => pps,
    pps_led_o            => pps_led,

    rst_aux_n_o => etherbone_rst_n
);

etherbone_gen: if (g_etherbone_enable = true) generate

  etherbone : eb_slave_core
  generic map (
      g_sdb_address => x"0000000000030000")
  port map (
      clk_i       => clk_sys_i,
      nrst_i      => etherbone_rst_n,
      src_o       => etherbone_src_o,
      src_i       => etherbone_src_i,
      snk_o       => etherbone_snk_o,
      snk_i       => etherbone_snk_i,
      cfg_slave_o => etherbone_cfg_slave_o,
      cfg_slave_i => etherbone_cfg_slave_i,
      master_o    => etherbone_wb_o,
      master_i    => etherbone_wb_i
  );

  ---------------------
  masterbar : xwb_crossbar
  generic map (
      g_num_masters => 1,
      g_num_slaves  => 1,
      g_registered  => false,
      g_address     => (0 => x"00000000"),
      g_mask        => (0 => x"00000000"))
  port map (
      clk_sys_i   => clk_sys_i,
      rst_n_i     => rst_n_i,
      slave_i(0)  => etherbone_wb_o,
      slave_o(0)  => etherbone_wb_i,
      master_i(0) => wrc_slave_o,
      master_o(0) => wrc_slave_i
  );

end generate;

multiboot_gen:if (g_etherbone_enable=true and g_multiboot_enable=true) generate

------------------------------------------------------------------------
      -- multiboot modules --
------------------------------------------------------------------------  
  cmp_clock_crossing: xwb_clock_crossing
      port map
      (
        slave_clk_i     => clk_sys_i,
        slave_rst_n_i   => rst_n_i,
        slave_i         => multiboot_in,
        slave_o         => multiboot_out,

        master_clk_i    => clk_20m_i,
        master_rst_n_i  => rst_n_i,
        master_i        => multiboot_wb_in,
        master_o        => multiboot_wb_out
      );

  cmp_multiboot : xwb_xil_multiboot
    port map
    (
      clk_i   => clk_20m_i,
      rst_n_i => rst_n_i,
      wbs_i   => multiboot_wb_out,
      wbs_o   => multiboot_wb_in,
      spi_cs_n_o => fpga_prom_cso_b_n_o,
      spi_sclk_o => fpga_prom_cclk_o,
      spi_mosi_o => fpga_prom_mosi_o,
      spi_miso_i => fpga_prom_miso_i
    );

end generate;

  ---------------------

u_gtp : wr_gtp_phy_spartan6
generic map (
	g_enable_ch0 => 0,
	g_enable_ch1 => 1,
	g_simulation => 0)
port map (
	--      gtp_clk_i => clk_gtp0_i,
	gtp_clk_i => clk_gtp1_i,

	-- ch0_ref_clk_i      => clk_ref_i,
	-- ch0_tx_data_i      => phy0_tx_data,
	-- ch0_tx_k_i         => phy0_tx_k(0),
	-- ch0_tx_disparity_o => phy0_tx_disparity,
	-- ch0_tx_enc_err_o   => phy0_tx_enc_err,
	-- ch0_rx_rbclk_o     => phy0_rx_rbclk,
	-- ch0_rx_data_o      => phy0_rx_data,
	-- ch0_rx_k_o         => phy0_rx_k(0),
	-- ch0_rx_enc_err_o   => phy0_rx_enc_err,
	-- ch0_rx_bitslide_o  => phy0_rx_bitslide,
	-- ch0_rst_i          => phy0_rst,
	-- ch0_loopen_i       => phy0_loopen,
	-- ch0_loopen_vec_i   => phy0_loopen_vec,
	-- ch0_tx_prbs_sel_i  => phy0_prbs_sel,
	-- ch0_rdy_o          => phy0_rdy,
	-- pad_txn0_o         => sfp0_txn_o,
	-- pad_txp0_o         => sfp0_txp_o,
	-- pad_rxn0_i         => sfp0_rxn_i,
	-- pad_rxp0_i         => sfp0_rxp_i,

	ch1_ref_clk_i      => clk_ref_i,
	ch1_tx_data_i      => phy1_tx_data,
	ch1_tx_k_i         => phy1_tx_k(0),
	ch1_tx_disparity_o => phy1_tx_disparity,
	ch1_tx_enc_err_o   => phy1_tx_enc_err,
	ch1_rx_rbclk_o     => phy1_rx_rbclk,
	ch1_rx_data_o      => phy1_rx_data,
	ch1_rx_k_o         => phy1_rx_k(0),
	ch1_rx_enc_err_o   => phy1_rx_enc_err,
	ch1_rx_bitslide_o  => phy1_rx_bitslide,
	ch1_rst_i          => phy1_rst,
	ch1_loopen_i       => phy1_loopen,
	ch1_loopen_vec_i   => phy1_loopen_vec,
	ch1_tx_prbs_sel_i  => phy1_prbs_sel,
	ch1_rdy_o          => phy1_rdy,
	pad_txn1_o         => sfp1_txn_o,
	pad_txp1_o         => sfp1_txp_o,
	pad_rxn1_i         => sfp1_rxn_i,
	pad_rxp1_i         => sfp1_rxp_i,

	ch0_ref_clk_i      => clk_ref_i,
	ch0_tx_data_i      => x"00",
	ch0_tx_k_i         => '0',
	ch0_tx_disparity_o => open,
	ch0_tx_enc_err_o   => open,
	ch0_rx_data_o      => open,
	ch0_rx_rbclk_o     => open,
	ch0_rx_k_o         => open,
	ch0_rx_enc_err_o   => open,
	ch0_rx_bitslide_o  => open,
	ch0_rst_i          => '1',
	ch0_loopen_i       => '0',
	ch0_loopen_vec_i   => (others=>'0'),
	ch0_tx_prbs_sel_i  => (others=>'0'),
	ch0_rdy_o          => open,
	pad_txn0_o         => open,
	pad_txp0_o         => open,
	pad_rxn0_i         => '0',
	pad_rxp0_i         => '0'

	--ch1_ref_clk_i      => clk_ref_i,
	--ch1_tx_data_i      => x"00",
	--ch1_tx_k_i         => '0',
	--ch1_tx_disparity_o => open,
	--ch1_tx_enc_err_o   => open,
	--ch1_rx_data_o      => open,
	--ch1_rx_rbclk_o     => open,
	--ch1_rx_k_o         => open,
	--ch1_rx_enc_err_o   => open,
	--ch1_rx_bitslide_o  => open,
	--ch1_rst_i          => '1',
	--ch1_loopen_i       => '0',
	--ch1_loopen_vec_i   => (others=>'0'),
	--ch1_tx_prbs_sel_i  => (ot hers=>'0'),
	--ch1_rdy_o          => open,
	--pad_txn1_o         => open,
	--pad_txp1_o         => open,
	--pad_rxn1_i         => '0',
	--pad_rxp1_i         => '0'
);

u_dac_arb : cute_serial_dac_arb
generic map (
    g_invert_sclk    => false,
    g_num_extra_bits => 8)
port map (
    clk_i   => clk_sys_i,
    rst_n_i => rst_n_i,
    val1_i  => dac_hpll_data,
    load1_i => dac_hpll_load_p1,
    val2_i  => dac_dpll_data,
    load2_i => dac_dpll_load_p1,
    dac_sync_n_o  => dac_sync_n_o,
    dac_ldac_n_o  => dac_ldac_n_o,
    dac_clr_n_o   => dac_clr_n_o,
    dac_sclk_o    => dac_sclk_o,
    dac_din_o     => dac_din_o
);

end rtl;
