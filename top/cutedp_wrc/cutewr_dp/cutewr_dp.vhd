
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.gn4124_core_pkg.all;
use work.gencores_pkg.all;
use work.wrcore_pkg.all;
use work.wr_fabric_pkg.all;
use work.wr_xilinx_pkg.all;
use work.wishbone_pkg.all;
use work.etherbone_pkg.all;

entity cutewr_dp is
port
(
-- clock
  clk20          : in std_logic;    -- 20MHz VCXO clock
  fpga_clk_p     : in std_logic;  -- 125 MHz PLL reference
  fpga_clk_n     : in std_logic;
--  sfp0_ref_clk_p : in std_logic;  -- Dedicated clock for Xilinx GTP transceiver
--  sfp0_ref_clk_n : in std_logic;
  sfp1_ref_clk_p : in std_logic;  -- Dedicated clock for Xilinx GTP transceiver
  sfp1_ref_clk_n : in std_logic;
	
-- pll
  plldac_sclk   : out std_logic;
  plldac_din    : out std_logic;
  plldac_clr_n  : out std_logic;
  plldac_load_n : out std_logic;
  plldac_sync_n : out std_logic;
	
-- eeprom
	fpga_scl      : inout std_logic;
  fpga_sda      : inout std_logic;
	
-- 1-wire
	one_wire      : inout std_logic;      -- 1-Wire interface to DS18B20
  
	-- FLASH
	fpga_cclk     : out std_logic;
  fpga_cso_b    : out std_logic;
  fpga_mosi     : out std_logic;
  fpga_din      : in  std_logic:='1';
	
  -- sfp0 pins
--  sfp0_tx_p : out std_logic;
--  sfp0_tx_n : out std_logic;
--  sfp0_rx_p : in std_logic;
--  sfp0_rx_n : in std_logic;
--  sfp0_mod_def0    : in    std_logic;  -- sfp detect
--  sfp0_mod_def1    : inout std_logic;  -- scl
--  sfp0_mod_def2    : inout std_logic;  -- sda
--  sfp0_tx_fault    : in    std_logic;
--  sfp0_tx_disable  : out   std_logic;
--  sfp0_los         : in    std_logic;
  
	sfp1_tx_p        : out std_logic;
  sfp1_tx_n        : out std_logic;
  sfp1_rx_p        : in std_logic;
  sfp1_rx_n        : in std_logic;
  sfp1_mod_def0    : in    std_logic;  -- sfp detect
  sfp1_mod_def1    : inout std_logic;  -- scl
  sfp1_mod_def2    : inout std_logic;  -- sda
  sfp1_tx_fault    : in    std_logic;
  sfp1_tx_disable  : out   std_logic;
  sfp1_tx_los      : in    std_logic;

  --UART
  uart_rx : in  std_logic;
  uart_tx : out std_logic;
  
	-- user interface
	sfp0_led      : out std_logic;
  sfp1_led      : out std_logic;
--  ext_clk       :  out  std_logic;
--  usr_button    : in  std_logic;
--  usr_led1      : out std_logic;
--  usr_led2      : out std_logic;
--  usr_lemo1     : in  std_logic;
--  usr_lemo2     : out std_logic
  pps_out       :  out std_logic
);
end cutewr_dp;

architecture rtl of cutewr_dp is

------------------------------------------------------------------------------
-- Components declaration
------------------------------------------------------------------------------
component cute_reset_gen is
  port (
    clk_sys_i : in std_logic;
--    rst_button_n_a_i : in std_logic;
    rst_n_o : out std_logic
  );
end component;

