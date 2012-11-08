
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
use std.textio.all;
 
ENTITY PatternGenerator_tb IS
END PatternGenerator_tb;
 
ARCHITECTURE behavior OF PatternGenerator_tb IS 

constant g_nrofoutputs : integer := 8;
constant g_patterndepthbits: integer := 7;
constant g_periodbits: integer := 16;

component PatternGenerator is
  generic(
    g_nrofoutputs : integer := g_nrofoutputs;
	g_patterndepthbits: integer := g_patterndepthbits;
	g_periodbits : integer := g_periodbits);
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
end component;

   signal whiterabbit_clock : std_logic;
   signal wishbone_clock : std_logic;
   signal reset         : std_logic;
   signal data_in       : std_logic_vector(g_nrofoutputs-1 downto 0);
   signal data_write    : std_logic;
   signal data_in_s     : std_logic_vector(g_nrofoutputs-1 downto 0);
   signal data_write_s  : std_logic;
   signal data_enable   : std_logic;
   signal enable        : std_logic;
   signal start         : std_logic;
   signal busy          : std_logic;
   signal pattern_out   : std_logic_vector(g_nrofoutputs-1 downto 0);
   signal period_s      : std_logic_vector(g_periodbits-1 downto 0);


   -- Clock period definitions
   constant bus_period : time := 10 ns;
   constant rt_period : time := 10 ns;
 
BEGIN

   uut: PatternGenerator PORT MAP (
    whiterabbit_clock_i => whiterabbit_clock,
    wishbone_clock_i => wishbone_clock,
    reset_i => reset,
    data_i => data_in_s,
    data_write_i => data_write_s,
	period_i => period_s,
    data_enable_i => data_enable,
    enable_i => enable,
    start_i => start,
    force_start_i => '0',
    busy_o => busy,
    pattern_o => pattern_out);

	
   -- Clock process definitions
   whiterabbit_clock_process :process
   begin
		whiterabbit_clock <= '0';
		wait for rt_period/2;
		whiterabbit_clock <= '1';
		wait for rt_period/2;
   end process;
   wishbone_clock_clock_process :process
   begin
		wishbone_clock <= '0';
		wait for bus_period/2;
		wishbone_clock <= '1';
		wait for bus_period/2;
   end process;
   
sync_process : process(wishbone_clock)
variable reset_v : std_logic := '1';
  begin
    if rising_edge(wishbone_clock) then
		data_in_s <= data_in;
		data_write_s <= data_write;
		end if;
end process;

	
	
   stim_proc: process
		variable l : line;
   begin		
		reset <= '1';
		data_in <= (others => '0');
		data_write <= '0';
		data_enable <= '0';
		period_s <= x"0002";
		enable <= '0';
		start <= '0';
		wait for 100 ns;	
		reset <= '0';

		wait for bus_period*10;
		data_enable <= '1';
		data_in <= x"55";
		wait for bus_period*2;
		data_write <= '1';
		for i in 0 to 0 loop
			wait for bus_period;
			data_in <= data_in+1;
		end loop;
		data_in <= (others => '0');
--		wait for bus_period;
		data_write <= '0';
		wait for bus_period*2;
		data_enable <= '0';
		enable <= '1';
		
		wait for bus_period*10;
		start <= '1';
		wait for bus_period*10;
		start <= '0';


		wait for bus_period*10;
		data_enable <= '1';
		data_in <= x"33";
		wait for bus_period*2;
		data_write <= '1';
		for i in 0 to 0 loop
			wait for bus_period;
			data_in <= data_in+1;
		end loop;
		data_in <= x"55"; -- (others => '0');
		wait for bus_period;
		data_write <= '0';
		wait for bus_period*2;
		data_enable <= '0';
		enable <= '1';
		
		wait for bus_period*10;
		start <= '1';
		wait for bus_period*10;
		start <= '0';

		wait for bus_period*10;
		data_enable <= '1';
		data_in <= x"00";
		wait for bus_period*2;
		data_write <= '1';
		for i in 0 to 3 loop
			wait for bus_period;
			data_in <= data_in+1;
		end loop;
		data_in <= (others => '0');
		wait for bus_period;
		data_write <= '0';
		wait for bus_period*2;
		data_enable <= '0';
		enable <= '1';
		
		wait for bus_period*10;
		start <= '1';
		wait for bus_period*10;
		start <= '0';


		wait for bus_period*10;
		data_enable <= '1';
		data_in <= x"01";
		wait for bus_period*2;
		data_write <= '1';
		for i in 0 to 126 loop
			wait for bus_period;
			data_in <= data_in+1;
		end loop;
		data_in <= (others => '0');
		wait for bus_period;
		data_write <= '0';
		wait for bus_period*2;
		data_enable <= '0';
		enable <= '1';
		
		wait for bus_period*10;
		start <= '1';
		wait for bus_period*10;
		start <= '0';




		wait;
   end process;



END;
