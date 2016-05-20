
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gn4124_core_pkg.all;
use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wr_fabric_pkg.all;
use work.wr_xilinx_pkg.all;
use work.etherbone_pkg.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.wishbone_pkg.all;


entity cute_wrc is
  generic
    (
      g_etherbone_enable: boolean:= false
     );
  port
    (
      clk_sys_i     : in std_logic;     -- 62.5m system clock, from pll drived by clk_125m_pllref
      clk_dmtd_i    : in std_logic;     -- 62.5m dmtd clock, from pll drived by clk_20m_vcxo
      clk_ref_i     : in std_logic;     -- 125m reference clock
      clk_gtp_i     : in std_logic;     -- dedicated clock for xilinx gtp transceiver

      rst_n_i  		: in std_logic;

      -- font panel leds
      led_red   : out std_logic;
      led_green : out std_logic;
      led_test  : out std_logic;

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

      --spi_sclk_o : out std_logic;
      --spi_ncs_o  : out std_logic;
      --spi_mosi_o : out std_logic;
      --spi_miso_i : in  std_logic := 'l';

      thermo_id_i : in  std_logic;
      thermo_id_o : out std_logic;      -- 1-wire interface to ds18b20

      -------------------------------------------------------------------------
      -- sfp pins
      -------------------------------------------------------------------------

      sfp_txp_o : out std_logic;
      sfp_txn_o : out std_logic;

      sfp_rxp_i : in std_logic;
      sfp_rxn_i : in std_logic;

      sfp_mod_def0_i    : in    std_logic;  -- sfp detect
      sfp_mod_def1_i    : in std_logic;  -- scl
      sfp_mod_def1_o    : out std_logic;  -- scl
      sfp_mod_def2_i    : in std_logic;  -- sda
      sfp_mod_def2_o    : out std_logic;  -- sda
      sfp_rate_select_i : in std_logic;
      sfp_rate_select_o : out std_logic;
      sfp_tx_fault_i    : in    std_logic;
      sfp_tx_disable_o  : out   std_logic;
      sfp_los_i         : in    std_logic;

      pps_o : out std_logic;
      tm_time_valid_o      : out std_logic;
      tm_tai_o             : out std_logic_vector(39 downto 0);
      tm_cycles_o          : out std_logic_vector(27 downto 0);

      -----------------------------------------
      --uart
      -----------------------------------------
      uart_rxd_i : in  std_logic;
      uart_txd_o : out std_logic;

      ext_snk_i : in  t_wrf_sink_in;
      ext_snk_o : out t_wrf_sink_out;

      ext_src_o : out t_wrf_source_out;
      ext_src_i : in  t_wrf_source_in;

      ext_cfg_master_i : in t_wishbone_master_in:=cc_unused_master_in;
      ext_cfg_master_o : out t_wishbone_master_out;
			aux_master_i : in t_wishbone_master_in:=cc_dummy_master_in;
      aux_master_o : out t_wishbone_master_out
      );

end cute_wrc;

