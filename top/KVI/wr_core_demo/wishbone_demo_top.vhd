library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.pcie_wb_pkg.all;
 
entity wishbone_demo_top is
  port(
    -----------------------------------------
    -- Clocking pins
    -----------------------------------------
    clk125_i : in std_logic;

    -----------------------------------------
    -- PCI express pins
    -----------------------------------------
    pcie_refclk_i : in  std_logic;
    pcie_rstn_i   : in  std_logic;
    pcie_rx_i     : in  std_logic_vector(3 downto 0);
    pcie_tx_o     : out std_logic_vector(3 downto 0);
      
    -----------------------------------------------------------------------
    -- User LEDs
    -----------------------------------------------------------------------
    leds_o			: out std_logic_vector(7 downto 0);
    HPLA1			: inout std_logic_vector(15 downto 0)
--    HPLA2			: inout std_logic_vector(15 downto 0)
	 
	 );
end wishbone_demo_top;

architecture rtl of wishbone_demo_top is

  component sys_pll_quad -- Altera megafunction
    port(
      inclk0 : in  std_logic;
      areset : in  std_logic;
      c0     : out std_logic;
      c1     : out std_logic;
      c2     : out std_logic;
      c3     : out std_logic;
      locked : out std_logic);
  end component;

 component SinglePulseGeneratorModule is
	generic(
		g_pulsetimebits                        : integer := 32
	);
	port(
		clk_sys_i                              : in std_logic;
		rst_n_i                                : in std_logic;
		gpio_slave_i                           : in t_wishbone_slave_in;
		gpio_slave_o                           : out t_wishbone_slave_out;
		wr_clock_i                             : in std_logic;
		trigger_i                              : in std_logic;
		pulse_o                                : out std_logic
    );
  end component;

component PatternGeneratorModule is
	generic(
		g_nrofoutputs                          : integer := 32;
		g_patterndepthbits                     : integer := 7;
		g_periodbits                           : integer := 16
	);
	port(
		clk_sys_i                              : in std_logic;
		rst_n_i                                : in std_logic;
		gpio_slave_i                           : in t_wishbone_slave_in;
		gpio_slave_o                           : out t_wishbone_slave_out;
		wr_clock_i                             : in std_logic;
		trigger_i                              : in std_logic;
		pattern_o                              : out std_logic_vector(g_nrofoutputs-1 downto 0)
    );
  end component;

  component simplers232module is
	generic(
		CLOCK_FREQUENCY    : integer := 125000000
	);
	port(
		clk_sys_i                              : in std_logic;
		rst_n_i                                : in std_logic;
		gpio_slave_i                           : in t_wishbone_slave_in;
		gpio_slave_o                           : out t_wishbone_slave_out;
		serial_i                               : in std_logic;
		serial_o                               : out std_logic
    );
  end component;

component BuTis_clock_generator is
  port(
		clk_sys_i                              : in std_logic;
		scanclk_i                              : in std_logic;
		rst_n_i                                : in std_logic;
		gpio_slave_i                           : in t_wishbone_slave_in;
		gpio_slave_o                           : out t_wishbone_slave_out;
		wr_clock_i                             : in  std_logic;
		wr_PPSpulse_i                          : in  std_logic;
		BuTis_C2_ph0_o                         : out std_logic;
		BuTis_C2_o                             : out std_logic;
		BuTis_T0_o                             : out std_logic;
		BuTis_T0_timestamp_o                   : out std_logic;
		error_o                                : out std_logic);
end component;

component TimestampDecoder is
  generic(
		g_timestampbytes                         : integer := 8;
		g_clockcyclesperbit                      : integer := 4;
		g_RScodewords                            : integer := 4;
		g_BuTis_ratio                            : integer := 2000;
		g_BuTis_T0_precision                     : integer := 100);
  port(
		BuTis_C2_i                               : in std_logic;
		BuTis_C2div2_i                           : in std_logic;
		reset_i                                  : in std_logic;
		serial_i                                 : in std_logic;
		BuTis_T0_o                               : out std_logic;
		timestamp_o                              : out std_logic_vector(g_timestampbytes*8-1 downto 0);
		timestamp_write_o                        : out std_logic;
		corrected_o                              : out std_logic;
		error_o                                  : out std_logic);
