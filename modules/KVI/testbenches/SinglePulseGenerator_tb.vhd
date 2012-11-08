
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;
use std.textio.all;
 
ENTITY SinglePulseGenerator_tb IS
END SinglePulseGenerator_tb;
 
ARCHITECTURE behavior OF SinglePulseGenerator_tb IS 

component SinglePulseGenerator is
  generic(
    g_timebits    : integer := 32);
  port(
    clock_i       : in  std_logic;
    reset_i       : in  std_logic;
    delay_i       : in  std_logic_vector(g_timebits-1 downto 0);
    duration_i    : in  std_logic_vector(g_timebits-1 downto 0);
    enable_i      : in  std_logic;
    start_i       : in  std_logic;
    force_start_i : in  std_logic;
    busy_o        : out std_logic;
    pulse_o       : out std_logic);
end component;

   signal WB_clock      : std_logic;
   signal reset         : std_logic;
   signal delay         : std_logic_vector(31 downto 0);
   signal duration      : std_logic_vector(31 downto 0);
   signal enable        : std_logic;
   signal start         : std_logic;
   signal busy          : std_logic;
   signal pulse         : std_logic;


   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN

   uut: SinglePulseGenerator PORT MAP (
    clock_i => WB_clock,
    reset_i => reset,
    delay_i => delay,
    duration_i => duration,
    enable_i => enable,
    start_i => start,
    force_start_i => '0',
    busy_o => busy,
    pulse_o => pulse);

   -- Clock process definitions
   clock_process :process
   begin
		WB_clock <= '0';
		wait for clock_period/2;
		WB_clock <= '1';
		wait for clock_period/2;
   end process;
 

   stim_proc: process
		variable l : line;
   begin		
      -- hold reset state for 100 ns.
      reset <= '1';
      delay <= conv_std_logic_vector(10,32);
    duration <= conv_std_logic_vector(1,32);
    enable <= '1';
    start <= '0';
      wait for 100 ns;	
      reset <= '0';

      wait for clock_period*10;

      start <= '1';
      wait for clock_period;
      start <= '0';
      wait;
   end process;



END;