architecture rtl of cute_wrc is

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

  ------------------------------------------------------------------------------
  -- signals declaration
  ------------------------------------------------------------------------------

  -- dedicated clock for gtp transceiver
  signal gtp_dedicated_clk : std_logic;

  -- reset
  signal rst_a : std_logic;
  signal rst   : std_logic;

  -- spi
  signal spi_slave_select : std_logic_vector(7 downto 0);


  signal pllout_clk_sys       : std_logic;
  signal pllout_clk_dmtd      : std_logic;
  signal pllout_clk_fb_pllref : std_logic;
  signal pllout_clk_fb_dmtd   : std_logic;

  signal clk_20m_vcxo_buf : std_logic;
  signal clk_125m_pllref  : std_logic;
  signal clk_sys          : std_logic;
  signal clk_dmtd         : std_logic;
  signal dac_rst_n        : std_logic;
  signal led_divider      : unsigned(23 downto 0);

  signal wrc_scl_o : std_logic;
  signal wrc_scl_i : std_logic;
  signal wrc_sda_o : std_logic;
  signal wrc_sda_i : std_logic;
  signal sfp_scl_o : std_logic;
  signal sfp_scl_i : std_logic;
  signal sfp_sda_o : std_logic;
  signal sfp_sda_i : std_logic;
  --signal dio       : std_logic_vector(3 downto 0);

  signal dac_hpll_load_p1 : std_logic;
  signal dac_dpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_data    : std_logic_vector(15 downto 0);

  signal pps     : std_logic;
  signal pps_led : std_logic;

  signal phy_tx_data      : std_logic_vector(7 downto 0);
  signal phy_tx_k         : std_logic_vector(0 downto 0);
  signal phy_tx_disparity : std_logic;
  signal phy_tx_enc_err   : std_logic;
  signal phy_rx_data      : std_logic_vector(7 downto 0);
  signal phy_rx_rbclk     : std_logic;
  signal phy_rx_k         : std_logic_vector(0 downto 0);
  signal phy_rx_enc_err   : std_logic;
  signal phy_rx_bitslide  : std_logic_vector(3 downto 0);
  signal phy_rst          : std_logic;
  signal phy_loopen       : std_logic;
  signal phy_loopen_vec   : std_logic_vector(2 downto 0);
  signal phy_prbs_sel     : std_logic_vector(2 downto 0);
  signal phy_rdy          : std_logic;

  signal local_reset_n  : std_logic;
  --signal button1_synced : std_logic_vector(2 downto 0);

  signal wrc_slave_i : t_wishbone_slave_in;
  signal wrc_slave_o : t_wishbone_slave_out;

  signal owr_en : std_logic_vector(1 downto 0);
  signal owr_i  : std_logic_vector(1 downto 0);

  signal wb_adr : std_logic_vector(31 downto 0);  --c_bar0_aperture-priv_log2_ceil(c_csr_wb_slaves_nb+1)-1 downto 0);

  signal etherbone_rst_n   : std_logic;
  signal etherbone_src_out : t_wrf_source_out;
  signal etherbone_src_in  : t_wrf_source_in;
  signal etherbone_snk_out : t_wrf_sink_out;
  signal etherbone_snk_in  : t_wrf_sink_in;
  signal etherbone_wb_out  : t_wishbone_master_out;
  signal etherbone_wb_in   : t_wishbone_master_in;
  signal etherbone_cfg_slave_in  : t_wishbone_slave_in;
  signal etherbone_cfg_slave_out : t_wishbone_slave_out:=cc_unused_master_in;

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
    name      => "wr-ext-config      ")));

  constant c_null_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
        vendor_id => x"0000000000001103",  -- thu
        device_id => x"c0403598",
        version   => x"00000001",
        date      => x"20160324",
        name      => "wr-null            ")));

	constant c_wrc_tdc_cm_sdb : t_sdb_device := (
    abi_class     => x"0000",              -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7",                 -- 8/16/32-bit port granularity
    sdb_component => (
      addr_first  => x"0000000000000000",
      addr_last   => x"00000000000000ff",
      product     => (
        vendor_id => x"0000000000001103",  -- thu
        device_id => x"f0443598",
        version   => x"00000001",
        date      => x"20160419",
        name      => "wr-tdc-control     ")));

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
  --    clk_i      => clk_sys,
  --    rst_n_i    => local_reset_n,
  --    pulse_i    => clk_ext_rst,
  --    extended_o => ext_pll_reset);

  --cmp_sys_clk_pll : pll_base
  --  generic map (
  --    bandwidth          => "optimized",
  --    clk_feedback       => "clkfbout",
  --    compensation       => "internal",
  --    divclk_divide      => 1,
  --    clkfbout_mult      => 8,
  --    clkfbout_phase     => 0.000,
  --    clkout0_divide     => 16,         -- 62.5 mhz
  --    clkout0_phase      => 0.000,
  --    clkout0_duty_cycle => 0.500,
  --    clkout1_divide     => 16,         -- 125 mhz
  --    clkout1_phase      => 0.000,
  --    clkout1_duty_cycle => 0.500,
  --    clkout2_divide     => 16,
  --    clkout2_phase      => 0.000,
  --    clkout2_duty_cycle => 0.500,
  --    clkin_period       => 8.0,
  --    ref_jitter         => 0.016)
  --  port map (
  --    clkfbout => pllout_clk_fb_pllref,
  --    clkout0  => pllout_clk_sys,
  --    clkout1  => open,
  --    clkout2  => open,
  --    clkout3  => open,
  --    clkout4  => open,
  --    clkout5  => open,
  --    locked   => open,
  --    rst      => '0',
  --    clkfbin  => pllout_clk_fb_pllref,
  --    clkin    => clk_125m_pllref);

  --cmp_dmtd_clk_pll : pll_base
  --  generic map (
  --    bandwidth          => "optimized",
  --    clk_feedback       => "clkfbout",
  --    compensation       => "internal",
  --    divclk_divide      => 1,
  --    clkfbout_mult      => 50,
  --    clkfbout_phase     => 0.000,
  --    clkout0_divide     => 16,         -- 62.5 mhz
  --    clkout0_phase      => 0.000,
  --    clkout0_duty_cycle => 0.500,
  --    clkout1_divide     => 16,         -- 62.5 mhz
  --    clkout1_phase      => 0.000,
  --    clkout1_duty_cycle => 0.500,
  --    clkout2_divide     => 8,
  --    clkout2_phase      => 0.000,
  --    clkout2_duty_cycle => 0.500,
  --    clkin_period       => 50.0,
  --    ref_jitter         => 0.016)
  --  port map (
  --    clkfbout => pllout_clk_fb_dmtd,
  --    clkout0  => pllout_clk_dmtd,
  --    clkout1  => open,
  --    clkout2  => open,
  --    clkout3  => open,
  --    clkout4  => open,
  --    clkout5  => open,
  --    locked   => open,
  --    rst      => '0',
  --    clkfbin  => pllout_clk_fb_dmtd,
  --    clkin    => clk_20m_vcxo_buf);