end component;

component readTimestampModule is
	generic(
		g_timestampbytes                       : integer := 8
	);
	port(
		clk_sys_i                              : in std_logic;
		rst_n_i                                : in std_logic;
		gpio_slave_i                           : in t_wishbone_slave_in;
		gpio_slave_o                           : out t_wishbone_slave_out;
		BuTis_C2_i                             : in std_logic;
		timestamp_i                            : in std_logic_vector(g_timestampbytes*8-1 downto 0);
		timestamp_write_i                      : in std_logic;
		timestamp_corrected_i                  : in std_logic;
		timestamp_error_i                      : in std_logic
    );
end component;

  constant c_xwb_gpio32_sdb : t_sdb_device := (
    abi_class     => x"0000", -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"7", -- 8/16/32-bit port granularity
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"0000000000000007", -- Two 4 byte registers
    product => (
    vendor_id     => x"0000000000000651", -- GSI
    device_id     => x"35aa6b95",
    version       => x"00000001",
    date          => x"20120305",
    name          => "GSI_GPIO_32        ")));

	 
	constant c_xwb_SinglePulseGen_sdb : t_sdb_device := (
    abi_class     => x"0000", -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4", -- 8/16/32-bit port granularity
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"000000000000000f", -- four 4 byte registers
    product => (
    vendor_id     => x"0000000000000651", -- GSI
    device_id     => x"35aa6b96",
    version       => x"00000001",
    date          => x"20120830",
    name          => "KVI_SINGLEPULSE    ")));
	 
	constant c_xwb_PatternGen_sdb : t_sdb_device := (
    abi_class     => x"0000", -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4", -- 8/16/32-bit port granularity
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"000000000000000f", -- four 4 byte registers
    product => (
    vendor_id     => x"0000000000000651", -- GSI
    device_id     => x"35aa6b97",
    version       => x"00000001",
    date          => x"20120830",
    name          => "KVI_PATTERNGEN     ")));

	constant c_xwb_BuTiSclock_sdb : t_sdb_device := (
    abi_class     => x"0000", -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4", -- 8/16/32-bit port granularity
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"000000000000000f", -- four 4 byte registers
    product => (
    vendor_id     => x"0000000000000651", -- GSI
    device_id     => x"35aa6b98",
    version       => x"00000001",
    date          => x"20120830",
    name          => "KVI_BUTISCLOCK     ")));

	constant c_xwb_simplers232_sdb : t_sdb_device := (
    abi_class     => x"0000", -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4", -- 8/16/32-bit port granularity
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"000000000000001f", -- five 4 byte registers
    product => (
    vendor_id     => x"0000000000000651", -- GSI
    device_id     => x"35aa6b99",
    version       => x"00000001",
    date          => x"20120830",
    name          => "KVI_RS232          ")));

   constant c_xwb_readTimestamp_sdb : t_sdb_device := (
    abi_class     => x"0000", -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4", -- 8/16/32-bit port granularity
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"000000000000001f", -- six 4 byte registers
    product => (
    vendor_id     => x"0000000000000651", -- GSI
    device_id     => x"35aa6b9a",
    version       => x"00000001",
    date          => x"20120830",
    name          => "KVI_READTIMESTAMP  ")));
	 
	 -- Top crossbar layout
  constant c_slaves : natural := 8;
  constant c_masters : natural := 5;
  constant c_dpram_size : natural := 16384; -- in 32-bit words (64KB)
  constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
   (0 => f_sdb_embed_device(f_xwb_dpram(c_dpram_size), x"00000000"),
    1 => f_sdb_embed_device(c_xwb_gpio32_sdb,          x"00100400"),
    2 => f_sdb_embed_device(c_xwb_dma_sdb,             x"00100500"),
    3 => f_sdb_embed_device(c_xwb_SinglePulseGen_sdb,  x"00110000"),
    4 => f_sdb_embed_device(c_xwb_PatternGen_sdb,      x"00110400"),
	 5 => f_sdb_embed_device(c_xwb_BuTiSclock_sdb,      x"00110500"),
	 6 => f_sdb_embed_device(c_xwb_simplers232_sdb,     x"00110600"),
	 7 => f_sdb_embed_device(c_xwb_readTimestamp_sdb,   x"00110700")
	 );
  constant c_sdb_address : t_wishbone_address := x"00100000";

  signal cbar_slave_i  : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_o  : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_i : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_o : t_wishbone_master_out_array(c_slaves-1 downto 0);

  signal clk_sys, clk_cal, rstn, locked : std_logic;
  signal lm32_interrupt : std_logic_vector(31 downto 0);
  
  signal gpio_slave_o : t_wishbone_slave_out;
  signal gpio_slave_i : t_wishbone_slave_in;
  
  signal singlepulsegenerator_slave_o : t_wishbone_slave_out;
  signal singlepulsegenerator_slave_i : t_wishbone_slave_in;
  
  signal patterngenerator_slave_o : t_wishbone_slave_out;
  signal patterngenerator_slave_i : t_wishbone_slave_in;

  signal trigger_s,triggerin_s,pulse_s : std_logic;
  signal pattern_s : std_logic_vector(7 downto 0);
 
  signal reset_s : std_logic := '0';
  signal r_leds : std_logic_vector(7 downto 0);
  signal r_reset : std_logic;
  signal pulsebusy : std_logic := '0';

  signal BuTisclock_slave_o : t_wishbone_slave_out;
  signal BuTisclock_slave_i : t_wishbone_slave_in;

  signal simplers232_slave_o : t_wishbone_slave_out;
  signal simplers232_slave_i : t_wishbone_slave_in;
  signal serial_in_s : std_logic := '0';
  signal serial_out_s : std_logic := '0';
  
  
  signal readTimestamp_slave_o : t_wishbone_slave_out;
  signal readTimestamp_slave_i : t_wishbone_slave_in;
  
  signal BuTis_C2_s : std_logic := '0';
  signal clock200MHz_S : std_logic := '0';
  signal clock100MHz_S : std_logic := '0';
  signal BuTis_T0_in_s : std_logic := '0';
  signal BuTis_T0_out_s : std_logic := '0';
  signal BuTis_T0_in_sync_s : std_logic := '0';
  
  
  signal wr_PPSpulse_s : std_logic := '0';
  signal BuTis_T0_s : std_logic := '0';
  signal BuTis_T0_rec_s : std_logic := '0';
  
  signal encoder_error_s : std_logic := '0';
  signal timestamp_write_s : std_logic := '0';
  signal decoder_corrected_s : std_logic := '0';
  signal decoder_error_s : std_logic := '0';
  signal timestamp_s  : std_logic_vector(63 downto 0) := (others => '0');
 
  signal clock200MHzdiv2_s : std_logic := '0';
  signal clk_sysdiv2_s : std_logic := '0';
  signal clock200MHz_ph0_s : std_logic := '0';
  signal clock200MHzdiv2_ph0_s : std_logic := '0';



   begin
  -- Obtain core clocking
  sys_pll_inst : sys_pll_quad -- Altera megafunction
    port map (
      inclk0 => clk125_i,    -- 125Mhz oscillator from board
      areset => '0',
      c0     => clk_sys,     -- 125MHz system clk (cannot use external pin as clock for RAM blocks)
      c1     => clk_cal,     -- 50Mhz calibration clock for Altera reconfig cores
		c2     => clock200MHz_s,
		c3     => clock100MHz_s,
      locked => locked);     -- '1' when the PLL has locked
  
  

  
  -- Hold the entire WB bus reset until the PLL has locked
  rstn <= locked;
  
  -- The top-most Wishbone B.4 crossbar
  interconnect : xwb_sdb_crossbar
   generic map(
     g_num_masters => c_masters,
     g_num_slaves  => c_slaves,
     g_registered  => true,
     g_wraparound  => false, -- Should be true for nested buses
     g_layout      => c_layout,
     g_sdb_addr    => c_sdb_address)
   port map(
     clk_sys_i     => clk_sys,
     rst_n_i       => rstn,
     -- Master connections (INTERCON is a slave)
     slave_i       => cbar_slave_i,
     slave_o       => cbar_slave_o,
     -- Slave connections (INTERCON is a master)
     master_i      => cbar_master_i,
     master_o      => cbar_master_o);
  
  -- Master 0 is the PCIe bridge
  PCIe : pcie_wb
    generic map(
      sdb_addr => c_sdb_address)
    port map(
      clk125_i      => clk_sys,       -- Free running clock
      cal_clk50_i   => clk_cal,       -- Transceiver global calibration clock
      wb_rstn_i        => rstn,          -- Reset for the PCIe decoder logic
      pcie_refclk_i => pcie_refclk_i, -- External PCIe 100MHz bus clock
      pcie_rstn_i   => pcie_rstn_i,   -- External PCIe system reset pin
      pcie_rx_i     => pcie_rx_i,
      pcie_tx_o     => pcie_tx_o,
      wb_clk        => clk_sys,       -- Desired clock for the WB bus
      master_o      => cbar_slave_i(0),
      master_i      => cbar_slave_o(0));
  
  -- The LM32 is master 1+2
  LM32 : xwb_lm32
    generic map(
      g_profile => "medium_icache_debug") -- Including JTAG and I-cache (no divide)
    port map(
      clk_sys_i => clk_sys,
      rst_n_i   => rstn and not r_reset,
      irq_i     => lm32_interrupt,
      dwb_o     => cbar_slave_i(1), -- Data bus
      dwb_i     => cbar_slave_o(1),
      iwb_o     => cbar_slave_i(2), -- Instruction bus
      iwb_i     => cbar_slave_o(2));
  
  -- The other 31 interrupt pins are unconnected
  lm32_interrupt(31 downto 1) <= (others => '0');
  
  -- A DMA controller is master 3+4, slave 2, and interrupt 0
  dma : xwb_dma
    port map(
      clk_i       => clk_sys,
      rst_n_i     => rstn,
      slave_i     => cbar_master_o(2),
      slave_o     => cbar_master_i(2),
      r_master_i  => cbar_slave_o(3),
      r_master_o  => cbar_slave_i(3),
      w_master_i  => cbar_slave_o(4),
      w_master_o  => cbar_slave_i(4),
      interrupt_o => lm32_interrupt(0));
  
  -- Slave 0 is the RAM
  ram : xwb_dpram
    generic map(
      g_size                  => c_dpram_size,
      g_slave1_interface_mode => PIPELINED, -- Why isn't this the default?!
      g_slave2_interface_mode => PIPELINED,
      g_slave1_granularity    => BYTE,
      g_slave2_granularity    => WORD)
    port map(
      clk_sys_i => clk_sys,
      rst_n_i   => rstn,
      -- First port connected to the crossbar
      slave1_i  => cbar_master_o(0),
      slave1_o  => cbar_master_i(0),
      -- Second port disconnected
      slave2_i  => cc_dummy_slave_in, -- CYC always low
      slave2_o  => open);
  
  -- Slave 1 is the example LED driver
  gpio_slave_i <= cbar_master_o(1);
  cbar_master_i(1) <= gpio_slave_o;
  leds_o <= not r_leds;
  
  -- There is a tool called 'wbgen2' which can autogenerate a Wishbone
  -- interface and C header file, but this is a simple example.
  gpio : process(clk_sys)
  begin
    if rising_edge(clk_sys) then
      -- It is vitally important that for each occurance of
      --   (cyc and stb and not stall) there is (ack or rty or err)
      --   sometime later on the bus.
      --
      -- This is an easy solution for a device that never stalls:
      gpio_slave_o.ack <= gpio_slave_i.cyc and gpio_slave_i.stb;
      
      -- Detect a write to the register byte
      if gpio_slave_i.cyc = '1' and gpio_slave_i.stb = '1' and
         gpio_slave_i.we = '1' and gpio_slave_i.sel(0) = '1' then
			-- Register 0x0 = LEDs, 0x4 = CPU reset
			if gpio_slave_i.adr(2) = '0' then
				r_leds <= gpio_slave_i.dat(7 downto 0);
			else
				r_reset <= gpio_slave_i.dat(0);
			end if;
      end if;
      if gpio_slave_i.adr(2) = '0' then
        gpio_slave_o.dat(31 downto 1) <= (others => '0');
        gpio_slave_o.dat(0) <= r_reset;
      else
        gpio_slave_o.dat(31 downto 8) <= (others => '0');
        gpio_slave_o.dat(7 downto 0) <= r_leds;
      end if;
    end if;
  end process;
  gpio_slave_o.int <= '0'; -- In my opinion, this should not be in the structure,
                           -- but it is in there. Bother Thomasz to remove it.
  gpio_slave_o.err <= '0';
  gpio_slave_o.rty <= '0';
  gpio_slave_o.stall <= '0'; -- This simple example is always ready
  
