--
-- White Rabbit Training, Lab 1
--
-- Objectives:
-- - Synchronize two SPEC boards. No user data transmission yet.
--
-- Brief description:
-- The firmware contains the simplest fully functional implementation of the WR core.
-- It's purpose is to show the WRPC synchronizing to another WR device.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Use library UNISIM for PLL_BASE, IBUFGDS and BUFG simulation components.
library UNISIM;
use UNISIM.vcomponents.all;

-- Use the WR Core package, with xwr_core component defined inside.
use work.wrcore_pkg.all;
-- Use the General Cores package (for gc_extend_pulse)
use work.gencores_pkg.all;
-- Use the Xilinx White Rabbit platform-specific package (for wr_gtp_phy_spartan6)
use work.wr_xilinx_pkg.all;

entity spec_top is
  generic (
    -- Simulation mode enable parameter. Set by default (synthesis) to 0, and
    -- changed to non-zero in the instantiation of the top level DUT in the testbench.
    -- Its purpose is to reduce some internal counters/timeouts to speed up simulations.
    g_simulation : integer := 0
    );
  port (

    ---------------------------------------------------------------------------
    -- Clock signals
    ---------------------------------------------------------------------------

    -- Clock input: 125 MHz LVDS reference clock, coming from the CDCM61004
    -- PLL. The reference oscillator is a 25 MHz VCTCXO (VM53S), tunable by the
    -- DAC connected to CS0 SPI line (dac_main output of the WR Core).
    clk_125m_pllref_p_i : in std_logic;
    clk_125m_pllref_n_i : in std_logic;

    -- Dedicated clock for the Xilinx GTP transceiver. Same physical clock as
    -- clk_125m_pllref, just coming from another output of CDCM61004 PLL.
    fpga_pll_ref_clk_101_p_i : in std_logic;
    fpga_pll_ref_clk_101_n_i : in std_logic;

    -- Clock input, used to derive the DDMTD clock (check out the general presentation
    -- of WR for explanation of its purpose). The clock is produced by the
    -- other VCXO, tuned by the second AD5662 DAC, (which is connected to
    -- dac_helper output of the WR Core)
    clk_20m_vcxo_i : in std_logic;

    -- Reset input, active low. Comes from the Gennum PCI-Express bridge.
    l_rst_n : in std_logic := 'H';

    -- Button 1 on the SPEC card. In our case, used as an external reset trigger.
    button1_n_i : in std_logic := 'H';

    -------------------------------------------------------------------------
    -- SFP pins
    -------------------------------------------------------------------------

    -- TX gigabit output
    sfp_txp_o : out std_logic;
    sfp_txn_o : out std_logic;

    -- RX gigabit input
    sfp_rxp_i : in std_logic;
    sfp_rxn_i : in std_logic;

    -- SFP MOD_DEF0 pin (used as a tied-to-ground SFP insertion detect line)
    sfp_det_i         : in    std_logic;
    -- SFP MOD_DEF1 pin (SCL line of the I2C EEPROM inside the SFP)
    sfp_scl_b         : inout std_logic;
    -- SFP MOD_DEF1 pin (SDA line of the I2C EEPROM inside the SFP)
    sfp_sda_b         : inout std_logic;
    -- SFP RATE_SELECT pin. Unused for most SFPs, in our case tied to 0.
    sfp_rate_select_b : inout std_logic;
    -- SFP laser fault detection pin. Unused in our design.
    sfp_tx_fault_i    : in    std_logic;
    -- SFP laser disable line. In our case, tied to GND.
    sfp_tx_disable_o  : out   std_logic;
    -- SFP-provided loss-of-link detection. We don't use it as Ethernet PCS
    -- has its own loss-of-sync detection mechanism.
    sfp_los_i         : in    std_logic;

    -- Green LED next to the SFP: indicates if the link is up.
    sfp_led_green_o : out std_logic;

    -- Red LED next to the SFP: blinking indicates that packets are being
    -- transferred.
    sfp_led_red_o : out std_logic;

    ---------------------------------------------------------------------------
    -- Oscillator control pins
    ---------------------------------------------------------------------------

    -- A typical SPI bus shared betwen two AD5662 DACs. The first one (CS1) tunes
    -- the clk_ref oscillator, the second (CS2) - the clk_dmtd VCXO.
    dac_sclk_o  : out std_logic;
    dac_din_o   : out std_logic;
    dac_cs1_n_o : out std_logic;
    dac_cs2_n_o : out std_logic;

    ---------------------------------------------------------------------------
    -- Miscellanous WR Core pins
    ---------------------------------------------------------------------------

    -- SPI bus connected to the FPGA Flash memory on the SPEC. This Flash is used
    -- for storing WR Core's configuration parameters.
    spi_sclk_o : out std_logic;
    spi_ncs_o  : out std_logic;
    spi_mosi_o : out std_logic;
    spi_miso_i : in  std_logic;

    -- One-wire interface to DS18B20 temperature sensor, which also provides an
    -- unique serial number, that WRPC uses to assign itself a unique MAC address.
    thermo_id_b : inout std_logic;

    -- UART pins (connected to the mini-USB port)
    uart_txd_o : out std_logic;
    uart_rxd_i : in  std_logic;

    -------------------------------------------------------------------------
    -- Necessary Digital I/O mezzanine pins
    -------------------------------------------------------------------------

    -- Differential inputs, dio_p_i(N) inputs the current state of I/O (N+1) on
    -- the mezzanine front panel.
    dio_n_i : in std_logic_vector(4 downto 0);
    dio_p_i : in std_logic_vector(4 downto 0);

    -- Differential outputs. When the I/O (N+1) is configured as output (i.e. when
    -- dio_oe_n_o(N) = 0), the value of dio_p_o(N) determines the logic state
    -- of I/O (N+1) on the front panel of the mezzanine
    dio_n_o : out std_logic_vector(4 downto 0);
    dio_p_o : out std_logic_vector(4 downto 0);

    -- Output enable. When dio_oe_n_o(N) is 0, connector (N+1) on the front
    -- panel is configured as an output.
    dio_oe_n_o : out std_logic_vector(4 downto 0);

    -- Termination enable. When dio_term_en_o(N) is 1, connector (N+1) on the front
    -- panel is 50-ohm terminated
    dio_term_en_o : out std_logic_vector(4 downto 0);

    -- Two LEDs on the mezzanine panel
    dio_led_top_o : out std_logic;
    dio_led_bot_o : out std_logic
    );