component cutedp_wrc is
  generic (
    g_etherbone_enable: boolean:= true;
    g_multiboot_enable: boolean:= true);
  port (
    clk_20m_i     : in std_logic;
    clk_sys_i     : in std_logic;     -- 62.5m system clock, from pll drived by clk_125m_pllref
    clk_dmtd_i    : in std_logic;     -- 62.5m dmtd clock, from pll drived by clk_20m_vcxo
    clk_ref_i     : in std_logic;     -- 125m reference clock
--    clk_gtp0_i     : in std_logic;     -- dedicated clock for xilinx gtp transceiver
    clk_gtp1_i    : in std_logic;     -- dedicated clock for xilinx gtp transceiver
    rst_n_i  		  : in std_logic;
    sfp0_led_o    : out std_logic;
    sfp1_led_o    : out std_logic;
    dac_sclk_o    : out std_logic;
    dac_din_o     : out std_logic;
    dac_clr_n_o   : out std_logic;
    dac_ldac_n_o  : out std_logic;
    dac_sync_n_o  : out std_logic;
    fpga_scl_i    : in  std_logic;
    fpga_scl_o    : out std_logic;
    fpga_sda_i    : in  std_logic;
    fpga_sda_o    : out std_logic;
--    button1_i : in std_logic := 'h';
--		button2_i : in std_logic := 'h';
    fpga_prom_cclk_o    : out std_logic;
    fpga_prom_cso_b_n_o : out std_logic;
    fpga_prom_mosi_o    : out std_logic;
    fpga_prom_miso_i    : in  std_logic:='1';
    thermo_id_i         : in  std_logic;
    thermo_id_o         : out std_logic;      -- 1-wire interface to ds18b20
--    sfp0_txp_o           : out std_logic;
--    sfp0_txn_o           : out std_logic;
--    sfp0_rxp_i           : in std_logic;
--    sfp0_rxn_i           : in std_logic;
--    sfp0_mod_def0_i    : in    std_logic;  -- sfp detect
--    sfp0_mod_def1_i    : in std_logic;  -- scl
--    sfp0_mod_def1_o    : out std_logic;  -- scl
--    sfp0_mod_def2_i    : in std_logic;  -- sda
--    sfp0_mod_def2_o    : out std_logic;  -- sda
--    sfp0_rate_select_i : in std_logic;
--    sfp0_rate_select_o : out std_logic;
--    sfp0_tx_fault_i    : in    std_logic;
--    sfp0_tx_disable_o  : out   std_logic;
--    sfp0_los_i         : in    std_logic;
    sfp1_txp_o         : out std_logic;
    sfp1_txn_o         : out std_logic;
    sfp1_rxp_i         : in std_logic;
    sfp1_rxn_i         : in std_logic;
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
    pps_o              : out std_logic;
    tm_time_valid_o    : out std_logic;
    tm_tai_o           : out std_logic_vector(39 downto 0);
    tm_cycles_o        : out std_logic_vector(27 downto 0);
    uart_rxd_i         : in  std_logic;
    uart_txd_o         : out std_logic;
    ext_snk_i          : in  t_wrf_sink_in;
    ext_snk_o          : out t_wrf_sink_out;
    ext_src_o          : out t_wrf_source_out;
    ext_src_i          : in  t_wrf_source_in;
    ext_master_i       : in t_wishbone_master_in:=cc_unused_master_in;
    ext_master_o       : out t_wishbone_master_out);
end component;