debounce : process(clk_sys)
constant debouncetime : integer := 15;
variable cnt : integer range 0 to debouncetime;
begin
    if rising_edge(clk_sys) then
		if rstn='0' then
			pulsebusy <= triggerin_s;
			cnt := 0;
			trigger_s <= '0';
		else
			if pulsebusy='0' then
				if cnt<debouncetime then
					trigger_s <= '0';
					if triggerin_s='1' then
						pulsebusy <= '1';
						cnt := 0;
					else
						cnt := cnt+1;
					end if;
				elsif triggerin_s='1' then
					trigger_s <= '1';
					pulsebusy <= '1';
					cnt := 0;
				else
					trigger_s <= '0';
				end if;
			else
				trigger_s <= '0';
				if cnt<debouncetime then
					cnt := cnt+1;
				else
					if triggerin_s='0' then
						pulsebusy <= '0';
						cnt := 0;
					end if;
				end if;
			end if;
		end if;
	 end if;
end process;

  -- pulse/pattern generator I/O
triggerin_s <= HPLA1(0);
serial_in_s <= HPLA1(1);
BuTis_T0_in_s <= HPLA1(2);


HPLA1(0) <= 'Z';
HPLA1(1) <= 'Z';
HPLA1(2) <= 'Z';

HPLA1(3) <= pulse_s;
HPLA1(4) <= BuTis_T0_out_s;
HPLA1(5) <= wr_PPSpulse_s;
HPLA1(6) <= BuTis_T0_s;
HPLA1(7) <= not serial_out_s;
-- HPLA1(7 downto 6) <= (others => 'Z');
HPLA1(12 downto 8) <= pattern_s(4 downto 0);
-- HPLA2 <= (others => 'Z');
HPLA1(13) <= BuTis_T0_rec_s;
HPLA1(14) <= clk_sysdiv2_s;
HPLA1(15) <= clock200MHzdiv2_s;