--  u_reset_gen : cute_reset_gen
--    port map (
--      clk_sys_i        => clk_sys,
--      rst_pcie_n_a_i   => '1',
--      rst_button_n_a_i => '1',
--      rst_n_o          => local_reset_n);

local_reset_n <= rst_n_i;

  --cmp_clk_sys_buf : bufg
  --  port map (
  --    o => clk_sys,
  --    i => pllout_clk_sys);

  --cmp_clk_dmtd_buf : bufg
  --  port map (
  --    o => clk_dmtd,
  --    i => pllout_clk_dmtd);

  --cmp_clk_vcxo : bufg
  --  port map (
  --    o => clk_20m_vcxo_buf,
  --    i => clk_20m_vcxo_i);

  --------------------------------------------------------------------------------
  ---- local clock from gennum lclk
  --------------------------------------------------------------------------------
  --cmp_l_clk_buf : ibufds
  --  generic map (
  --    diff_term    => false,            -- differential termination
  --    ibuf_low_pwr => true,  -- low power (true) vs. performance (false) setting for referenced i/o standards
  --    iostandard   => "default")
  --  port map (
  --    o  => l_clk,                      -- buffer output
  --    i  => l_clkp,  -- diff_p buffer input (connect directly to top-level port)
  --    ib => l_clkn  -- diff_n buffer input (connect directly to top-level port)
  --    );

  --cmp_pllrefclk_buf : ibufgds
  --  generic map (
  --    diff_term    => true,             -- differential termination
  --    ibuf_low_pwr => true,  -- low power (true) vs. performance (false) setting for referenced i/o standards
  --    iostandard   => "default")
  --  port map (
  --    o  => clk_125m_pllref,            -- buffer output
  --    i  => clk_125m_pllref_p_i,  -- diff_p buffer input (connect directly to top-level port)
  --    ib => clk_125m_pllref_n_i  -- diff_n buffer input (connect directly to top-level port)
  --    );


  ----------------------------------------------------------------------------------
  ------ dedicated clock for gtp
  ----------------------------------------------------------------------------------
  --cmp_gtp_dedicated_clk_buf : ibufgds
  --  generic map(
  --    diff_term    => true,
  --    ibuf_low_pwr => true,
  --    iostandard   => "default")
  --  port map (
  --    o  => gtp_dedicated_clk,
  --    i  => fpga_pll_ref_clk_101_p_i,
  --    ib => fpga_pll_ref_clk_101_n_i
  --    );

clk_sys           <= clk_sys_i;
clk_dmtd          <= clk_dmtd_i;
gtp_dedicated_clk <= clk_gtp_i;
clk_125m_pllref   <= clk_ref_i;

led_test <= led_divider(23);

process(clk_sys)
begin
  if rising_edge(clk_sys) then
    led_divider <= led_divider + 1;
  end if;
