-- arria5_phy8.vhd

-- Generated using ACDS version 16.0 218

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity arria5_phy8 is
	port (
		phy_mgmt_clk                : in  std_logic                      := '0';             --                phy_mgmt_clk.clk
		phy_mgmt_clk_reset          : in  std_logic                      := '0';             --          phy_mgmt_clk_reset.reset
		phy_mgmt_address            : in  std_logic_vector(8 downto 0)   := (others => '0'); --                    phy_mgmt.address
		phy_mgmt_read               : in  std_logic                      := '0';             --                            .read
		phy_mgmt_readdata           : out std_logic_vector(31 downto 0);                     --                            .readdata
		phy_mgmt_waitrequest        : out std_logic;                                         --                            .waitrequest
		phy_mgmt_write              : in  std_logic                      := '0';             --                            .write
		phy_mgmt_writedata          : in  std_logic_vector(31 downto 0)  := (others => '0'); --                            .writedata
		tx_ready                    : out std_logic;                                         --                    tx_ready.export
		rx_ready                    : out std_logic;                                         --                    rx_ready.export
		pll_ref_clk                 : in  std_logic_vector(0 downto 0)   := (others => '0'); --                 pll_ref_clk.clk
		tx_serial_data              : out std_logic_vector(0 downto 0);                      --              tx_serial_data.export
		tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0)   := (others => '0'); --    tx_bitslipboundaryselect.export
		pll_locked                  : out std_logic_vector(0 downto 0);                      --                  pll_locked.export
		rx_serial_data              : in  std_logic_vector(0 downto 0)   := (others => '0'); --              rx_serial_data.export
		rx_runningdisp              : out std_logic_vector(0 downto 0);                      --              rx_runningdisp.export
		rx_disperr                  : out std_logic_vector(0 downto 0);                      --                  rx_disperr.export
		rx_errdetect                : out std_logic_vector(0 downto 0);                      --                rx_errdetect.export
		rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);                      -- rx_bitslipboundaryselectout.export
		tx_clkout                   : out std_logic_vector(0 downto 0);                      --                   tx_clkout.export
		rx_clkout                   : out std_logic_vector(0 downto 0);                      --                   rx_clkout.export
		tx_parallel_data            : in  std_logic_vector(7 downto 0)   := (others => '0'); --            tx_parallel_data.export
		tx_datak                    : in  std_logic_vector(0 downto 0)   := (others => '0'); --                    tx_datak.export
		rx_parallel_data            : out std_logic_vector(7 downto 0);                      --            rx_parallel_data.export
		rx_datak                    : out std_logic_vector(0 downto 0);                      --                    rx_datak.export
		reconfig_from_xcvr          : out std_logic_vector(91 downto 0);                     --          reconfig_from_xcvr.reconfig_from_xcvr
		reconfig_to_xcvr            : in  std_logic_vector(139 downto 0) := (others => '0')  --            reconfig_to_xcvr.reconfig_to_xcvr
	);
end entity arria5_phy8;

architecture rtl of arria5_phy8 is
	component altera_xcvr_det_latency is
		generic (
			device_family                 : string  := "";
			operation_mode                : string  := "Duplex";
			lanes                         : integer := 1;
			ser_base_factor               : integer := 8;
			ser_words                     : integer := 1;
			pcs_pma_width                 : integer := 8;
			data_rate                     : string  := "614.4 Mbps";
			base_data_rate                : string  := "1228.8 Mbps";
			en_cdrref_support             : integer := 0;
			pll_feedback_path             : string  := "no_compensation";
			word_aligner_mode             : string  := "deterministic_latency";
			tx_bitslip_enable             : string  := "false";
			run_length_violation_checking : integer := 40;
			pll_refclk_cnt                : integer := 1;
			pll_refclk_freq               : string  := "62.5 MHz";
			pll_refclk_select             : string  := "0";
			cdr_refclk_select             : integer := 0;
			plls                          : integer := 1;
			pll_type                      : string  := "AUTO";
			pll_select                    : integer := 0;
			pll_reconfig                  : integer := 0;
			mgmt_clk_in_mhz               : integer := 250;
			embedded_reset                : integer := 1;
			channel_interface             : integer := 0
		);
		port (
			phy_mgmt_clk                : in  std_logic                      := 'X';             -- clk
			phy_mgmt_clk_reset          : in  std_logic                      := 'X';             -- reset
			phy_mgmt_address            : in  std_logic_vector(8 downto 0)   := (others => 'X'); -- address
			phy_mgmt_read               : in  std_logic                      := 'X';             -- read
			phy_mgmt_readdata           : out std_logic_vector(31 downto 0);                     -- readdata
			phy_mgmt_waitrequest        : out std_logic;                                         -- waitrequest
			phy_mgmt_write              : in  std_logic                      := 'X';             -- write
			phy_mgmt_writedata          : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- writedata
			tx_ready                    : out std_logic;                                         -- export
			rx_ready                    : out std_logic;                                         -- export
			pll_ref_clk                 : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- clk
			tx_serial_data              : out std_logic_vector(0 downto 0);                      -- export
			tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0)   := (others => 'X'); -- export
			pll_locked                  : out std_logic_vector(0 downto 0);                      -- export
			rx_serial_data              : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- export
			rx_runningdisp              : out std_logic_vector(0 downto 0);                      -- export
			rx_disperr                  : out std_logic_vector(0 downto 0);                      -- export
			rx_errdetect                : out std_logic_vector(0 downto 0);                      -- export
			rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);                      -- export
			tx_clkout                   : out std_logic_vector(0 downto 0);                      -- export
			rx_clkout                   : out std_logic_vector(0 downto 0);                      -- export
			tx_parallel_data            : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- export
			tx_datak                    : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- export
			rx_parallel_data            : out std_logic_vector(7 downto 0);                      -- export
			rx_datak                    : out std_logic_vector(0 downto 0);                      -- export
			reconfig_from_xcvr          : out std_logic_vector(91 downto 0);                     -- reconfig_from_xcvr
			reconfig_to_xcvr            : in  std_logic_vector(139 downto 0) := (others => 'X'); -- reconfig_to_xcvr
			rx_is_lockedtoref           : out std_logic_vector(0 downto 0);                      -- export
			rx_is_lockedtodata          : out std_logic_vector(0 downto 0);                      -- export
			rx_signaldetect             : out std_logic_vector(0 downto 0);                      -- export
			rx_patterndetect            : out std_logic_vector(0 downto 0);                      -- export
			rx_syncstatus               : out std_logic_vector(0 downto 0);                      -- export
			rx_rlv                      : out std_logic_vector(0 downto 0);                      -- export
			cdr_ref_clk                 : in  std_logic                      := 'X';             -- clk
			pll_powerdown               : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- export
			tx_digitalreset             : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- export
			tx_analogreset              : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- export
			tx_cal_busy                 : out std_logic_vector(0 downto 0);                      -- export
			rx_digitalreset             : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- export
			rx_analogreset              : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- export
			rx_cal_busy                 : out std_logic_vector(0 downto 0)                       -- export
		);
	end component altera_xcvr_det_latency;

