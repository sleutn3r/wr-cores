-------------------------------------------------------------------------------
-- Title      : PLL set phase
-- Project    : White Rabbit generator
-------------------------------------------------------------------------------
-- File       : PLL_setphase.vhd
-- Author     : Peter Schakel
-- Company    : KVI
-- Created    : 2012-09-18
-- Last update: 2012-09-28
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- Adjust the phase of a (Altera) PLL
-- 
-- Generics
--
-- Inputs
--     clk_sys_i : 125MHz Whishbone bus clock
--     rst_n_i : reset: low active
--     enable_i : enable phase adjusting
--     gpio_slave_i : Record with Whishbone Bus signals
--     wr_clock_i : White Rabbit 125MHz clock
--     wr_PPSpulse_i : White Rabbit PPS pulse
--
-- Outputs
--     gpio_slave_o : Record with Whishbone Bus signals
--     BuTis_C2_o : BuTiS 200 MHz clock
--     BuTis_T0_o : BuTis T0 100kHz signal
--     BuTis_T0_timestamp_o : BuTis T0 100kHz signal with serial encoded 64-bits timestamp
--     error_o : error detected: wr_PPSpulse_i signal period is not exactly 1 second
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

library IEEE;
use IEEE.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all ;
USE ieee.std_logic_arith.all ;

entity PLL_setphase is
	port(
		clock_i                                : in std_logic;
		reset_i                                : in std_logic;
		enable_i                               : in std_logic;
		phase_i                                : in std_logic_vector(7 downto 0);
		phasedone_i                            : in std_logic;
		phasestep_o                            : out std_logic;
		phaseupdown_o                          : out std_logic
   );
end PLL_setphase;

architecture struct of PLL_setphase is

type phasestate_type is (STEPPOS0,STEPPOS1,STEADY,STEPNEG0,STEPNEG1);
signal phase_S                             : std_logic_vector(7 downto 0) := (others => '0');
signal phasestate_S                        : phasestate_type := STEADY;
signal phasestep_S                         : std_logic := '0';
signal phaseupdown_S                       : std_logic := '0';
signal phasecounterselect_S                : std_logic_vector(3 downto 0) := (others => '0');
signal clear_phasedone_S                   : std_logic := '0';
signal phasedone_occurred_S                : std_logic := '0';
signal actualphase_S                       : std_logic_vector(7 downto 0) := (others => '0');

	
begin

phasestep_o <= phasestep_S;
phaseupdown_o <= phaseupdown_S;

-- process to detect the phasedone_i signal from the PLL
phasedone_process: process (clock_i,phasedone_i)
begin  -- process DO_STEPS
	if phasedone_i='0' then
		phasedone_occurred_S <= '1';
	elsif rising_edge(clock_i) then
		if clear_phasedone_S='1' then
			phasedone_occurred_S <= '0';
		end if;
	end if;
end process;

-- process to adjust the phase of a PLL. The actual position of the phase is stored in actualphase_S
setphase_process: process (clock_i,reset_i)
variable timeoutcounter_V : integer range 0 to 7 := 0;
begin  -- process DO_STEPS
	if rising_edge(clock_i) then
		if reset_i='1' then
			actualphase_S <= (others => '0');
			phase_S <= phase_i;
			clear_phasedone_S <= '1';
			phasestate_S <= STEADY;
		elsif enable_i='1' then -- enable to prevent that pulses to change the PLL phase are missed by the PLL and that the actual phasse is faulty
			case phasestate_S is
				when STEPPOS0 => -- perform a positive phase step
					phaseupdown_S <= '0';
					phasestep_S <= '1';
					clear_phasedone_S <= '0';
					phasestate_S <= STEPPOS1;
				when STEPPOS1 => -- wait for phasedone_i signal, detected in a separate process
					timeoutcounter_V := 0;
					phaseupdown_S <= '0';
					if (phasedone_occurred_S='1') or (timeoutcounter_V=7) then
						phasestep_S <= '0';
						actualphase_S <= actualphase_S+1;
						phasestate_S <= STEADY;
					else 
						timeoutcounter_V := timeoutcounter_V+1;
						phasestep_S <= '1';
					end if;
				when STEADY => -- state to check the desired phase with the actual phase and take action if unequal
					timeoutcounter_V := 0;
					clear_phasedone_S <= '1';
					if phasedone_i='1' then
						if actualphase_S < phase_S then
							phaseupdown_S <= '0';
							phasestep_S <= '1';
							phasestate_S <= STEPPOS0;
						elsif actualphase_S > phase_s then
							phaseupdown_S <= '1';
							phasestep_S <= '1';
							phasestate_S <= STEPNEG0;
						else
							phasestep_S <= '0';
							phasestate_S <= STEADY;
						end if;
					else
						phasestep_S <= '0';
					end if;
					phase_S <= phase_i;
				when STEPNEG0 => -- perform a negative phase step
					timeoutcounter_V := 0;
					phaseupdown_S <= '1';
					phasestep_S <= '1';
					clear_phasedone_S <= '0';
					phasestate_S <= STEPNEG1;
				when STEPNEG1 => -- wait for phasedone_i signal, detected in a separate process
					phaseupdown_S <= '1';
					if (phasedone_occurred_S='1') or (timeoutcounter_V=7) then
						phasestep_S <= '0';
						actualphase_S <= actualphase_S-1;
						phasestate_S <= STEADY;
					else 
						timeoutcounter_V := timeoutcounter_V+1;
						phasestep_S <= '1';
					end if;
				when others =>
					phasestate_S <= STEADY;
			end case;
		else
			phasestate_S <= STEADY;
			phase_S <= phase_i;
			clear_phasedone_S <= '1';
			timeoutcounter_V := 0;
			phasestep_S <= '0';
		end if;
	end if;
end process;
  
  
end struct;

