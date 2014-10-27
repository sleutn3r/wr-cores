
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wr_fabric_pkg.all;
use work.wr_xilinx_pkg.all;
use work.etherbone_pkg.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.wishbone_pkg.all;


entity cute_top is
  generic
    (
      TAR_ADDR_WDTH : integer := 13     -- not used for this project
      );
  port
    (
      -- Global ports
      clk_20m_vcxo_i : in std_logic;    -- 20MHz VCXO clock

      clk_125m_pllref_p_i : in std_logic;  -- 125 MHz PLL reference
      clk_125m_pllref_n_i : in std_logic;

      fpga_pll_ref_clk_101_p_i : in std_logic;  -- Dedicated clock for Xilinx GTP transceiver
      fpga_pll_ref_clk_101_n_i : in std_logic;


      -- Font panel LEDs
      LED_RED   : out std_logic;
      LED_GREEN : out std_logic;
      LED_TEST  : out std_logic;    
  
      dac_sclk_o  : out std_logic;
      dac_din_o   : out std_logic;
      dac_clr_n_o : out std_logic;
      dac_ldac_n_o : out std_logic;
      dac_sync_n_o : out std_logic;

      fpga_scl_b : inout std_logic;
      fpga_sda_b : inout std_logic;


      thermo_id : inout std_logic;      -- 1-Wire interface to DS18B20

      -------------------------------------------------------------------------
      -- SFP pins
      -------------------------------------------------------------------------

      sfp_txp_o : out std_logic;
      sfp_txn_o : out std_logic;

      sfp_rxp_i : in std_logic;
      sfp_rxn_i : in std_logic;

      sfp_mod_def0_b    : in    std_logic;  -- sfp detect
      sfp_mod_def1_b    : inout std_logic;  -- scl
      sfp_mod_def2_b    : inout std_logic;  -- sda
      sfp_rate_select_b : inout std_logic;
      sfp_tx_fault_i    : in    std_logic;
      sfp_tx_disable_o  : out   std_logic;
      sfp_los_i         : in    std_logic;


      -----------------------------------------
      --UART
      -----------------------------------------
      uart_rxd_i : in  std_logic;
      uart_txd_o : out std_logic;

      ----------------------------------------
      -- PPS
      ---------------------------------------
      pps_o : out std_logic 
      );

end cute_top;

