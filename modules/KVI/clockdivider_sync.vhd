-------------------------------------------------------------------------------
-- Title      : clockdivider_sync
-- Project    : White Rabbit pulse generator
-------------------------------------------------------------------------------
-- File       : clockdivider_sync.vhd
-- Author     : Peter Schakel
-- Company    : KVI
-- Created    : 2012-09-17
-- Last update: 2012-09-17
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- Divide a clock signal by a constant value and synchronize to additional slow signal
--
-- 
-- Generics
--     g_clockddivisor : clock divisor
--
-- Inputs
--     clock_i : input clock
--     reset_i : reset: high active
--     sync_i : slow signal to synchronize on
--
-- Outputs
--     divclock_o : Divide clock
--     error_o : Synchronization error
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


entity clockdivider_sync is
  generic(
    g_clockddivisor                          : integer := 5);
  port(
    clock_i                                  : in  std_logic;
    reset_i                                  : in  std_logic;
    sync_i                                   : in  std_logic;
    divclock_o                               : out std_logic;
    error_o                                  : out std_logic);
end clockdivider_sync;

architecture rtl of clockdivider_sync is
signal prev_sync_s                           : std_logic := '0';
signal counter_s                             : integer range 0 to g_clockddivisor-1;

begin

pulse_process : process(clock_i)
begin
    if rising_edge(clock_i) then
		if reset_i = '1' then
			counter_s <= 0;
			divclock_o <= '0';
			error_o <= '0';
		else
			if sync_i='1' and prev_sync_s='0' then
				if counter_s/=0 then
					error_o <= '1';					
				else
					error_o <= '0';
				end if;
				counter_s <= 1;
				divclock_o <= '1';
			else
				if counter_s=g_clockddivisor/2-1 then
					divclock_o <= '0';
					counter_s <= counter_s+1;
				elsif counter_s=g_clockddivisor-1 then
					divclock_o <= '1';
					counter_s <= 0;
				else
					counter_s <= counter_s+1;
				end if;
			end if;
		end if;
		prev_sync_s <= sync_i;
    end if;
end process;
  
end;

