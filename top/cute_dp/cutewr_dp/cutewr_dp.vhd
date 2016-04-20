
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.gn4124_core_pkg.all;
use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wrdp_pkg.all;
use work.wr_fabric_pkg.all;
use work.wr_xilinx_pkg.all;
use work.etherbone_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity cutewr_dp is
port
(
    -- Global ports
    clk_20m_vcxo_i : in std_logic;    -- 20MHz VCXO clock

    fpga_clk_p_i : in std_logic;  -- 125 MHz PLL reference
    fpga_clk_n_i : in std_logic;

    sfp0_ref_clk_p_i : in std_logic;  -- Dedicated clock for Xilinx GTP transceiver
    sfp0_ref_clk_n_i : in std_logic;

    sfp1_ref_clk_p_i : in std_logic;  -- Dedicated clock for Xilinx GTP transceiver
    sfp1_ref_clk_n_i : in std_logic;

    dac_sclk_o  : out std_logic;
    dac_din_o   : out std_logic;
    dac_clr_n_o : out std_logic;
    dac_ldac_n_o : out std_logic;
    dac_sync_n_o : out std_logic;

    fpga_scl_b : inout std_logic;
    fpga_sda_b : inout std_logic;
    thermo_id_b : inout std_logic;      -- 1-Wire interface to DS18B20

    sfp0_led_o : out std_logic;
    sfp1_led_o : out std_logic;
    -------------------------------------------------------------------------
    -- sfp0 pins
    -------------------------------------------------------------------------
    
    --sfp0_txp_o : out std_logic;
    --sfp0_txn_o : out std_logic;
    --sfp0_rxp_i : in std_logic;
    --sfp0_rxn_i : in std_logic;
    --sfp0_mod_def0_i    : in    std_logic;  -- sfp detect
    --sfp0_mod_def1_b    : inout std_logic;  -- scl
    --sfp0_mod_def2_b    : inout std_logic;  -- sda
    --sfp0_tx_fault_i    : in    std_logic;
    --sfp0_tx_disable_o  : out   std_logic;
    --sfp0_los_i         : in    std_logic;

    -------------------------------------------------------------------------
    -- SFP1 pins
    -------------------------------------------------------------------------
    sfp1_txp_o : out std_logic;
    sfp1_txn_o : out std_logic;
    sfp1_rxp_i : in std_logic;
    sfp1_rxn_i : in std_logic;
    sfp1_mod_def0_i    : in    std_logic;  -- sfp detect
    sfp1_mod_def1_b    : inout std_logic;  -- scl
    sfp1_mod_def2_b    : inout std_logic;  -- sda
    sfp1_tx_fault_i    : in    std_logic;
    sfp1_tx_disable_o  : out   std_logic;
    sfp1_los_i         : in    std_logic;

    -----------------------------------------
    --UART
    -----------------------------------------
    uart_rxd_i : in  std_logic;
    uart_txd_o : out std_logic;
    -----------------------------------------
    --PPS
    -----------------------------------------
    pps_o     :  out std_logic;
    ext_clk_o :  out  std_logic;   
    ----------------------------------------
    -- user interface
    ---------------------------------------
    -- Font panel LEDs
    usr_button_i: in  std_logic
--    usr_led1_o  : out std_logic;
--    usr_led2_o  : out std_logic;
--    usr_lemo1_o : out std_logic;
--    usr_lemo2_o : out std_logic
);
end cutewr_dp;

architecture rtl of cutewr_dp is

------------------------------------------------------------------------------
-- Components declaration
------------------------------------------------------------------------------
component cute_reset_gen is
port (
    clk_sys_i : in std_logic;
    rst_pcie_n_a_i   : in std_logic;
    rst_button_n_a_i : in std_logic;
    rst_n_o : out std_logic);
