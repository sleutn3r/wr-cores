-------------------------------------------------------------------------------
-- Title      : Pattern Generator
-- Project    : White Rabbit pattern generator
-------------------------------------------------------------------------------
-- File       : SinglePulseGenerator.vhd
-- Author     : Peter Schakel
-- Company    : KVI
-- Created    : 2012-08-13
-- Last update: 2012-09-28
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- Outputs a digital pattern.
-- The pattern is written sequentially to memory.
-- After an external trigger this data is read back and put on the pattern output 
-- on each period (1 or more White Rabbit clock cycles).
-- 
-- 
-- Generics
--     g_nrofoutputs : number of parallel bits for the pattern
--     g_patterndepthbits : number of bits used for momory addresses: 2^g_patterndepthbits defines number of words in pattern
--
-- Inputs
--     whiterabbit_clock_i : White Rabbit 125MHz clock
--     wishbone_clock_i : 125MHz Whishbone bus clock
--     reset_i : reset: high active
--     data_i : Parallel data with the digital pattern to write into the memory
--     period_i : Number of clockcycles for each pattern output cycle
--     data_write_i : Write signal for the parallel data. The memory address is incremented on each write.
--     data_enable_i : Enable parallel data writing. When this signal is low the memory address is set to zero.
--     enable_i : enable external start (trigger) signal
--     start_i : start the output of the pattern
--     force_start_i : start the output of the pattern, even if enable_i is low. (used for soft trigger).
--
-- Outputs
--     busy_o : Pattern is busy
--     pattern_o : Pattern output
--
-- Components
--     simple_dual_port_ram_dual_clock : dual ported ram at bottom of this vhdl-file
--
--
-------------------------------------------------------------------------------
-- Copyright (c) 2012 KVI / Peter Schakel
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all ;
USE ieee.std_logic_arith.all ;


entity PatternGenerator is
  generic(
    g_nrofoutputs : integer := 32;
    g_patterndepthbits : integer := 7;
	g_periodbits : integer := 16);
  port(
	whiterabbit_clock_i                      : in  std_logic;
	wishbone_clock_i                         : in  std_logic;
	reset_i                                  : in  std_logic;
	data_i                                   : in  std_logic_vector(g_nrofoutputs-1 downto 0);
	data_write_i                             : in  std_logic;
	period_i                                 : in  std_logic_vector(g_periodbits-1 downto 0);
	data_enable_i                            : in  std_logic;
	enable_i                                 : in  std_logic;
	start_i                                  : in  std_logic;
	force_start_i                            : in  std_logic;
	busy_o                                   : out std_logic;
	pattern_o                                : out std_logic_vector(g_nrofoutputs-1 downto 0));
end PatternGenerator;

architecture rtl of PatternGenerator is

component simple_dual_port_ram_dual_clock is
  generic(
    DATA_WIDTH : natural := g_nrofoutputs;
    ADDR_WIDTH : natural := g_patterndepthbits);
  port(
    rclk          : in std_logic;
    wclk          : in std_logic;
    raddr         : in natural range 0 to 2**ADDR_WIDTH - 1;
    waddr         : in natural range 0 to 2**ADDR_WIDTH - 1;
    data          : in std_logic_vector((DATA_WIDTH-1) downto 0);
    we            : in std_logic := '1';
    q             : out std_logic_vector((DATA_WIDTH -1) downto 0));
end component;

constant zeros               : std_logic_vector(31 downto 0) := (others => '0');

signal mem_readaddress_s     : std_logic_vector(g_patterndepthbits-1 downto 0) := (others => '0');
signal mem_writeaddress_s    : std_logic_vector(g_patterndepthbits-1 downto 0) := (others => '0');
signal mem_raddr_s           : natural range 0 to 2**g_patterndepthbits - 1;
signal mem_waddr_s           : natural range 0 to 2**g_patterndepthbits - 1;

signal mem_writeenable_s     : std_logic := '0';
signal mem_data_out_s        : std_logic_vector(g_nrofoutputs-1 downto 0) := (others => '0');
signal pattern_out_s         : std_logic_vector(g_nrofoutputs-1 downto 0) := (others => '0');
signal data_written_s        : std_logic := '0';
signal pattern_pass_s        : std_logic := '0';
signal nrofvalsmin1_s        : std_logic_vector(g_patterndepthbits-1 downto 0) := (others => '0');
signal busy0_s               : std_logic := '0';
signal busy_s                : std_logic := '0';
signal start_s               : std_logic := '0';

signal periodcounter_s       : std_logic_vector(g_periodbits-1 downto 0) := (others => '0');
signal period_s              : std_logic_vector(g_periodbits-1 downto 0) := (others => '0');

begin

