
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
use std.textio.all;
 
ENTITY TimestampEncoder_tb IS
END TimestampEncoder_tb;
 
ARCHITECTURE behavior OF TimestampEncoder_tb IS 

component TimestampEncoder is
  generic(
		g_timestampbytes                         : integer := 8;
		g_clockcyclesperbit                      : integer := 4;
		g_RScodewords                            : integer := 4;
		g_BuTis_ratio                            : integer := 2000);
  port(
		BuTis_C2_i                               : in  std_logic;
		BuTis_T0_i                               : in  std_logic;
		reset_i                                  : in  std_logic;
		timestamp_i                              : in  std_logic_vector(g_timestampbytes*8-1 downto 0);
		settimestamp_i                           : in  std_logic;
		serial_o                                 : out std_logic;
		error_o                                  : out std_logic);
end component;

component TimestampDecoder is
  generic(
	g_timestampbytes                         : integer := 8;
	g_clockcyclesperbit                      : integer := 4;
	g_RScodewords                            : integer := 4;
	g_BuTis_ratio                            : integer := 2000;
	g_BuTis_T0_precision                     : integer := 10);
  port(
	BuTis_C2_i                               : in std_logic;
	reset_i                                  : in std_logic;
	serial_i                                 : in std_logic;
	BuTis_T0_o                               : out std_logic;
	timestamp_o                              : out std_logic_vector(g_timestampbytes*8-1 downto 0);
	timestamp_write_o                        : out std_logic;
	corrected_o                              : out std_logic;
	error_o                                  : out std_logic);
end component;

signal BuTis_C2_i    : std_logic;
signal reset         : std_logic;
signal BuTis_T0_i    : std_logic;
signal cleartime_i   : std_logic;
signal serial_o      : std_logic;
signal error_enc     : std_logic;

signal BuTis_T0_o    : std_logic;
signal timestamp_o   : std_logic_vector(8*8-1 downto 0);
signal error_dec     : std_logic;
signal correction_o  : std_logic;
signal serial_i      : std_logic;
signal generror      : std_logic;

signal serial_ok     : std_logic;
signal timestamp_write_o     : std_logic;

signal timestamp_ok  : std_logic_vector(8*8-1 downto 0);



-- Clock period definitions
constant clock_period : time := 5 ns;
 
BEGIN

uut: TimestampEncoder port map(
	BuTis_C2_i => BuTis_C2_i,
	BuTis_T0_i => BuTis_T0_i,
	reset_i => reset,
	timestamp_i => (others => '0'),
	settimestamp_i => cleartime_i,
	serial_o => serial_o,
	error_o => error_enc);
serial_i <= serial_o xor generror;
uut2: TimestampDecoder port map(
	BuTis_C2_i => BuTis_C2_i,
	reset_i => reset,
	serial_i => serial_i,
	BuTis_T0_o => BuTis_T0_o,
	timestamp_o => timestamp_o,
	timestamp_write_o => timestamp_write_o,
	corrected_o => correction_o,
	error_o => error_dec);

uut_ok: TimestampEncoder port map(
	BuTis_C2_i => BuTis_C2_i,
	BuTis_T0_i => BuTis_T0_i,
	reset_i => reset,
	timestamp_i => (others => '0'),
	settimestamp_i => cleartime_i,
	serial_o => serial_ok,
	error_o => open);
serial_i <= serial_o xor generror;
uut2_ok: TimestampDecoder port map(
	BuTis_C2_i => BuTis_C2_i,
	reset_i => reset,
	serial_i => serial_ok,
	BuTis_T0_o => open,
	timestamp_o => timestamp_ok,
	timestamp_write_o => open,
	corrected_o => open,
	error_o => open);
	
	
   -- Clock process definitions
   clock_process :process
   begin
		BuTis_C2_i <= '0';
		wait for clock_period/2;
		BuTis_C2_i <= '1';
		wait for clock_period/2;
   end process;
 
error_process : process
variable c : integer := 0;
begin
	generror <= '0';
	wait for 100 ns;	
	while true loop
		while BuTis_T0_i='0' loop
			wait for clock_period;
		end loop;
		wait for clock_period*4*8;
		wait for clock_period*4*c;
		generror <= '1';
		wait for clock_period*4*10;
		generror <= '0';
		if c<8*(8+4) then
			c := c+1;
		else
			c := 0;
		end if;
	end loop;
	wait;
end process;

timestamp_process : process(BuTis_C2_i)
variable counter_v : integer range 0 to 2000 := 0;
begin
    if rising_edge(BuTis_C2_i) then
		if reset = '1' then
			counter_v := 0;
			BuTis_T0_i <= '0';
		else
			if counter_v<2000-1 then
				counter_v := counter_v+1;
				BuTis_T0_i <= '0';
			else
				counter_v := 0;
				BuTis_T0_i <= '1';
			end if;
		end if;
	end if;
end process;


stim_proc: process
variable l : line;
begin		
	reset <= '1';
	cleartime_i <= '0';
	wait for 100 ns;	
	reset <= '0';

	wait for clock_period*10;
	cleartime_i <= '1';
	wait for clock_period*10;
	cleartime_i <= '0';

	wait for clock_period;

	wait;
end process;

check: process(BuTis_C2_i)
variable l : line;
variable e : std_logic := '0';
variable f : std_logic := '0';
   begin
		if rising_edge(BuTis_C2_i) then
			if timestamp_ok/=timestamp_o then
				if e='0' then
				  write(l, string'("error "));
					write( l, conv_integer(unsigned(timestamp_ok(31 downto 0))));
					writeline(output,l);	
					if error_dec/='1' then
						write( l, string'("error not detected !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"));
						writeline(output,l);	
					end if;
				end if;
				e := '1';
				f := '0';
			else
				if (error_dec='1') then
					if (f='0')  then
						write( l, string'("error : false detection ????????????????????????????????????????????????"));
						writeline(output,l);	
					end if;
					f := '1';
				else
					f := '0';
				end if;
				e := '0';
			end if;
		end if;
end process;
	
	

END;