end component;

  ------------------------------------------------------------------------------
  -- Signals declaration
  ------------------------------------------------------------------------------
  -- Reset
  signal local_reset_n:std_logic;
  -- Clock
  signal fpga_clk_i:std_logic;
  signal clk_ref_i,clk_sys_i,clk_dmtd_i: std_logic;
  signal clk_gtp_i:std_logic;
  signal clk_20m_vcxo_buf:std_logic;
  signal pllout_clk_62_5,pllout_clk_125:std_logic;
  signal pllout_clk_fb_ref,pllout_clk_fb_dmtd:std_logic;
  signal pllout_clk_dmtd:std_logic;
  
  signal ext_wb_out    : t_wishbone_master_out;
  signal ext_wb_in     : t_wishbone_master_in;

  signal ext_src_out : t_wrf_source_out;
  signal ext_src_in  : t_wrf_source_in;
  signal ext_snk_out : t_wrf_sink_out;
  signal ext_snk_in  : t_wrf_sink_in;

  signal wrc_slave_i : t_wishbone_slave_in;
  signal wrc_slave_o : t_wishbone_slave_out;
  signal fpga_scl_o : std_logic;
  signal fpga_scl_i : std_logic;
  signal fpga_sda_o : std_logic;
  signal fpga_sda_i : std_logic;

  signal pps: std_logic;

  signal sfp0_scl_o : std_logic;
  signal sfp0_scl_i : std_logic;
  signal sfp0_sda_o : std_logic;
  signal sfp0_sda_i : std_logic;

  signal sfp0_mod_def1_i,sfp0_mod_def1_o:std_logic;
  signal sfp0_mod_def2_i,sfp0_mod_def2_o:std_logic;
  
  signal sfp1_scl_o : std_logic;
  signal sfp1_scl_i : std_logic;
  signal sfp1_sda_o : std_logic;
  signal sfp1_sda_i : std_logic;

  signal sfp1_mod_def1_i,sfp1_mod_def1_o:std_logic;
  signal sfp1_mod_def2_i,sfp1_mod_def2_o:std_logic;

  signal dac_hpll_load_p1 : std_logic;
  signal dac_dpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_data    : std_logic_vector(15 downto 0);
  
  signal etherbone_rst_n   : std_logic;
  signal etherbone_src_out : t_wrf_source_out;
  signal etherbone_src_in  : t_wrf_source_in;
  signal etherbone_snk_out : t_wrf_sink_out;
  signal etherbone_snk_in  : t_wrf_sink_in;
  signal etherbone_wb_out  : t_wishbone_master_out;
  signal etherbone_wb_in   : t_wishbone_master_in;
  signal etherbone_cfg_slave_in  : t_wishbone_slave_in;
  signal etherbone_cfg_slave_out : t_wishbone_slave_out;

  signal owr_en : std_logic_vector(1 downto 0);
  signal owr_i  : std_logic_vector(1 downto 0);

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

begin

U_Reset_Gen : cute_reset_gen
port map (
    clk_sys_i        => clk_sys_i,
    rst_pcie_n_a_i   => '1',
    rst_button_n_a_i => usr_button_i,
    rst_n_o          => local_reset_n
);

cmp_refclk_buf : IBUFGDS
generic map (
    DIFF_TERM    => true,             -- Differential Termination
    IBUF_LOW_PWR => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD   => "DEFAULT")
port map (
    O  => fpga_clk_i,            -- Buffer output
    I  => fpga_clk_p_i,  -- Diff_p buffer input (connect directly to top-level port)
    IB => fpga_clk_n_i  -- Diff_n buffer input (connect directly to top-level port)
);

cmp_clk_vcxo_buf : BUFG
port map (
    O => clk_20m_vcxo_buf,
    I => clk_20m_vcxo_i
);


--cmp_gtp0_dedicated_clk_buf : IBUFDS
--generic map(
--    DIFF_TERM    => true,
--    IBUF_LOW_PWR => true,
--    IOSTANDARD   => "DEFAULT")
--port map (
--    O  => clk_gtp_i,
--    I  => sfp0_ref_clk_p_i,
--    IB => sfp0_ref_clk_n_i
--);

cmp_gtp1_dedicated_clk_buf : IBUFDS
generic map(
    DIFF_TERM    => true,
    IBUF_LOW_PWR => true,
    IOSTANDARD   => "DEFAULT")
port map (
    O  => clk_gtp_i,
    I  => sfp1_ref_clk_p_i,
    IB => sfp1_ref_clk_n_i
);

cmp_sys_clk_pll : PLL_BASE
generic map (
    BANDWIDTH          => "OPTIMIZED",
    CLK_FEEDBACK       => "CLKFBOUT",
    COMPENSATION       => "INTERNAL",
    DIVCLK_DIVIDE      => 1,
    CLKFBOUT_MULT      => 8,
    CLKFBOUT_PHASE     => 0.000,
    CLKOUT0_DIVIDE     => 16,        -- 62.5 MHz
    CLKOUT0_PHASE      => 0.000,
    CLKOUT0_DUTY_CYCLE => 0.500,
    CLKOUT1_DIVIDE     => 8,         -- 125 MHz
    CLKOUT1_PHASE      => 0.000,
    CLKOUT1_DUTY_CYCLE => 0.500,
    CLKOUT2_DIVIDE     => 4,         -- 250 MHz
    CLKOUT2_PHASE      => 0.000,
    CLKOUT2_DUTY_CYCLE => 0.500,
    CLKIN_PERIOD       => 8.0,
    REF_JITTER         => 0.016)
