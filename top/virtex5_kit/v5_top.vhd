--
-- White Rabbit Core Hands-On Course
--
-- Lesson 03: Simplest functional WR core design
--
-- Objectives:
-- - Synchronize two SPEC boards. No user data transmission yet.
--
-- Brief description:
-- The firmware contains the simplest fully functional implementation of the WR core.
-- It's purpose is to show the WRPC talking to another WRPC and synchronizing
-- with each other
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

entity v5_top is
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
    gtp_clk_p_i : in std_logic;
    gtp_clk_n_i : in std_logic;

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

    --
    sfp_tx_disable_o : out std_logic;
    
    -- UART pins (connected to the mini-USB port)
    uart_txd_o : out std_logic;
    uart_rxd_i : in  std_logic
 );

end v5_top;

architecture rtl of v5_top is

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component chipscope_icon_v5 is
    port (
      CONTROL0 : inout std_logic_vector(35 downto 0));
  end component chipscope_icon_v5;

  component chipscope_ila_v5 is
    port (
      CONTROL : inout std_logic_vector(35 downto 0);
      CLK     : in    std_logic;
      TRIG0   : in    std_logic_vector(31 downto 0);
      TRIG1   : in    std_logic_vector(31 downto 0));
  end component chipscope_ila_v5;

  signal CONTROL : std_logic_vector(35 downto 0);
  signal TRIG0   : std_logic_vector(31 downto 0);
  signal TRIG1   : std_logic_vector(31 downto 0);
  
  component wr_gtp_phy_virtex5 is
    generic (
      g_simulation      : integer := 0;
      g_force_disparity : integer := 0;
      g_enable_ch0      : integer := 0;
      g_enable_ch1      : integer := 0);
    port (
      gtp_clk_i          : in  std_logic;
      ch01_ref_clk_i     : in  std_logic                    := '0';
      ch0_tx_data_i      : in  std_logic_vector(7 downto 0) := "00000000";
      ch0_tx_k_i         : in  std_logic                    := '0';
      ch0_tx_disparity_o : out std_logic;
      ch0_tx_enc_err_o   : out std_logic;
      ch0_rx_rbclk_o     : out std_logic;
      ch0_rx_data_o      : out std_logic_vector(7 downto 0);
      ch0_rx_k_o         : out std_logic;
      ch0_rx_enc_err_o   : out std_logic;
      ch0_rx_bitslide_o  : out std_logic_vector(3 downto 0);
      ch0_rst_i          : in  std_logic                    := '0';
      ch0_loopen_i       : in  std_logic                    := '0';
      ch1_tx_data_i      : in  std_logic_vector(7 downto 0) := "00000000";
      ch1_tx_k_i         : in  std_logic                    := '0';
      ch1_tx_disparity_o : out std_logic;
      ch1_tx_enc_err_o   : out std_logic;
      ch1_rx_data_o      : out std_logic_vector(7 downto 0);
      ch1_rx_rbclk_o     : out std_logic;
      ch1_rx_k_o         : out std_logic;
      ch1_rx_enc_err_o   : out std_logic;
      ch1_rx_bitslide_o  : out std_logic_vector(3 downto 0);
      ch1_rst_i          : in  std_logic                    := '0';
      ch1_loopen_i       : in  std_logic                    := '0';
      pad_txn0_o         : out std_logic;
      pad_txp0_o         : out std_logic;
      pad_rxn0_i         : in  std_logic                    := '0';
      pad_rxp0_i         : in  std_logic                    := '0';
      pad_txn1_o         : out std_logic;
      pad_txp1_o         : out std_logic;
      pad_rxn1_i         : in  std_logic                    := '0';
      pad_rxp1_i         : in  std_logic                    := '0';
      ch1_align_done_o   : out std_logic;
      ch1_rx_synced_o    : out std_logic);
  end component wr_gtp_phy_virtex5;
  
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

  -- Digital I/O mezzanine wiring
  signal dio_in  : std_logic_vector(4 downto 0);
  signal dio_out : std_logic_vector(4 downto 0);

  -- Misc signals
  signal pps_p, pps_long : std_logic;

  signal sfp_scl_out, sfp_sda_out : std_logic;
  signal fmc_scl_out, fmc_sda_out : std_logic;
  signal owr_enable, owr_in       : std_logic_vector(1 downto 0);
  signal uart_txd_int:  std_logic;
  