architecture rtl of cute_top is

  ------------------------------------------------------------------------------
  -- Components declaration
  ------------------------------------------------------------------------------

  component spec_reset_gen
    port (
      clk_sys_i        : in  std_logic;
      rst_pcie_n_a_i   : in  std_logic;
      rst_button_n_a_i : in  std_logic;
      rst_n_o          : out std_logic);
  end component;

  --component chipscope_ila
  --  port (
  --    CONTROL : inout std_logic_vector(35 downto 0);
  --    CLK     : in    std_logic;
  --    TRIG0   : in    std_logic_vector(31 downto 0);
  --    TRIG1   : in    std_logic_vector(31 downto 0);
  --    TRIG2   : in    std_logic_vector(31 downto 0);
  --    TRIG3   : in    std_logic_vector(31 downto 0));
  --end component;

  --signal CONTROL : std_logic_vector(35 downto 0);
  --signal CLK     : std_logic;
  --signal TRIG0   : std_logic_vector(31 downto 0);
  --signal TRIG1   : std_logic_vector(31 downto 0);
  --signal TRIG2   : std_logic_vector(31 downto 0);
  --signal TRIG3   : std_logic_vector(31 downto 0);

  --component chipscope_icon
  --  port (
  --    CONTROL0 : inout std_logic_vector (35 downto 0));
  --end component;

  ------------------------------------------------------------------------------
  -- Constants declaration
  ------------------------------------------------------------------------------
  constant c_BAR0_APERTURE     : integer := 20;
  constant c_CSR_WB_SLAVES_NB  : integer := 1;
  constant c_DMA_WB_SLAVES_NB  : integer := 1;
  constant c_DMA_WB_ADDR_WIDTH : integer := 26;

  ------------------------------------------------------------------------------
  -- Signals declaration
  ------------------------------------------------------------------------------


  -- Dedicated clock for GTP transceiver
  signal gtp_dedicated_clk : std_logic;


  -- Reset
  signal rst_a : std_logic;
  signal rst   : std_logic;

  -- DMA wishbone bus
  --signal dma_adr     : std_logic_vector(31 downto 0);
  --signal dma_dat_i   : std_logic_vector((32*c_DMA_WB_SLAVES_NB)-1 downto 0);
  --signal dma_dat_o   : std_logic_vector(31 downto 0);
  --signal dma_sel     : std_logic_vector(3 downto 0);
  --signal dma_cyc     : std_logic;  --_vector(c_DMA_WB_SLAVES_NB-1 downto 0);
  --signal dma_stb     : std_logic;
  --signal dma_we      : std_logic;
  --signal dma_ack     : std_logic;  --_vector(c_DMA_WB_SLAVES_NB-1 downto 0);
  --signal dma_stall   : std_logic;  --_vector(c_DMA_WB_SLAVES_NB-1 downto 0);
  signal ram_we      : std_logic_vector(0 downto 0);
  signal ddr_dma_adr : std_logic_vector(29 downto 0);


  -- SPI
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
  signal led_divider      : unsigned(23 downto 0) := (others => '0');

  signal wrc_scl_o : std_logic;
  signal wrc_scl_i : std_logic;
  signal wrc_sda_o : std_logic;
  signal wrc_sda_i : std_logic;
  signal sfp_scl_o : std_logic;
  signal sfp_scl_i : std_logic;
  signal sfp_sda_o : std_logic;
  signal sfp_sda_i : std_logic;
  signal dio       : std_logic_vector(3 downto 0);

  signal dac_hpll_load_p1 : std_logic;
  signal dac_dpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_data    : std_logic_vector(15 downto 0);

  signal pps     : std_logic;
  signal pps_led : std_logic;

  signal phy_tx_data      : std_logic_vector(7 downto 0);
  signal phy_tx_k         : std_logic;
  signal phy_tx_disparity : std_logic;
  signal phy_tx_enc_err   : std_logic;
  signal phy_rx_data      : std_logic_vector(7 downto 0);
  signal phy_rx_rbclk     : std_logic;
  signal phy_rx_k         : std_logic;
  signal phy_rx_enc_err   : std_logic;
  signal phy_rx_bitslide  : std_logic_vector(3 downto 0);
  signal phy_rst          : std_logic;
  signal phy_loopen       : std_logic;

  signal dio_in  : std_logic_vector(4 downto 0);
  signal dio_out : std_logic_vector(4 downto 0);
  signal dio_clk : std_logic;

  signal local_reset_n  : std_logic;
  signal button1_synced : std_logic_vector(2 downto 0);

  signal genum_wb_out    : t_wishbone_master_out;
  signal genum_wb_in     : t_wishbone_master_in;
  signal genum_csr_ack_i : std_logic;

  signal wrc_slave_i : t_wishbone_slave_in;
  signal wrc_slave_o : t_wishbone_slave_out;

  signal owr_en : std_logic_vector(1 downto 0);
  signal owr_i  : std_logic_vector(1 downto 0);

  signal wb_adr : std_logic_vector(31 downto 0);  --c_BAR0_APERTURE-priv_log2_ceil(c_CSR_WB_SLAVES_NB+1)-1 downto 0);

  signal etherbone_rst_n   : std_logic;
  signal etherbone_src_out : t_wrf_source_out;
  signal etherbone_src_in  : t_wrf_source_in;
  signal etherbone_snk_out : t_wrf_sink_out;
  signal etherbone_snk_in  : t_wrf_sink_in;
  signal etherbone_wb_out  : t_wishbone_master_out;
  signal etherbone_wb_in   : t_wishbone_master_in;
  signal etherbone_cfg_in  : t_wishbone_slave_in;
  signal etherbone_cfg_out : t_wishbone_slave_out;
  