component xwr_com5402 is
  generic (
    g_use_wishbone_interface : boolean := true;
    nudptx: integer range 0 to 1:= 1;
    nudprx: integer range 0 to 1:= 1;
    ntcpstreams: integer range 0 to 255 := 1;  
    clk_frequency: integer := 120;    
    tx_idle_timeout: integer range 0 to 50:= 50;  
    simulation: std_logic := '0');
  port (
    rst_n_i           : in std_logic;
    clk_ref_i         : in std_logic;
    clk_sys_i         : in std_logic;
    snk_i             : in  t_wrf_sink_in;
    snk_o             : out t_wrf_sink_out;
    src_o             : out t_wrf_source_out;
    src_i             : in  t_wrf_source_in;
    udp_rx_data       : out std_logic_vector(7 downto 0);
    udp_rx_data_valid : out std_logic;
    udp_rx_sof        : out std_logic;
    udp_rx_eof        : out std_logic;
    udp_tx_data       : in  std_logic_vector(7 downto 0):= (others=>'0');
    udp_tx_data_valid : in  std_logic:= '0';
    udp_tx_sof        : in  std_logic:= '0';
    udp_tx_eof        : in  std_logic:= '0';
    udp_tx_cts        : out std_logic;
    udp_tx_ack        : out std_logic;
    udp_tx_nak        : out std_logic;
    connection_reset  : in std_logic_vector((ntcpstreams-1) downto 0):=(others=>'0');
    tcp_rx_data       : out std_logic_vector(7 downto 0);
    tcp_rx_data_valid : out std_logic;
    tcp_rx_rts        : out std_logic;
    tcp_rx_cts        : in  std_logic:='1';
    tcp_tx_data       : in  std_logic_vector(7 downto 0):= (others=>'0');
    tcp_tx_data_valid : in  std_logic:='0';
    tcp_tx_cts        : out std_logic;
    cfg_slave_in  : in t_wishbone_slave_in:=cc_dummy_slave_in;
    cfg_slave_out : out t_wishbone_slave_out;
    my_mac_addr   : in std_logic_vector(47 downto 0):=x"1234567890ab";
    my_ip_addr    : in std_logic_vector(31 downto 0):=x"c0ab0008";
    my_subnet_mask: in std_logic_vector(31 downto 0):=x"ffffff00";
    my_gateway    : in std_logic_vector(31 downto 0):=x"c0ab0001";
    tcp_local_port_no: in std_logic_vector(15 downto 0):=x"dcba";
    udp_rx_dest_port_no: in std_logic_vector(15 downto 0):=x"abcd";
    udp_tx_dest_ip_addr: in std_logic_vector(31 downto 0):=x"c0ab0201";
    udp_tx_source_port_no: in std_logic_vector(15 downto 0):=x"abcd";
    udp_tx_dest_port_no: in std_logic_vector(15 downto 0):=x"abcd");
end component;

component user_udp_demo is
  port(
    clk_i 				   	      : in std_logic;
    rst_n_i 					      : in std_logic;
    udp_rx_data             : out std_logic_vector(7 downto 0);
    udp_rx_data_valid       : out std_logic;
    udp_rx_sof              : out std_logic;
    udp_rx_eof              : out std_logic;
    udp_tx_data         		: out std_logic_vector(7 downto 0);
    udp_tx_data_valid   		: out std_logic;
    udp_tx_sof          		: out std_logic;
    udp_tx_eof          		: out std_logic;
    udp_tx_cts          		: in std_logic;
    udp_tx_ack          		: in std_logic;
    udp_tx_nak          		: in std_logic);
end component;

component user_tcp_demo is
  port (
    clk_i : in std_logic;
    rst_n_i: in std_logic;
    tcp_rx_data: in std_logic_vector(7 downto 0);
    tcp_rx_data_valid:in std_logic;
    tcp_tx_data: out std_logic_vector(7 downto 0);
    tcp_tx_data_valid:out std_logic;
    tcp_tx_cts: in std_logic;
    tcp_rx_rts: in std_logic);
end component ; -- user_tcp_demo

------------------------------------------------------------------------------
-- Signals declaration
------------------------------------------------------------------------------
-- Reset
  signal rst_n_i:std_logic;