end process;

  fpga_scl_o <= wrc_scl_o;
  fpga_sda_o <= wrc_sda_o;
  wrc_scl_i  <= fpga_scl_i;
  wrc_sda_i  <= fpga_sda_i;

  sfp_mod_def1_o <= sfp_scl_o;
  sfp_mod_def2_o <= sfp_sda_o;
  sfp_scl_i      <= sfp_mod_def1_i;
  sfp_sda_i      <= sfp_mod_def2_i;

  thermo_id_o <= owr_en(0);
  owr_i(0)    <= thermo_id_i;
  owr_i(1)    <= '0';

  pps_o <= pps;

u_wr_core : xcute_core
generic map (
    g_simulation                => 0,
    g_with_external_clock_input => true,
    --
    g_phys_uart                 => true,
    g_virtual_uart              => true,
    g_aux_clks                  => 0,
    g_ep_rxbuf_size             => 1024,
    g_tx_runt_padding           => true,
    g_pcs_16bit                 => false,
    g_dpram_initf               => "",
    g_etherbone_cfg_sdb         => c_etherbone_sdb,
    g_ext_cfg_sdb               => c_ext_sdb,
    g_aux1_sdb                  => c_wrc_tdc_cm_sdb,
    g_aux2_sdb                  => c_null_sdb,
    g_dpram_size                => 131072/4,
    g_interface_mode            => pipelined,
    g_address_granularity       => byte)
port map (
    clk_sys_i     => clk_sys,
    clk_dmtd_i    => clk_dmtd,
    clk_ref_i     => clk_125m_pllref,
    clk_aux_i     => (others => '0'),
    clk_ext_i     => '0',
    clk_ext_mul_i => '0',
    clk_ext_mul_locked_i => '1',
    clk_ext_stopped_i    => '0',
    clk_ext_rst_o        => open,
    pps_ext_i     => '0',
    rst_n_i       => local_reset_n,

    dac_hpll_load_p1_o => dac_hpll_load_p1,
    dac_hpll_data_o    => dac_hpll_data,
    dac_dpll_load_p1_o => dac_dpll_load_p1,
    dac_dpll_data_o    => dac_dpll_data,

    phy_ref_clk_i      => clk_125m_pllref,
    phy_tx_data_o      => phy_tx_data,
    phy_tx_k_o         => phy_tx_k,
    phy_tx_disparity_i => phy_tx_disparity,
    phy_tx_enc_err_i   => phy_tx_enc_err,
    phy_rx_data_i      => phy_rx_data,
    phy_rx_rbclk_i     => phy_rx_rbclk,
    phy_rx_k_i         => phy_rx_k,
    phy_rx_enc_err_i   => phy_rx_enc_err,
    phy_rx_bitslide_i  => phy_rx_bitslide,
    phy_rst_o          => phy_rst,
    phy_loopen_o       => phy_loopen,
    phy_loopen_vec_o   => phy_loopen_vec,
    phy_rdy_i          => phy_rdy,
    phy_sfp_tx_fault_i => sfp_tx_fault_i,
    phy_sfp_los_i      => sfp_los_i,
    phy_sfp_tx_disable_o => sfp_tx_disable_o,
    phy_tx_prbs_sel_o  =>  phy_prbs_sel,

    led_act_o  => led_red,
    led_link_o => led_green,
    scl_o      => wrc_scl_o,
    scl_i      => wrc_scl_i,
    sda_o      => wrc_sda_o,
    sda_i      => wrc_sda_i,
    sfp_scl_o  => sfp_scl_o,
    sfp_scl_i  => sfp_scl_i,
    sfp_sda_o  => sfp_sda_o,
    sfp_sda_i  => sfp_sda_i,
    sfp_det_i  => sfp_mod_def0_i,
    btn1_i     => open,
    btn2_i     => open,
    spi_sclk_o  => open,
    spi_ncs_o   => open,
    spi_mosi_o  => open,
    spi_miso_i  => '0',

    uart_rxd_i => uart_rxd_i,
    uart_txd_o => uart_txd_o,

    owr_en_o => owr_en,
    owr_i    => owr_i,

    wrc_slave_i => wrc_slave_i,
    wrc_slave_o => wrc_slave_o,

    aux_master_o => aux_master_o,
    aux_master_i => aux_master_i,

    etherbone_cfg_master_o=> etherbone_cfg_slave_in,
    etherbone_cfg_master_i=> etherbone_cfg_slave_out,

    etherbone_src_o => etherbone_snk_in,
    etherbone_src_i => etherbone_snk_out,
    etherbone_snk_o => etherbone_src_in,
    etherbone_snk_i => etherbone_src_out,

    ext_cfg_master_o=> ext_cfg_master_o,
    ext_cfg_master_i=> ext_cfg_master_i,

    ext_src_o => ext_src_o,
    ext_src_i => ext_src_i,
    ext_snk_o => ext_snk_o,
    ext_snk_i => ext_snk_i,

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
    clk_i       => clk_sys,
    nrst_i      => etherbone_rst_n,
    src_o       => etherbone_src_out,
    src_i       => etherbone_src_in,
    snk_o       => etherbone_snk_out,
    snk_i       => etherbone_snk_in,
    cfg_slave_o => etherbone_cfg_slave_out,
    cfg_slave_i => etherbone_cfg_slave_in,
    master_o    => etherbone_wb_out,
    master_i    => etherbone_wb_in
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
    clk_sys_i   => clk_sys,
    rst_n_i     => local_reset_n,
    slave_i(0)  => etherbone_wb_out,
    slave_o(0)  => etherbone_wb_in,
    master_i(0) => wrc_slave_o,
    master_o(0) => wrc_slave_i);