process(clock200MHz_ph0_s)
begin
	if rising_edge(clock200MHz_ph0_s) then
		clock200MHzdiv2_ph0_s <= not clock200MHzdiv2_ph0_s;
	end if;
end process;process(BuTis_C2_s)
begin
	if rising_edge(BuTis_C2_s) then
		clock200MHzdiv2_s <= not clock200MHzdiv2_s;
	end if;
end process;
process(clk_sys)
begin
	if rising_edge(clk_sys) then
		clk_sysdiv2_s <= not clk_sysdiv2_s;
	end if;
end process;



  -- slave 3 is the Single Pulse generator
  singlepulsegenerator_slave_i <= cbar_master_o(3);
  cbar_master_i(3) <= singlepulsegenerator_slave_o;
 
SinglePulseGeneratorModule1: SinglePulseGeneratorModule 
	generic map(
		g_pulsetimebits => 32
	)
	port map(
		clk_sys_i => clk_sys,
		rst_n_i => rstn,
		gpio_slave_i => singlepulsegenerator_slave_i,
		gpio_slave_o => singlepulsegenerator_slave_o,
		wr_clock_i => clk_sys,
		trigger_i => trigger_s,
		pulse_o => pulse_s
    );

 -- slave 4 is the Pattern generator
  patterngenerator_slave_i <= cbar_master_o(4);
  cbar_master_i(4) <= patterngenerator_slave_o;

