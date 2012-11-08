-----------------------------------------------------------------------------------
-- posedge_to_pulse
--		Makes pulse with duration 1 clock-cycle from positive edge
--	
-- inputs
--		clock_in : clock input for input signal
--		clock_out : clock input to synchronize to
--		en_clk : clock enable
--		signal_in : rising edge of this signal will result in pulse
--
--	output
--		pulse : pulse output : one clock cycle '1'
--
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity posedge_to_pulse is
	port (
		clock_in     : in  std_logic;
		clock_out     : in  std_logic;
		en_clk    : in  std_logic;
		signal_in : in  std_logic;
		pulse     : out std_logic
	);
end posedge_to_pulse;

architecture behavioral of posedge_to_pulse is

  signal resetff	: std_logic := '0';
  signal last_signal_in	: std_logic := '0';
  signal qff	: std_logic := '0'; 
  signal qff1	: std_logic := '0'; 
  signal qff2	: std_logic := '0'; 
  signal qff3	: std_logic := '0'; 
begin  

process (clock_in)
begin
	if rising_edge(clock_in) then
		if resetff='1' then
			qff <= '0';
		elsif (en_clk='1') and ((signal_in='1') and (qff='0') and (last_signal_in='0')) then 
			qff <= '1';
		else
			qff <= qff;
		end if;
		last_signal_in <= signal_in;
	end if;
end process;
resetff <= qff2;

process (clock_out)
begin
	if rising_edge(clock_out) then
		if qff3='0' and qff2='1' then 
			pulse <= '1'; 
		else 
			pulse <= '0';
		end if;
		qff3 <= qff2;
		qff2 <= qff1;
		qff1 <= qff;
	end if;
end process; 


end behavioral;