end spec_top;

architecture rtl of spec_top is

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  
  component spec_reset_gen
    port (
      clk_sys_i        : in  std_logic;
      rst_pcie_n_a_i   : in  std_logic;
      rst_button_n_a_i : in  std_logic;
      rst_n_o          : out std_logic);
  end component;

  -----------------------------------------------------------------------------
  -- Signals declarations
  -----------------------------------------------------------------------------

  -- System reset
  signal rst_n : std_logic;

  -- System clock (62.5 MHz)
  signal clk_sys : std_logic;

  -- White Rabbit reference clock (125 MHz)
  signal clk_ref : std_logic;

  -- White Rabbit DDMTD helper clock (62.5-and-something MHz)
  signal clk_dmtd : std_logic;

  -- 125 MHz GTP clock coming from a dedicated input pin (same as clk_ref)
  signal clk_gtp : std_logic;

  -- PLL & clock buffer wiring
  signal clk_20m_vcxo_buf     : std_logic;
  signal pllout_clk_sys       : std_logic;
  signal pllout_clk_fb_pllref : std_logic;
  signal pllout_clk_dmtd      : std_logic;
  signal pllout_clk_fb_dmtd   : std_logic;

  -- Oscillator control DAC wiring
  signal dac_hpll_load_p1 : std_logic;
  signal dac_dpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_data    : std_logic_vector(15 downto 0);

  -- PHY wiring
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
  signal phy_rdy          : std_logic;

  -- Digital I/O mezzanine wiring
  signal dio_in  : std_logic_vector(4 downto 0);
  signal dio_out : std_logic_vector(4 downto 0);

  -- Misc signals
  signal pps, pps_led, pps_long : std_logic;

  signal sfp_scl_out, sfp_sda_out : std_logic;
  signal owr_enable, owr_in       : std_logic_vector(1 downto 0);
  