PatternGeneratorModule1: PatternGeneratorModule 
	generic map(
		g_nrofoutputs => 8,
		g_patterndepthbits => 7,
		g_periodbits => 16
	)
	port map(
		clk_sys_i => clk_sys,
		rst_n_i => rstn,
		gpio_slave_i => patterngenerator_slave_i,
		gpio_slave_o => patterngenerator_slave_o,
		wr_clock_i => clk_sys,
		trigger_i => trigger_s,
		pattern_o => pattern_s
    );

	
-- slave 5 is BuTiS clock generator
  BuTisclock_slave_i <= cbar_master_o(5);
  cbar_master_i(5) <= BuTisclock_slave_o;	
BuTis_clock_generator1: BuTis_clock_generator port map(
		clk_sys_i => clk_sys,
		scanclk_i => clk_cal,
		rst_n_i => rstn,
		gpio_slave_i => BuTisclock_slave_i,
		gpio_slave_o => BuTisclock_slave_o,
		wr_clock_i => clk_sys,
		wr_PPSpulse_i => wr_PPSpulse_s,
		BuTis_C2_ph0_o => clock200MHz_ph0_s,
		BuTis_C2_o => BuTis_C2_s,
		BuTis_T0_o => BuTis_T0_s,
		BuTis_T0_timestamp_o => BuTis_T0_out_s,
		error_o => encoder_error_s);
	 
 -- slave 6 is rs232
  simplers232_slave_i <= cbar_master_o(6);
  cbar_master_i(6) <= simplers232_slave_o;	 