begin

	arria5_phy8_inst : component altera_xcvr_det_latency
		generic map (
			device_family                 => "Arria V",
			operation_mode                => "Duplex",
			lanes                         => 1,
			ser_base_factor               => 8,
			ser_words                     => 1,
			pcs_pma_width                 => 10,
			data_rate                     => "1.25 Gbps",
			base_data_rate                => "1250 Mbps",
			en_cdrref_support             => 0,
			pll_feedback_path             => "tx_clkout",
			word_aligner_mode             => "deterministic_latency",
			tx_bitslip_enable             => "true",
			run_length_violation_checking => 40,
			pll_refclk_cnt                => 1,
			pll_refclk_freq               => "125.0 MHz",
			pll_refclk_select             => "0",
			cdr_refclk_select             => 0,
			plls                          => 1,
			pll_type                      => "CMU",
			pll_select                    => 0,
			pll_reconfig                  => 0,
			mgmt_clk_in_mhz               => 250,
			embedded_reset                => 1,
			channel_interface             => 0
		)
		port map (
			phy_mgmt_clk                => phy_mgmt_clk,                --                phy_mgmt_clk.clk
			phy_mgmt_clk_reset          => phy_mgmt_clk_reset,          --          phy_mgmt_clk_reset.reset
			phy_mgmt_address            => phy_mgmt_address,            --                    phy_mgmt.address
			phy_mgmt_read               => phy_mgmt_read,               --                            .read
			phy_mgmt_readdata           => phy_mgmt_readdata,           --                            .readdata
			phy_mgmt_waitrequest        => phy_mgmt_waitrequest,        --                            .waitrequest
			phy_mgmt_write              => phy_mgmt_write,              --                            .write
			phy_mgmt_writedata          => phy_mgmt_writedata,          --                            .writedata
			tx_ready                    => tx_ready,                    --                    tx_ready.export
			rx_ready                    => rx_ready,                    --                    rx_ready.export
			pll_ref_clk                 => pll_ref_clk,                 --                 pll_ref_clk.clk
			tx_serial_data              => tx_serial_data,              --              tx_serial_data.export
			tx_bitslipboundaryselect    => tx_bitslipboundaryselect,    --    tx_bitslipboundaryselect.export
			pll_locked                  => pll_locked,                  --                  pll_locked.export
			rx_serial_data              => rx_serial_data,              --              rx_serial_data.export
			rx_runningdisp              => rx_runningdisp,              --              rx_runningdisp.export
			rx_disperr                  => rx_disperr,                  --                  rx_disperr.export
			rx_errdetect                => rx_errdetect,                --                rx_errdetect.export
			rx_bitslipboundaryselectout => rx_bitslipboundaryselectout, -- rx_bitslipboundaryselectout.export
			tx_clkout                   => tx_clkout,                   --                   tx_clkout.export
			rx_clkout                   => rx_clkout,                   --                   rx_clkout.export
			tx_parallel_data            => tx_parallel_data,            --            tx_parallel_data.export
			tx_datak                    => tx_datak,                    --                    tx_datak.export
			rx_parallel_data            => rx_parallel_data,            --            rx_parallel_data.export
			rx_datak                    => rx_datak,                    --                    rx_datak.export
			reconfig_from_xcvr          => reconfig_from_xcvr,          --          reconfig_from_xcvr.reconfig_from_xcvr
			reconfig_to_xcvr            => reconfig_to_xcvr,            --            reconfig_to_xcvr.reconfig_to_xcvr
			rx_is_lockedtoref           => open,                        --                 (terminated)
			rx_is_lockedtodata          => open,                        --                 (terminated)
			rx_signaldetect             => open,                        --                 (terminated)
			rx_patterndetect            => open,                        --                 (terminated)
			rx_syncstatus               => open,                        --                 (terminated)
			rx_rlv                      => open,                        --                 (terminated)
			cdr_ref_clk                 => '0',                         --                 (terminated)
			pll_powerdown               => "0",                         --                 (terminated)
			tx_digitalreset             => "0",                         --                 (terminated)
			tx_analogreset              => "0",                         --                 (terminated)
			tx_cal_busy                 => open,                        --                 (terminated)
			rx_digitalreset             => "0",                         --                 (terminated)
			rx_analogreset              => "0",                         --                 (terminated)
			rx_cal_busy                 => open                         --                 (terminated)
		);

end architecture rtl; -- of arria5_phy8