end generate;

  ---------------------

u_gtp : wr_gtp_phy_spartan6
generic map (
    g_enable_ch0 => 0,
    g_enable_ch1 => 1,
    g_simulation => 0)
port map (
    gtp_clk_i => gtp_dedicated_clk,

    ch0_ref_clk_i      => clk_125m_pllref,
    ch0_tx_data_i      => x"00",
    ch0_tx_k_i         => '0',
    ch0_tx_disparity_o => open,
    ch0_tx_enc_err_o   => open,
    ch0_rx_rbclk_o     => open,
    ch0_rx_data_o      => open,
    ch0_rx_k_o         => open,
    ch0_rx_enc_err_o   => open,
    ch0_rx_bitslide_o  => open,
    ch0_rst_i          => '1',
    ch0_loopen_i       => '0',
    ch0_rdy_o          => open,

    ch1_ref_clk_i      => clk_125m_pllref,
    ch1_tx_data_i      => phy_tx_data,
    ch1_tx_k_i         => phy_tx_k(0),
    ch1_tx_disparity_o => phy_tx_disparity,
    ch1_tx_enc_err_o   => phy_tx_enc_err,
    ch1_rx_data_o      => phy_rx_data,
    ch1_rx_rbclk_o     => phy_rx_rbclk,
    ch1_rx_k_o         => phy_rx_k(0),
    ch1_rx_enc_err_o   => phy_rx_enc_err,
    ch1_rx_bitslide_o  => phy_rx_bitslide,
    ch1_rst_i          => phy_rst,
    ch1_loopen_i       => phy_loopen,
    ch1_loopen_vec_i   => phy_loopen_vec,
    ch1_tx_prbs_sel_i  => phy_prbs_sel,
    ch1_rdy_o          => phy_rdy,
    pad_txn0_o         => open,
    pad_txp0_o         => open,
    pad_rxn0_i         => '0',
    pad_rxp0_i         => '0',
    pad_txn1_o         => sfp_txn_o,
    pad_txp1_o         => sfp_txp_o,
    pad_rxn1_i         => sfp_rxn_i,
    pad_rxp1_i         => sfp_rxp_i
);

u_dac_arb : cute_serial_dac_arb
generic map (
    g_invert_sclk    => false,
    g_num_extra_bits => 8)
port map (
    clk_i   => clk_sys,
    rst_n_i => local_reset_n,
    val1_i  => dac_dpll_data,
    load1_i => dac_dpll_load_p1,
    val2_i  => dac_hpll_data,
    load2_i => dac_hpll_load_p1,
    dac_sync_n_o  => dac_sync_n_o,
    dac_ldac_n_o  => dac_ldac_n_o,
    dac_clr_n_o   => dac_clr_n_o,
    dac_sclk_o    => dac_sclk_o,
    dac_din_o     => dac_din_o
);

end rtl;