simplers232module1: simplers232module port map(
		clk_sys_i => clk_sys,
		rst_n_i => rstn,
		gpio_slave_i => simplers232_slave_i,
		gpio_slave_o => simplers232_slave_o,
		serial_i => serial_in_s,
		serial_o => serial_out_s
    );
 	 

	 
PPS_process : process(clk_sys)
variable counter_1s_v : integer range 0 to 125000000 := 0;
begin
	if rising_edge(clk_sys) then
		if reset_s='1' then	
			counter_1s_v := 0;
			wr_PPSpulse_s <= '0';
		else
			if counter_1s_v<125000000-1 then
				counter_1s_v := counter_1s_v+1;
				wr_PPSpulse_s <= '0';
			else
				counter_1s_v := 0;
				wr_PPSpulse_s <= '1';
			end if;
		end if;
	end if;
end process;
			
reset_s <= '1' when (rstn='0') else '0';
TimestampDecoder1: TimestampDecoder port map(
		BuTis_C2_i => clock200MHz_s,
		BuTis_C2div2_i => clock100MHz_s,
		reset_i => reset_s,
		serial_i => BuTis_T0_in_sync_s,
		BuTis_T0_o => BuTis_T0_rec_s,
		timestamp_o => timestamp_s,
		timestamp_write_o => timestamp_write_s,
		corrected_o => decoder_corrected_s,
		error_o => decoder_error_s);

-- slave 7 is rs232
  readTimestamp_slave_i <= cbar_master_o(7);
  cbar_master_i(7) <= readTimestamp_slave_o;	
readTimestampModule1: readTimestampModule port map(
		clk_sys_i => clk_sys,
		rst_n_i => rstn,
		gpio_slave_i => readTimestamp_slave_i,
		gpio_slave_o => readTimestamp_slave_o,
		BuTis_C2_i => clock200MHz_s,
		timestamp_i => timestamp_s,
		timestamp_write_i => timestamp_write_s,
		timestamp_corrected_i => decoder_corrected_s,
		timestamp_error_i => decoder_error_s);
		
serialsync_process : process(clock200MHz_s)
begin
	if rising_edge(clock200MHz_s) then
		BuTis_T0_in_sync_s <= BuTis_T0_in_s;
	end if;
end process;
		
	
  
end rtl;