signal button1_n : std_logic;
begin

  --chipscope_ila_v5_1: chipscope_ila_v5
  --  port map (
  --    CONTROL => CONTROL,
  --    CLK => clk_sys,
  --    TRIG0   => TRIG0,
  --    TRIG1   => TRIG1);

  --chipscope_icon_v5_1: chipscope_icon_v5
  --  port map (
  --    CONTROL0 => CONTROL);
  
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


  clk_dmtd <= clk_sys;
  

  ------------------------------------------------------------------------------
  -- Dedicated clock for GTP
  ------------------------------------------------------------------------------
  U_Dedicated_GTP_Clock_Buffer : IBUFGDS
    generic map(
      DIFF_TERM    => true,
--      IBUF_LOW_PWR => true,
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => clk_gtp,
      I  => gtp_clk_p_i,
      IB => gtp_clk_n_i
      );

  -----------------------------------------------------------------------------
  -- Reset signal generator
  -----------------------------------------------------------------------------

  -- Produces a clean reset signal upon the following
  -- conditions:
  -- - device is powered up
  -- - a PCI-Express bus reset is requested
  -- - button 1 is pressed.

  button1_n <= not button1_n_i;
  
  U_Reset_Gen : spec_reset_gen
    port map (
      clk_sys_i        => clk_sys,
      rst_pcie_n_a_i   => '1',
      rst_button_n_a_i => button1_n,
      rst_n_o          => rst_n);

  TRIG0(0) <= button1_n_i;
  trig0(1) <= rst_n;
  trig0(2) <= uart_txd_int;

  uart_txd_o <= uart_txd_int;
  -----------------------------------------------------------------------------
  -- The WR Core part. The simplest functional instantiation.
  -----------------------------------------------------------------------------

  U_The_WR_Core : wr_core
    generic map (
      g_simulation => g_simulation,
      g_dpram_initf => "wrc-bootloader.ram"
      )
    
    port map (
      -- Clocks & resets connections
      clk_sys_i  => clk_sys,
      clk_ref_i  => clk_ref,
      clk_dmtd_i => clk_dmtd,

      rst_n_i    => rst_n,

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

      -- Oscillator control DACs connections
      dac_hpll_load_p1_o => dac_hpll_load_p1,
      dac_hpll_data_o    => dac_hpll_data,
      dac_dpll_load_p1_o => dac_dpll_load_p1,
      dac_dpll_data_o    => dac_dpll_data,

      -- Miscellanous pins
      uart_rxd_i => uart_rxd_i,
      uart_txd_o => uart_txd_int,

      scl_o => open,
      scl_i => '1',
      sda_o => open,
      sda_i => '1',

      sfp_scl_o => open,
      sfp_scl_i => '1',
      sfp_sda_o => open,
      sfp_sda_i => '1',

      sfp_det_i => '1',

      led_link_o => open,
      led_act_o  => open,

      owr_en_o => open,
      --owr_i    => owr_enable(0),

      -- The PPS output, which we'll drive to the DIO mezzanine channel 1.
      pps_p_o => open
      );


  -----------------------------------------------------------------------------
  -- Gigabit Ethernet PHY using Spartan-6 GTP transceviver.
  -----------------------------------------------------------------------------
  
  U_GTP : wr_gtp_phy_virtex5
    generic map (
      g_enable_ch0 => 1,
      -- each GTP has two channels, so does the PHY module.
      -- The SFP on the SPEC is connected to the 2nd channel. 
      g_enable_ch1 => 0,
      g_simulation => g_simulation)
    port map (
      gtp_clk_i => clk_gtp,

      ch01_ref_clk_i => clk_ref,

      -- TX code stream
      ch0_tx_data_i      => phy_tx_data,
      -- TX control/data select
      ch0_tx_k_i         => phy_tx_k,
      -- TX disparity of the previous symbol
      ch0_tx_disparity_o => phy_tx_disparity,
      -- TX encoding error
      ch0_tx_enc_err_o   => phy_tx_enc_err,

      -- RX recovered byte clock
      ch0_rx_rbclk_o    => phy_rx_rbclk,
      -- RX data stream
      ch0_rx_data_o     => phy_rx_data,
      -- RX control/data select
      ch0_rx_k_o        => phy_rx_k,
      -- RX encoding error detection
      ch0_rx_enc_err_o  => phy_rx_enc_err,
      -- RX path comma alignment bit slide delay (crucial for accuracy!)
      ch0_rx_bitslide_o => phy_rx_bitslide,

      -- Channel reset
      ch0_rst_i    => phy_rst,
      ch1_rst_i    => phy_rst,
      -- Loopback mode enable
      ch0_loopen_i => phy_loopen,

      pad_txn0_o => sfp_txn_o,
      pad_txp0_o => sfp_txp_o,
      pad_rxn0_i => sfp_rxn_i,
      pad_rxp0_i => sfp_rxp_i);

  -- The SFP is permanently enabled
    sfp_tx_disable_o  <= '0';
--    sfp_rate_select_b <= '0';

  ---- Open-drain driver for the Onewire bus
  --thermo_id_b <= '0' when owr_enable(0) = '1' else 'Z';
  --owr_in(0)   <= thermo_id_b;


  --sfp_scl_b <= '0' when sfp_scl_out = '0' else 'Z';
  --sfp_sda_b <= '0' when sfp_sda_out = '0' else 'Z';

end rtl;