memblock: simple_dual_port_ram_dual_clock port map(
	rclk => whiterabbit_clock_i,
	wclk => wishbone_clock_i,
	raddr => mem_raddr_s,
	waddr => mem_waddr_s,
	data => data_i,
	we => mem_writeenable_s,
	q => mem_data_out_s);
mem_raddr_s <= conv_integer(unsigned(mem_readaddress_s));
mem_waddr_s <= conv_integer(unsigned(mem_writeaddress_s));

pattern_o <= mem_data_out_s when pattern_pass_s='1' else pattern_out_s;
-- process to save the last output data and keep that value, even if different data is being written for the next trigger
save_process : process(whiterabbit_clock_i)
begin
	if rising_edge(whiterabbit_clock_i) then
		if pattern_pass_s='1' then
			pattern_out_s <= mem_data_out_s;
		end if;
	end if;
end process;


mem_writeenable_s <= '1' when data_write_i='1' and data_enable_i='1' else '0';	

-- process to write pattern data in memory 
write_process : process(wishbone_clock_i)
variable reset_v : std_logic := '1';
  begin
    if rising_edge(wishbone_clock_i) then
		if reset_v = '1' then
			mem_writeaddress_s <= (others => '0');
			data_written_s <= '0';
		else
			if data_enable_i='1' then -- data_enable determines that data can be written
				if mem_writeenable_s='1' then
					mem_writeaddress_s <= mem_writeaddress_s+1;
					data_written_s <= '1';
				end if;
			else
				if data_written_s='1' then
					if mem_writeaddress_s=zeros(g_patterndepthbits-1 downto 0) then
						nrofvalsmin1_s <= (others => '1');
					else
						nrofvalsmin1_s <= mem_writeaddress_s-1;
					end if;
				end if;
				data_written_s <= '0';
				mem_writeaddress_s <= (others => '0');
			end if;
		end if;
		reset_v := reset_i;
	end if;
end process;

	
-- process to read the pattern from memory and output it	
pattern_process : process(whiterabbit_clock_i)
variable reset_v        : std_logic := '1';
variable nrofvalsmin1_v : std_logic_vector(g_patterndepthbits-1 downto 0);
  begin
    if rising_edge(whiterabbit_clock_i) then
		if reset_v = '1' then
			mem_readaddress_s <= (others => '0');
			busy0_s <= '0';
			busy_s <= '0';
		else
			if busy0_s='0' then -- if no pattern reading is performed check on trigger
				periodcounter_s <= (others => '0');
				if (enable_i='1' and start_i='1' and start_s='0') or (force_start_i='1') then -- check trigger
					mem_readaddress_s <= (others => '0');
					busy0_s <= '1';
					busy_s <= '1';
					nrofvalsmin1_v := nrofvalsmin1_s;
				else
					busy0_s <= '0';
					busy_s <= '0';
				end if;
			else -- busy0_s='1' : performing pattern reading 
				if periodcounter_s+1<period_s then
					periodcounter_s <= periodcounter_s+1;
				else
					if mem_readaddress_s+1>=nrofvalsmin1_v then
						busy0_s <= '0';
					else
						busy0_s <= '1';
					end if;
					periodcounter_s <= (others => '0');
					if nrofvalsmin1_v/=zeros then
						mem_readaddress_s <= mem_readaddress_s+1;
					end if;
				end if;
			end if;
		end if;
		reset_v := reset_i;
		start_s <= start_i;
		busy_o <= busy_s;
		pattern_pass_s <= busy_s;
		if period_i=zeros(g_periodbits-1 downto 0) then
			period_s(g_periodbits-1 downto 1) <= (others => '0');
			period_s(0) <= '1';
		else
			period_s <= period_i;
		end if;
    end if;
  end process;

  
end;

-- Quartus II VHDL Template
-- Simple Dual-Port RAM with different read/write addresses and
-- different read/write clock

library ieee;
use ieee.std_logic_1164.all;

entity simple_dual_port_ram_dual_clock is

	generic 
	(
		DATA_WIDTH : natural := 8;
		ADDR_WIDTH : natural := 6
	);

	port 
	(
		rclk	: in std_logic;
		wclk	: in std_logic;
		raddr	: in natural range 0 to 2**ADDR_WIDTH - 1;
		waddr	: in natural range 0 to 2**ADDR_WIDTH - 1;
		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic := '1';
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end simple_dual_port_ram_dual_clock;

architecture rtl of simple_dual_port_ram_dual_clock is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

	-- Declare the RAM signal.	
	signal ram : memory_t := (others => (others => '0'));

begin

	process(wclk)
	begin
	if(rising_edge(wclk)) then 
		if(we = '1') then
			ram(waddr) <= data;
		end if;
	end if;
	end process;

	process(rclk)
	begin
	if(rising_edge(rclk)) then 
		q <= ram(raddr);
	end if;
	end process;

end rtl;
