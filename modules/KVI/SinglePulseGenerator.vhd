-------------------------------------------------------------------------------
-- Title      : Single Pulse Generator
-- Project    : White Rabbit pulse generator
-------------------------------------------------------------------------------
-- File       : SinglePulseGenerator.vhd
-- Author     : Peter Schakel
-- Company    : KVI
-- Created    : 2012-08-10
-- Last update: 2012-09-28
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- Outputs a single pulse with adjustable delay and duration on an external trigger input.
--
-- 
-- Generics
--     g_timebits : number of bits for the delay and duration of the pulse
--
-- Inputs
--     clock_i : 125MHz White Rabbit clock
--     reset_i : reset: high active
--     delay_i : number of clockcycles delay after the start (trigger) before the pulse starts
--     duration_i : umber of clockcycles duration of the pulse
--     enable_i : enable external start (trigger) signal
--     start_i : start the output of the pulse
--     force_start_i : start the output of the pulse, even if enable_i is low. (used for soft trigger).
--
-- Outputs
--     busy_o : Pulse (or delay) is busy
--     pulse_o : Pulse output
--
-- Components
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
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;


entity SinglePulseGenerator is
  generic(
    g_timebits                               : integer := 32);
  port(
    clock_i                                  : in  std_logic;
    reset_i                                  : in  std_logic;
    delay_i                                  : in  std_logic_vector(g_timebits-1 downto 0);
    duration_i                               : in  std_logic_vector(g_timebits-1 downto 0);
    enable_i                                 : in  std_logic;
    start_i                                  : in  std_logic;
    force_start_i                            : in  std_logic;
    busy_o                                   : out std_logic;
    pulse_o                                  : out std_logic);
end SinglePulseGenerator;

architecture rtl of SinglePulseGenerator is

constant zeros                               : std_logic_vector(g_timebits-1 downto 0) := (others => '0');
signal busy_s                                : std_logic := '0';
signal pulse_s                               : std_logic := '0';
signal start_s                               : std_logic := '0';
signal duration_s                            : std_logic_vector(g_timebits-1 downto 0);

begin

pulse_process : process(clock_i)
variable counter_v : std_logic_vector(g_timebits-1 downto 0);
begin
    if rising_edge(clock_i) then
		if reset_i = '1' then
			busy_s <= '0';
			pulse_s <= '0';
		else
			if busy_s='0' then -- busy is 0: alowed to start next pulse
				if (enable_i='1' and (start_i='1' and start_s='0')) or (force_start_i='1') then
					duration_s <= duration_i;
					if delay_i=zeros then
						if duration_i=zeros then
							pulse_s <= '0';
							busy_s <= '0';
						else
							pulse_s <= '1';
							busy_s <= '1';
							counter_v := duration_i;
						end if;
					else
						pulse_s <= '0';
						busy_s <= '1';
						counter_v := delay_i;
					end if;
				else
					pulse_s <= '0';
					busy_s <= '0';
				end if;
			else -- busy='1': count down to 0
				counter_v := counter_v-1;
				if pulse_s='0' then
					if counter_v=zeros then
						if duration_s=zeros then
							busy_s <= '0';
							pulse_s <= '0';
						else
							counter_v := duration_s;
							busy_s <= '1';
							pulse_s <= '1';
						end if;
					else
						busy_s <= '1';
						pulse_s <= '0';
					end if;
				else -- pulse_i='1'
					if counter_v=zeros then
						busy_s <= '0';
						pulse_s <= '0';
					else
						busy_s <= '1';
						pulse_s <= '1';
					end if;
				end if;
			end if;
		end if;
		start_s <= start_i;
    end if;
end process;

  busy_o <= busy_s;
  pulse_o <= pulse_s;
  
end;