port map (
    CLKFBOUT => pllout_clk_fb_ref,
    CLKOUT0  => pllout_clk_62_5,
    CLKOUT1  => pllout_clk_125,
    CLKOUT2  => open,
    CLKOUT3  => open,
    CLKOUT4  => open,
    CLKOUT5  => open,
    LOCKED   => open,
    RST      => '0',
    CLKFBIN  => pllout_clk_fb_ref,
    CLKIN    => fpga_clk_i
);

cmp_dmtd_clk_pll : PLL_BASE
generic map (
    BANDWIDTH          => "OPTIMIZED",
    CLK_FEEDBACK       => "CLKFBOUT",
    COMPENSATION       => "INTERNAL",
    DIVCLK_DIVIDE      => 1,
    CLKFBOUT_MULT      => 50,
    CLKFBOUT_PHASE     => 0.000,
    CLKOUT0_DIVIDE     => 16,         -- 62.5 MHz
    CLKOUT0_PHASE      => 0.000,
    CLKOUT0_DUTY_CYCLE => 0.500,
    CLKOUT1_DIVIDE     => 16,         -- 62.5 MHz
    CLKOUT1_PHASE      => 0.000,
    CLKOUT1_DUTY_CYCLE => 0.500,
    CLKOUT2_DIVIDE     => 8,
    CLKOUT2_PHASE      => 0.000,
    CLKOUT2_DUTY_CYCLE => 0.500,
    CLKIN_PERIOD       => 50.0,
    REF_JITTER         => 0.016)
port map (
    CLKFBOUT => pllout_clk_fb_dmtd,
    CLKOUT0  => pllout_clk_dmtd,
    CLKOUT1  => open,
    CLKOUT2  => open,
    CLKOUT3  => open,
    CLKOUT4  => open,
    CLKOUT5  => open,
    LOCKED   => open,
    RST      => '0',
    CLKFBIN  => pllout_clk_fb_dmtd,
    CLKIN    => clk_20m_vcxo_buf
);

cmp_clk_sys_buf : BUFG
port map (
    O => clk_sys_i,
    I => pllout_clk_62_5
);
   
cmd_clk_ref_buf: BUFG
port map(
    O => clk_ref_i,
    I => pllout_clk_125
);

cmp_clk_dmtd_buf : BUFG
  port map (
    O => clk_dmtd_i,
    I => pllout_clk_dmtd
);

------------------------------------------------------------------------------
-- Dedicated clock for GTP
------------------------------------------------------------------------------  
  fpga_scl_b  <= '0' when fpga_scl_o = '0' else 'Z';
  fpga_sda_b  <= '0' when fpga_sda_o = '0' else 'Z';
  fpga_scl_i  <= fpga_scl_b;
  fpga_sda_i  <= fpga_sda_b;

  --sfp0_mod_def1_b <= '0' when sfp0_mod_def1_o = '0' else 'Z';
  --sfp0_mod_def2_b <= '0' when sfp0_mod_def2_o = '0' else 'Z';
  --sfp0_mod_def1_i <= sfp0_mod_def1_b;
  --sfp0_mod_def2_i <= sfp0_mod_def2_b;

  sfp1_mod_def1_b <= '0' when sfp1_mod_def1_o = '0' else 'Z';
  sfp1_mod_def2_b <= '0' when sfp1_mod_def2_o = '0' else 'Z';
  sfp1_mod_def1_i <= sfp1_mod_def1_b;
  sfp1_mod_def2_i <= sfp1_mod_def2_b;

  thermo_id_b <= '0' when owr_en(0) = '1' else 'Z';
  owr_i(0)  <= thermo_id_b;
  owr_i(1)  <= '0';

  pps_o <= pps;
  ext_clk_o <= pps;