begin

  cmp_sys_clk_pll : PLL_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",
      CLK_FEEDBACK       => "CLKFBOUT",
      COMPENSATION       => "INTERNAL",
      DIVCLK_DIVIDE      => 1,
      CLKFBOUT_MULT      => 8,
      CLKFBOUT_PHASE     => 0.000,
      CLKOUT0_DIVIDE     => 16,         -- 62.5 MHz
      CLKOUT0_PHASE      => 0.000,
      CLKOUT0_DUTY_CYCLE => 0.500,
      CLKOUT1_DIVIDE     => 16,         -- 125 MHz
      CLKOUT1_PHASE      => 0.000,
      CLKOUT1_DUTY_CYCLE => 0.500,
      CLKOUT2_DIVIDE     => 16,
      CLKOUT2_PHASE      => 0.000,
      CLKOUT2_DUTY_CYCLE => 0.500,
      CLKIN_PERIOD       => 8.0,
      REF_JITTER         => 0.016)
    port map (
      CLKFBOUT => pllout_clk_fb_pllref,
      CLKOUT0  => pllout_clk_sys,
      CLKOUT1  => open,
      CLKOUT2  => open,
      CLKOUT3  => open,
      CLKOUT4  => open,
      CLKOUT5  => open,
      LOCKED   => open,
      RST      => '0',
      CLKFBIN  => pllout_clk_fb_pllref,
      CLKIN    => clk_125m_pllref);

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
      CLKIN    => clk_20m_vcxo_buf);

  U_Reset_Gen : spec_reset_gen
    port map (
      clk_sys_i        => clk_sys,
      rst_pcie_n_a_i   => '1',
      rst_button_n_a_i => '1',
      rst_n_o          => local_reset_n);

  cmp_clk_sys_buf : BUFG
    port map (
      O => clk_sys,
      I => pllout_clk_sys);

  cmp_clk_dmtd_buf : BUFG
    port map (
      O => clk_dmtd,
      I => pllout_clk_dmtd);

  cmp_clk_vcxo : BUFG
    port map (
      O => clk_20m_vcxo_buf,
      I => clk_20m_vcxo_i);

  ------------------------------------------------------------------------------
  -- Local clock from gennum LCLK
  ------------------------------------------------------------------------------

  cmp_pllrefclk_buf : IBUFGDS
    generic map (
      DIFF_TERM    => true,             -- Differential Termination
      IBUF_LOW_PWR => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => clk_125m_pllref,            -- Buffer output
      I  => clk_125m_pllref_p_i,  -- Diff_p buffer input (connect directly to top-level port)
      IB => clk_125m_pllref_n_i  -- Diff_n buffer input (connect directly to top-level port)
      );


  ------------------------------------------------------------------------------
  -- Dedicated clock for GTP
  ------------------------------------------------------------------------------
  cmp_gtp_dedicated_clk_buf : IBUFGDS
    generic map(
      DIFF_TERM    => true,
      IBUF_LOW_PWR => true,
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => gtp_dedicated_clk,
      I  => fpga_pll_ref_clk_101_p_i,
      IB => fpga_pll_ref_clk_101_n_i
      );


  genum_csr_ack_i                <= genum_wb_in.ack or genum_wb_in.err;
  genum_wb_out.adr(1 downto 0)   <= (others => '0');
  genum_wb_out.adr(18 downto 2)  <= wb_adr(16 downto 0);
  genum_wb_out.adr(31 downto 19) <= (others => '0');

  process(clk_sys)
  begin
    if rising_edge(clk_sys) then
      led_divider <= led_divider + 1;
    end if;
  end process;
  
  LED_TEST <= led_divider(23);

  fpga_scl_b <= '0' when wrc_scl_o = '0' else 'Z';
  fpga_sda_b <= '0' when wrc_sda_o = '0' else 'Z';
  wrc_scl_i  <= fpga_scl_b;
  wrc_sda_i  <= fpga_sda_b;

  sfp_mod_def1_b <= '0' when sfp_scl_o = '0' else 'Z';
  sfp_mod_def2_b <= '0' when sfp_sda_o = '0' else 'Z';
  sfp_scl_i      <= sfp_mod_def1_b;
  sfp_sda_i      <= sfp_mod_def2_b;

  thermo_id <= '0' when owr_en(0) = '1' else 'Z';
  owr_i(0)  <= thermo_id;

  U_WR_CORE : xwr_core
    generic map (
      g_simulation                => 0,
      g_phys_uart                 => true,
      g_virtual_uart              => true,
      g_with_external_clock_input => true,
      g_aux_clks                  => 1,
      g_ep_rxbuf_size             => 1024,
      g_dpram_initf               => "wrc.ram",
      g_dpram_size                => 94208/4,  --23552,
      g_interface_mode            => PIPELINED,
      g_address_granularity       => BYTE)
    port map (
      clk_sys_i  => clk_sys,
      clk_dmtd_i => clk_dmtd,
      clk_ref_i  => clk_125m_pllref,
      clk_aux_i  => (others => '0'),
      clk_ext_i  => '0',
      pps_ext_i  => '0',
      rst_n_i    => local_reset_n,

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

      led_act_o   => LED_RED,
      led_link_o  => LED_GREEN,
      
      scl_o       => wrc_scl_o,
      scl_i       => wrc_scl_i,
      sda_o       => wrc_sda_o,
      sda_i       => wrc_sda_i,
      sfp_scl_o   => sfp_scl_o,
      sfp_scl_i   => sfp_scl_i,
      sfp_sda_o   => sfp_sda_o,
      sfp_sda_i   => sfp_sda_i,
      sfp_det_i   => sfp_mod_def0_b,
      btn1_i      => '1',
      btn2_i      => '1',

      uart_rxd_i => uart_rxd_i,
      uart_txd_o => uart_txd_o,

      owr_en_o => owr_en,
      owr_i    => owr_i,

      slave_i => wrc_slave_i,
      slave_o => wrc_slave_o,
      
      aux_master_o => etherbone_cfg_in,
      aux_master_i => etherbone_cfg_out,

      wrf_src_o => etherbone_snk_in,
      wrf_src_i => etherbone_snk_out,
      wrf_snk_o => etherbone_src_in,
      wrf_snk_i => etherbone_src_out,

      tm_dac_value_o       => open,
      tm_dac_wr_o          => open,
      tm_clk_aux_lock_en_i => (others=>'0'),
      tm_clk_aux_locked_o  => open,
      tm_time_valid_o      => open,
      tm_tai_o             => open,
      tm_cycles_o          => open,
      pps_p_o              => pps,
      pps_led_o            => pps_led,

      dio_o       => open,
      rst_aux_n_o => etherbone_rst_n
      );

  Etherbone : eb_slave_core
    generic map (
      g_sdb_address => x"0000000000030000")
    port map (
      clk_i       => clk_sys,
      nRst_i      => etherbone_rst_n,
      src_o       => etherbone_src_out,
      src_i       => etherbone_src_in,
      snk_o       => etherbone_snk_out,
      snk_i       => etherbone_snk_in,
      cfg_slave_o => etherbone_cfg_out,
      cfg_slave_i => etherbone_cfg_in,
      master_o    => etherbone_wb_out,
      master_i    => etherbone_wb_in);

  ---------------------
  masterbar : xwb_crossbar
    generic map (
      g_num_masters => 2,
      g_num_slaves  => 1,
      g_registered  => false,
      g_address     => (0 => x"00000000"),
      g_mask        => (0 => x"00000000"))
    port map (
      clk_sys_i   => clk_sys,
      rst_n_i     => local_reset_n,
      slave_i(0)  => genum_wb_out,
      slave_i(1)  => etherbone_wb_out,
      slave_o(0)  => genum_wb_in,
      slave_o(1)  => etherbone_wb_in,
      master_i(0) => wrc_slave_o,
      master_o(0) => wrc_slave_i);
  ---------------------

  U_GTP : wr_gtp_phy_spartan6
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

      ch1_ref_clk_i      => clk_125m_pllref,
      ch1_tx_data_i      => phy_tx_data,
      ch1_tx_k_i         => phy_tx_k,
      ch1_tx_disparity_o => phy_tx_disparity,
      ch1_tx_enc_err_o   => phy_tx_enc_err,
      ch1_rx_data_o      => phy_rx_data,
      ch1_rx_rbclk_o     => phy_rx_rbclk,
      ch1_rx_k_o         => phy_rx_k,
      ch1_rx_enc_err_o   => phy_rx_enc_err,
      ch1_rx_bitslide_o  => phy_rx_bitslide,
      ch1_rst_i          => phy_rst,
      ch1_loopen_i       => phy_loopen,
      pad_txn0_o         => open,
      pad_txp0_o         => open,
      pad_rxn0_i         => '0',
      pad_rxp0_i         => '0',
      pad_txn1_o         => sfp_txn_o,
      pad_txp1_o         => sfp_txp_o,
      pad_rxn1_i         => sfp_rxn_i,
      pad_rxp1_i         => sfp_rxp_i);

  
  U_DAC_ARB : cutewr_serial_dac_arb
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
      dac_din_o     => dac_din_o);
  
  pps_o                  <= pps;

  sfp_tx_disable_o <= '0';

end rtl;