begin

  -----------------------------------------------------------------------------
  -- System/reference clock buffers and PLL
  -----------------------------------------------------------------------------

  -- Input differential buffer on the 125 MHz reference clock
  U_Reference_Clock_Buffer : IBUFGDS
    generic map (
      DIFF_TERM    => true,             -- Differential Termination
      IBUF_LOW_PWR => true,      -- Low power (TRUE) vs. performance (FALSE)
      IOSTANDARD   => "DEFAULT")  -- take the I/O standard from the UCF file
    port map (
      O  => clk_ref,                    -- Buffer output
      I  => clk_125m_pllref_p_i,  -- Diff_p buffer input (connect directly to top-level port)
      IB => clk_125m_pllref_n_i  -- Diff_n buffer input (connect directly to top-level port)
      );

  -- ... and the PLL that derives 62.5 MHz system clock from the 125 MHz reference
  U_System_Clock_PLL : PLL_BASE
    generic map (
      BANDWIDTH          => "OPTIMIZED",
      CLK_FEEDBACK       => "CLKFBOUT",
      COMPENSATION       => "INTERNAL",
      DIVCLK_DIVIDE      => 1,
      CLKFBOUT_MULT      => 8,
      CLKFBOUT_PHASE     => 0.000,
      CLKOUT0_DIVIDE     => 16,  -- Output 0: 125 MHz * 8 / 16 = 62.5 MHz
      CLKOUT0_PHASE      => 0.000,
      CLKOUT0_DUTY_CYCLE => 0.500,
      CLKOUT1_DIVIDE     => 16,
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
      CLKIN    => clk_ref);

  -- A buffer to drive system clock generated by the PLL above as a global
  -- clock net.
  U_System_Clock_Buffer : BUFG
    port map (
      O => clk_sys,
      I => pllout_clk_sys);

  -----------------------------------------------------------------------------
  -- DMTD clock buffers and PLL
  -----------------------------------------------------------------------------

  -- A global clock buffer to drive the PLL input pin from the 20 MHz VCXO clock
  -- input pin on the FPGA
  U_DMTD_VCXO_Clock_Buffer : BUFG
    port map (
      O => clk_20m_vcxo_buf,
      I => clk_20m_vcxo_i);

  -- The PLL that multiplies the 20 MHz VCXO input to obtain the DDMTD
  -- clock, that is sligthly offset in frequency wrs to the reference 125 MHz clock.
  -- The WR core additionally requires the DDMTD clock frequency to be divided
  -- by 2 (so instead of 125-point-something MHz we get 62.5-point-something
  -- MHz). This is to improve internal DDMTD phase detector timing.
  U_DMTD_Clock_PLL : PLL_BASE
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

  -- A buffer to drive system clock generated by the PLL above as a global
  -- clock net.
  U_DMTD_Clock_Buffer : BUFG
    port map (
      O => clk_dmtd,
      I => pllout_clk_dmtd);


  ------------------------------------------------------------------------------
  -- Dedicated clock for GTP
  ------------------------------------------------------------------------------
  U_Dedicated_GTP_Clock_Buffer : IBUFGDS
    generic map(
      DIFF_TERM    => true,
      IBUF_LOW_PWR => true,
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => clk_gtp,
      I  => fpga_pll_ref_clk_101_p_i,
      IB => fpga_pll_ref_clk_101_n_i
      );

  -----------------------------------------------------------------------------
  -- Reset signal generator
  -----------------------------------------------------------------------------

  -- Produces a clean reset signal upon the following
  -- conditions:
  -- - device is powered up
  -- - a PCI-Express bus reset is requested
  -- - button 1 is pressed.
  U_Reset_Gen : spec_reset_gen
    port map (
      clk_sys_i        => clk_sys,
      rst_pcie_n_a_i   => L_RST_N,
      rst_button_n_a_i => button1_n_i,
      rst_n_o          => rst_n);

  -----------------------------------------------------------------------------
  -- The WR Core part. The simplest functional instantiation.
  -----------------------------------------------------------------------------

  U_The_WR_Core : wr_core
    generic map (
      g_simulation  => g_simulation
      --g_dpram_initf => "none"
      )
    port map (
      -- Clocks & resets connections
      clk_sys_i  => clk_sys,
      clk_ref_i  => clk_ref,
      clk_dmtd_i => clk_dmtd,
      rst_n_i    => rst_n,

      -- Oscillator control DACs connections
      dac_hpll_load_p1_o => dac_hpll_load_p1,
      dac_hpll_data_o    => dac_hpll_data,
      dac_dpll_load_p1_o => dac_dpll_load_p1,
      dac_dpll_data_o    => dac_dpll_data,

      -- PHY connections
      phy_ref_clk_i      => clk_ref,
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
      phy_rdy_i          => phy_rdy,

      -- Timecode and 1-PPS interface
      tm_link_up_o    => open,
      tm_time_valid_o => open,
      tm_tai_o        => open,
      tm_cycles_o     => open,
      -- The PPS output, which we'll drive to the DIO mezzanine channel 1.
      pps_p_o         => pps,
      pps_led_o       => pps_led,

      -----------------------
      -- Miscellanous pins --
      -----------------------
      -- UART
      uart_rxd_i => uart_rxd_i,
      uart_txd_o => uart_txd_o,

      -- SPI for external Flash
      spi_sclk_o  => spi_sclk_o,
      spi_ncs_o   => spi_ncs_o,
      spi_mosi_o  => spi_mosi_o,
      spi_miso_i  => spi_miso_i,

      -- I2C for SFP identification
      sfp_scl_o => sfp_scl_out,
      sfp_scl_i => sfp_scl_b,
      sfp_sda_o => sfp_sda_out,
      sfp_sda_i => sfp_sda_b,

      -- 1-Wire for digital thermometer
      owr_en_o => owr_enable,
      owr_i    => owr_in,

      -- GPIO
      sfp_det_i => sfp_det_i,

      led_link_o => sfp_led_green_o,
      led_act_o  => sfp_led_red_o
    );


  -----------------------------------------------------------------------------
  -- Dual channel SPI DAC driver
  -----------------------------------------------------------------------------
  
  U_DAC_ARB : spec_serial_dac_arb
    generic map (
      g_invert_sclk    => false,        -- configured for 2xAD5662. Don't
                                        -- change the parameters.
      g_num_extra_bits => 8)

    port map (
      clk_i   => clk_sys,
      rst_n_i => rst_n,

      -- DAC 1 controls the main (clk_ref) oscillator
      val1_i  => dac_dpll_data,
      load1_i => dac_dpll_load_p1,

      -- DAC 2 controls the helper (clk_ddmtd) oscillator
      val2_i  => dac_hpll_data,
      load2_i => dac_hpll_load_p1,

      dac_cs_n_o(0) => dac_cs1_n_o,
      dac_cs_n_o(1) => dac_cs2_n_o,
      dac_sclk_o    => dac_sclk_o,
      dac_din_o     => dac_din_o);


  -----------------------------------------------------------------------------
  -- Gigabit Ethernet PHY using Spartan-6 GTP transceviver.
  -----------------------------------------------------------------------------
  
  U_GTP : wr_gtp_phy_spartan6
    generic map (
      g_enable_ch0 => 0,
      -- each GTP has two channels, so does the PHY module.
      -- The SFP on the SPEC is connected to the 2nd channel. 
      g_enable_ch1 => 1,
      g_simulation => g_simulation)
    port map (
      gtp_clk_i => clk_gtp,

      ch1_ref_clk_i => clk_ref,

      -- TX code stream
      ch1_tx_data_i      => phy_tx_data,
      -- TX control/data select
      ch1_tx_k_i         => phy_tx_k(0),
      -- TX disparity of the previous symbol
      ch1_tx_disparity_o => phy_tx_disparity,
      -- TX encoding error
      ch1_tx_enc_err_o   => phy_tx_enc_err,

      -- RX recovered byte clock
      ch1_rx_rbclk_o    => phy_rx_rbclk,
      -- RX data stream
      ch1_rx_data_o     => phy_rx_data,
      -- RX control/data select
      ch1_rx_k_o        => phy_rx_k(0),
      -- RX encoding error detection
      ch1_rx_enc_err_o  => phy_rx_enc_err,
      -- RX path comma alignment bit slide delay (crucial for accuracy!)
      ch1_rx_bitslide_o => phy_rx_bitslide,

      -- Channel reset
      ch1_rst_i    => phy_rst,
      -- Loopback mode enable
      ch1_loopen_i => phy_loopen,
      -- Transceiver is locked and ready
      ch1_rdy_o    => phy_rdy,

      pad_txn1_o => sfp_txn_o,
      pad_txp1_o => sfp_txp_o,
      pad_rxn1_i => sfp_rxn_i,
      pad_rxp1_i => sfp_rxp_i);

  -- pps_led signal from the WR core is 8ns- (single clk_ref cycle) wide. This is
  -- too short to drive outputs such as LEDs. Let's extend its length to some
  -- human-noticeable value
  U_Extend_PPS : gc_extend_pulse
    generic map (
      g_width => 10000000)              -- output length: 10000000x8ns = 80 ms.

    port map (
      clk_i      => clk_ref,
      rst_n_i    => rst_n,
      pulse_i    => pps_led,
      extended_o => pps_long);

  -----------------------------------------------------------------------------
  -- Differential buffers for the Digital I/O Mezzanine
  -----------------------------------------------------------------------------
  gen_dio_iobufs : for i in 0 to 4 generate
    U_Input_Buffer : IBUFDS
      generic map (
        DIFF_TERM => true)
      port map (
        O  => dio_in(i),
        I  => dio_p_i(i),
        IB => dio_n_i(i)
        );

    U_Output_Buffer : OBUFDS
      port map (
        I  => dio_out(i),
        O  => dio_p_o(i),
        OB => dio_n_o(i)
        );
  end generate gen_dio_iobufs;


  -- The SFP is permanently enabled
  sfp_tx_disable_o  <= '0';
  sfp_rate_select_b <= '0';

  -- Open-drain driver for the Onewire bus
  thermo_id_b <= '0' when owr_enable(0) = '1' else 'Z';
  owr_in(0)   <= thermo_id_b;

  -- Open-drain drivers for the SFP I2C bus
  sfp_scl_b <= '0' when sfp_scl_out = '0' else 'Z';
  sfp_sda_b <= '0' when sfp_sda_out = '0' else 'Z';

  -- Connect the PPS output to the I/O 1 of the Digital I/O mezzanine
  dio_out(0) <= pps;

  -- Drive unused DIO outputs to 0.
  dio_out(4 downto 1) <= (others => '0');

  -- all DIO connectors are outputs
  dio_oe_n_o <= (others => '0');

  -- and not terminated 
  dio_term_en_o <= (others => '0');

  -- Drive one of the LEDs on the mezzanine with out PPS signal (pps_led is a
  -- longer version that can be used to directly drive a LED)


  dio_led_top_o <= pps_long;

  -- The other LED is not used.
  dio_led_bot_o <= '0';

end rtl;