-- Clock
  signal fpga_clk_i:std_logic;
  signal clk_ref_i,clk_sys_i: std_logic;
  signal clk_dmtd_i: std_logic;
  signal clk_gtp0_i,clk_gtp1_i:std_logic;
  signal clk_20m_vcxo_buf:std_logic;
  signal pllout_clk_62_5,pllout_clk_125:std_logic;
  signal pllout_clk_fb_ref,pllout_clk_fb_dmtd:std_logic;
  signal pllout_clk_dmtd:std_logic;
  signal fpga_scl_o : std_logic;
  signal fpga_scl_i : std_logic;
  signal fpga_sda_o : std_logic;
  signal fpga_sda_i : std_logic;
  signal thermo_id_i: std_logic;
  signal thermo_id_o: std_logic;
  signal sfp0_mod_def1_i : std_logic;
  signal sfp0_mod_def1_o : std_logic;
  signal sfp0_mod_def2_i : std_logic;
  signal sfp0_mod_def2_o : std_logic;
  signal sfp1_mod_def1_i : std_logic;
  signal sfp1_mod_def1_o : std_logic;
  signal sfp1_mod_def2_i : std_logic;
  signal sfp1_mod_def2_o : std_logic;
  signal dac_hpll_load_p1 : std_logic;
  signal dac_dpll_load_p1 : std_logic;
  signal dac_hpll_data    : std_logic_vector(15 downto 0);
  signal dac_dpll_data    : std_logic_vector(15 downto 0);
  signal ext_snk_i : t_wrf_sink_in;
  signal ext_snk_o : t_wrf_sink_out;
  signal ext_src_o : t_wrf_source_out:=c_dummy_snk_in;
  signal ext_src_i : t_wrf_source_in;  
  signal ext_slave_in:t_wishbone_slave_in;
  signal ext_slave_out:t_wishbone_slave_out;
  signal udp_rx_data: std_logic_vector(7 downto 0) := (others => '0');
  signal udp_rx_data_valid: std_logic := '0';
  signal udp_rx_sof: std_logic := '0';
  signal udp_rx_eof: std_logic := '0';
  signal udp_tx_data: std_logic_vector(7 downto 0) := (others => '0');
  signal udp_tx_data_valid: std_logic := '0';
  signal udp_tx_sof: std_logic := '0';
  signal udp_tx_eof: std_logic := '0';
  signal udp_tx_cts: std_logic;
  signal udp_tx_ack: std_logic;
  signal udp_tx_nak: std_logic;
  signal tcp_rx_data       : std_logic_vector(7 downto 0):= (others=>'0');
  signal tcp_rx_data_valid : std_logic;
  signal tcp_rx_rts        : std_logic;
  signal tcp_rx_cts        : std_logic;
  signal tcp_tx_data       : std_logic_vector(7 downto 0):= (others=>'0');
  signal tcp_tx_data_valid : std_logic;
  signal tcp_tx_cts        : std_logic;
  signal ext_my_mac_addr   :    std_logic_vector(47 downto 0):=x"2233076cb3b5"; -- debug mac address
  signal ext_my_ip_addr    :    std_logic_vector(31 downto 0):=x"c0a80024";
  signal ext_my_subnet_mask:    std_logic_vector(31 downto 0):=x"ffffff00";
  signal ext_my_gateway    :    std_logic_vector(31 downto 0):=x"c0a80001";
  signal ext_tcp_local_port_no: std_logic_vector(15 downto 0):=x"dcba";
  signal ext_udp_rx_dest_port_no:  std_logic_vector(15 downto 0):=x"dcba";
  signal ext_udp_tx_dest_ip_addr:  std_logic_vector(31 downto 0):=x"c0a80001";
  signal ext_udp_tx_source_port_no:  std_logic_vector(15 downto 0):=x"abcd";
  signal ext_udp_tx_dest_port_no:  std_logic_vector(15 downto 0):=x"abcd";
  
begin

U_Reset_Gen : cute_reset_gen
  port map (
	  clk_sys_i        => clk_sys_i,
--    rst_button_n_a_i => '1',
    rst_n_o          => rst_n_i);

cmp_refclk_buf : IBUFGDS
  generic map (
    DIFF_TERM    => true,             -- Differential Termination
    IBUF_LOW_PWR => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD   => "DEFAULT")
  port map (
    O  => fpga_clk_i,            -- Buffer output
    I  => fpga_clk_p,  -- Diff_p buffer input (connect directly to top-level port)
    IB => fpga_clk_n); -- Diff_n buffer input (connect directly to top-level port)

cmp_clk_vcxo_buf : BUFG
  port map (
    O => clk_20m_vcxo_buf,
    I => clk20);
		
--cmp_gtp0_dedicated_clk_buf : IBUFDS
--  generic map(
--    DIFF_TERM    => true,
--    IBUF_LOW_PWR => true,
--    IOSTANDARD   => "DEFAULT")
--  port map (
--    O  => clk_gtp0_i,
--    I  => sfp0_ref_clk_p,
--    IB => sfp0_ref_clk_n);

cmp_gtp1_dedicated_clk_buf : IBUFDS
  generic map(
    DIFF_TERM    => true,
    IBUF_LOW_PWR => true,
    IOSTANDARD   => "DEFAULT")
  port map (
    O  => clk_gtp1_i,
    I  => sfp1_ref_clk_p,
    IB => sfp1_ref_clk_n);

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
    CLKIN    => fpga_clk_i);

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
    CLKOUT2_DIVIDE     => 16,         -- 62.5 MHz
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