U_WR_CORE : xcute_core
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
      g_aux1_sdb                  => c_etherbone_sdb,
      g_aux2_sdb                  => c_etherbone_sdb,
      g_dpram_size                => 131072/4,
      g_interface_mode            => PIPELINED,
      g_address_granularity       => BYTE)
    port map (
      clk_sys_i     => clk_sys_i,
      clk_dmtd_i    => clk_dmtd_i,
      clk_ref_i     => clk_ref_i,
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

      --phy_ref_clk_i      => clk_ref_i,
      --phy_tx_data_o      => phy0_tx_data,
      --phy_tx_k_o         => phy0_tx_k,
      --phy_tx_disparity_i => phy0_tx_disparity,
      --phy_tx_enc_err_i   => phy0_tx_enc_err,
      --phy_rx_data_i      => phy0_rx_data,
      --phy_rx_rbclk_i     => phy0_rx_rbclk,
      --phy_rx_k_i         => phy0_rx_k,
      --phy_rx_enc_err_i   => phy0_rx_enc_err,
      --phy_rx_bitslide_i  => phy0_rx_bitslide,
      --phy_rst_o          => phy0_rst,
      --phy_loopen_o       => phy0_loopen,
      --phy_loopen_vec_o   => phy0_loopen_vec,
      --phy_rdy_i          => phy0_rdy,
      --phy_sfp_tx_fault_i => sfp0_tx_fault_i,
      --phy_sfp_los_i      => sfp0_los_i,
      --phy_sfp_tx_disable_o => sfp0_tx_disable_o,
      --phy_tx_prbs_sel_o  =>  phy0_prbs_sel,

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

      led_act_o  => sfp0_led_o,
      led_link_o => sfp1_led_o,
      scl_o      => fpga_scl_o,
      scl_i      => fpga_scl_i,
      sda_o      => fpga_sda_o,
      sda_i      => fpga_sda_i,

      --sfp_scl_o  => sfp0_scl_o,
      --sfp_scl_i  => sfp0_scl_i,
      --sfp_sda_o  => sfp0_sda_o,
      --sfp_sda_i  => sfp0_sda_i,
      --sfp_det_i  => sfp0_mod_def0_i,

      sfp_scl_o  => sfp1_scl_o,
      sfp_scl_i  => sfp1_scl_i,
      sfp_sda_o  => sfp1_sda_o,
      sfp_sda_i  => sfp1_sda_i,
      sfp_det_i  => sfp1_mod_def0_i,

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

      aux1_master_o => open,
      aux1_master_i => open,

      aux2_master_o => open,
      aux2_master_i => open,

      etherbone_cfg_master_o=> etherbone_cfg_slave_in,
      etherbone_cfg_master_i=> etherbone_cfg_slave_out,

      etherbone_src_o => etherbone_snk_in,
      etherbone_src_i => etherbone_snk_out,
      etherbone_snk_o => etherbone_src_in,
      etherbone_snk_i => etherbone_src_out,

      ext_src_o => open,
      ext_src_i => open,
      ext_snk_o => open,
      ext_snk_i => open,
      
      tm_dac_value_o       => open,
      tm_dac_wr_o          => open,
      tm_clk_aux_lock_en_i => (others => '0'),
      tm_clk_aux_locked_o  => open,
      tm_time_valid_o      => open,
      tm_tai_o             => open,
      tm_cycles_o          => open,
      pps_p_o              => pps,
      pps_led_o            => open,

--      dio_o       => dio_out(4 downto 1),
      rst_aux_n_o => etherbone_rst_n
      );

    Etherbone : eb_slave_core
      generic map (
        g_sdb_address => x"0000000000030000")
      port map (
        clk_i       => clk_sys_i,
        nRst_i      => etherbone_rst_n,
        src_o       => etherbone_src_out,
        src_i       => etherbone_src_in,
        snk_o       => etherbone_snk_out,
        snk_i       => etherbone_snk_in,
        cfg_slave_o => etherbone_cfg_slave_out,
        cfg_slave_i => etherbone_cfg_slave_in,
        master_o    => etherbone_wb_out,
        master_i    => etherbone_wb_in);

  masterbar : xwb_crossbar
    generic map (
      g_num_masters => 2,
      g_num_slaves  => 1,
      g_registered  => false,
      g_address     => (0 => x"00000000"),
      g_mask        => (0 => x"00000000"))
    port map (
      clk_sys_i   => clk_sys_i,
      rst_n_i     => local_reset_n,
      slave_i(0)  => ext_wb_out,
      slave_i(1)  => etherbone_wb_out,
      slave_o(0)  => ext_wb_in,
      slave_o(1)  => etherbone_wb_in,
      master_i(0) => wrc_slave_o,
      master_o(0) => wrc_slave_i);

  U_DAC_ARB : cute_serial_dac_arb
    generic map (
      g_invert_sclk    => false,
      g_num_extra_bits => 8)

    port map (
      clk_i   => clk_sys_i,
      rst_n_i => local_reset_n,

      val1_i  => dac_dpll_data,
      load1_i => dac_dpll_load_p1,

      val2_i  => dac_hpll_data,
      load2_i => dac_hpll_load_p1,
      dac_sync_n_o  => dac_sync_n_o,
      dac_ldac_n_o  => dac_ldac_n_o,
      dac_clr_n_o   => dac_clr_n_o,
      dac_sclk_o    => dac_sclk_o,
      dac_din_o     => dac_din_o);

    U_GTP : wr_gtp_phy_spartan6
    generic map (
      g_enable_ch0 => 0,
      g_enable_ch1 => 1,
      g_simulation => 0)
    port map (
      gtp_clk_i => clk_gtp_i,

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
	    --ch0_rdy_o          => phy0_rdy,
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
      --ch1_tx_prbs_sel_i  => (others=>'0'),
      --ch1_rdy_o          => open,
      --pad_txn1_o         => open,
      --pad_txp1_o         => open,
      --pad_rxn1_i         => '0',
      --pad_rxp1_i         => '0'
);
    	
end rtl;