cmp_clk_sys_buf : BUFG
  port map (
    O => clk_sys_i,
    I => pllout_clk_62_5);

cmd_clk_ref_buf: BUFG
  port map(
    O => clk_ref_i,
    I => pllout_clk_125);

cmp_clk_dmtd_buf : BUFG
  port map (
    O => clk_dmtd_i,
    I => pllout_clk_dmtd);

U_WR_CORE : cutedp_wrc
  generic map(
    g_etherbone_enable => true,
    g_multiboot_enable => true)
  port map (
    clk_20m_i   => clk_20m_vcxo_buf,
    clk_sys_i   => clk_sys_i,
    clk_dmtd_i  => clk_dmtd_i,
    clk_ref_i   => clk_ref_i,
--    clk_gtp0_i   => clk_gtp0_i,
    clk_gtp1_i   => clk_gtp1_i,
    rst_n_i     => rst_n_i,
    sfp0_led_o  => sfp0_led,
    sfp1_led_o  => sfp1_led,
    dac_sclk_o  => plldac_sclk,
    dac_din_o   => plldac_din,
    dac_clr_n_o => plldac_clr_n,
    dac_ldac_n_o=> plldac_load_n,
    dac_sync_n_o=> plldac_sync_n,
    fpga_scl_i  => fpga_scl_i,
    fpga_scl_o  => fpga_scl_o,
    fpga_sda_i  => fpga_sda_i,
    fpga_sda_o  => fpga_sda_o,
    thermo_id_i => thermo_id_i,
    thermo_id_o => thermo_id_o,
    fpga_prom_cclk_o=> fpga_cclk,
    fpga_prom_cso_b_n_o=> fpga_cso_b,
    fpga_prom_mosi_o=> fpga_mosi,
    fpga_prom_miso_i=> fpga_din,
--    sfp0_txp_o   => sfp0_tx_p,
--    sfp0_txn_o   => sfp0_tx_n,
--    sfp0_rxp_i   => sfp0_rx_p,
--    sfp0_rxn_i   => sfp0_rx_n,
--    sfp0_mod_def0_i=> sfp0_mod_def0,
--    sfp0_mod_def1_i=> sfp0_mod_def1_i,
--    sfp0_mod_def1_o=> sfp0_mod_def1_o,
--    sfp0_mod_def2_i=> sfp0_mod_def2_i,
--    sfp0_mod_def2_o=> sfp0_mod_def2_o,
--    sfp0_rate_select_i=> '1',
--    sfp0_rate_select_o=> open,
--    sfp0_tx_fault_i=> sfp0_tx_fault,
--    sfp0_tx_disable_o=> sfp0_tx_disable,
--    sfp0_los_i   => sfp0_los,
    sfp1_txp_o   => sfp1_tx_p,
    sfp1_txn_o   => sfp1_tx_n,
    sfp1_rxp_i   => sfp1_rx_p,
    sfp1_rxn_i   => sfp1_rx_n,
    sfp1_mod_def0_i=> sfp1_mod_def0,
    sfp1_mod_def1_i=> sfp1_mod_def1_i,
    sfp1_mod_def1_o=> sfp1_mod_def1_o,
    sfp1_mod_def2_i=> sfp1_mod_def2_i,
    sfp1_mod_def2_o=> sfp1_mod_def2_o,
    sfp1_rate_select_i=> '1',
    sfp1_rate_select_o=> open,
    sfp1_tx_fault_i=> sfp1_tx_fault,
    sfp1_tx_disable_o=> sfp1_tx_disable,
    sfp1_los_i          => sfp1_tx_los,
    uart_rxd_i          => uart_rx,
    uart_txd_o          => uart_tx,
    pps_o               => pps_out,
    tm_time_valid_o     => open,
    tm_tai_o            => open,
    tm_cycles_o         => open,
    ext_snk_o           => ext_src_i,
    ext_snk_i           => ext_src_o,
    ext_src_o           => ext_snk_i,
    ext_src_i           => ext_snk_o,
    ext_master_i        => ext_slave_out,
    ext_master_o        => ext_slave_in);

u_xwr_com5402: xwr_com5402
  port map(
    rst_n_i           => rst_n_i,
    clk_ref_i         => clk_ref_i,
    clk_sys_i         => clk_sys_i,
    snk_i             => ext_snk_i,
    snk_o             => ext_snk_o,
    src_o             => ext_src_o,
    src_i             => ext_src_i,
    connection_reset  => (others=>'0'),
    udp_rx_data       => udp_rx_data,
    udp_rx_data_valid => udp_rx_data_valid,
    udp_rx_sof        => udp_rx_sof,
    udp_rx_eof        => udp_rx_eof,
    udp_tx_data       => udp_tx_data,
    udp_tx_data_valid => udp_tx_data_valid,
    udp_tx_sof        => udp_tx_sof,
    udp_tx_eof        => udp_tx_eof,
    udp_tx_cts        => udp_tx_cts,
    udp_tx_ack        => udp_tx_ack,
    udp_tx_nak        => udp_tx_nak,
    tcp_rx_data       => tcp_rx_data,
    tcp_rx_data_valid => tcp_rx_data_valid,
    tcp_tx_data       => tcp_tx_data,
    tcp_tx_data_valid => tcp_tx_data_valid,
    tcp_tx_cts        => tcp_tx_cts,
    cfg_slave_in      => ext_slave_in,
    cfg_slave_out     => ext_slave_out,
    my_mac_addr       => ext_my_mac_addr,
    my_ip_addr        => ext_my_ip_addr,
    my_subnet_mask    => ext_my_subnet_mask,
    my_gateway        => ext_my_gateway,
    tcp_local_port_no=>ext_tcp_local_port_no,
    udp_rx_dest_port_no=>ext_udp_rx_dest_port_no,
    udp_tx_dest_ip_addr=>ext_udp_tx_dest_ip_addr,
    udp_tx_source_port_no=>ext_udp_tx_source_port_no,
    udp_tx_dest_port_no=>ext_udp_tx_dest_port_no);

inst_udp_demo: user_udp_demo
  port map(
    clk_i                 => clk_ref_i,
    rst_n_i               => rst_n_i,
    udp_rx_data           => udp_rx_data,
    udp_rx_data_valid     => udp_rx_data_valid,
    udp_rx_sof            => udp_rx_sof,
    udp_rx_eof            => udp_rx_eof,
    udp_tx_data           => udp_tx_data,
    udp_tx_data_valid     => udp_tx_data_valid,
    udp_tx_sof            => udp_tx_sof,
    udp_tx_eof            => udp_tx_eof,
    udp_tx_cts            => udp_tx_cts,
    udp_tx_ack            => udp_tx_ack,
    udp_tx_nak            => udp_tx_nak);

Inst_tcp_demo: user_tcp_demo
  port map(
    clk_i         	 	=> clk_ref_i,
    rst_n_i       	 	=> rst_n_i,
    tcp_rx_data   		=> tcp_rx_data,
    tcp_rx_data_valid => tcp_rx_data_valid,
    tcp_tx_data   		=> tcp_tx_data,
    tcp_tx_data_valid => tcp_tx_data_valid,
    tcp_tx_cts    		=> tcp_tx_cts,
    tcp_rx_rts    		=> '1');

  fpga_scl  <= '0' when fpga_scl_o = '0' else 'Z';
  fpga_sda  <= '0' when fpga_sda_o = '0' else 'Z';
  fpga_scl_i  <= fpga_scl;
  fpga_sda_i  <= fpga_sda;

--  sfp0_mod_def1 <= '0' when sfp0_mod_def1_o = '0' else 'Z';
--  sfp0_mod_def2 <= '0' when sfp0_mod_def2_o = '0' else 'Z';
--  sfp0_mod_def1 <= sfp0_mod_def1_b;
--  sfp0_mod_def2 <= sfp0_mod_def2_b;
  sfp1_mod_def1 <= '0' when sfp1_mod_def1_o = '0' else 'Z';
  sfp1_mod_def2 <= '0' when sfp1_mod_def2_o = '0' else 'Z';
  sfp1_mod_def1_i <= sfp1_mod_def1;
  sfp1_mod_def2_i <= sfp1_mod_def2;
	
  one_wire <= '0' when thermo_id_o = '1' else 'Z';
  thermo_id_i  <= one_wire;

end rtl;
