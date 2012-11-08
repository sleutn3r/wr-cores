-------------------------------------------------------------------------------
-- Title      : Timestamp Decoder
-- Project    : White Rabbit generator
-------------------------------------------------------------------------------
-- File       : TimestampDecoder.vhd
-- Author     : Peter Schakel
-- Company    : KVI
-- Created    : 2012-08-29
-- Last update: 2012-09-28
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- Decodes a serial burst that contains a timestamp with Forward Error Correction code. 
-- The timestamp is a linear counter (i.e. 64-bits) that counts on every BuTiS C2 clock (200MHz)
-- The Forward Error Correction is done with Reed Solomon method.
-- Based on open source code downloaded from http://www.opencores.org 
-- The code: 
--     the timestamp is divided in bytes.
--     the bytes ares sent serially, 4 clock cycles for each bit, Most Significant Bit first
--     the first byte is 0xff
--     then the timestamp bytes are tranceived, Most Significant Byte first
--     after this the Reed Solomon bytes, calculated on the timestamp bytes are sent
--     Between the last bit and the next BuTiS T0 with code the signal is zero
-- 
--
-- Generics
--     g_timestampbytes : number of bytes for the timestamp, (8 means 64-bit timestamp)
--     g_clockcyclesperbit : number 200MHz clock cycles for each serial bit (default 4)
--     g_RScodewords : number of code words (=bytes) for Reed Solomons code, (4 means that upto 2 erroneous bytes can be corrected)
--     g_BuTis_ratio : Ratio between BuTiS C2 clock (200MHz) and T0 signal (100kHz)
--     g_BuTis_T0_precision : defines the precision on the check on the period of BuTiS T0 signal (+/- number of clock cycles).
--
-- Inputs
--     BuTis_C2_i : BuTiS 200 MHz clock
--     BuTis_C2div2_i : BuTiS 100 MHz clock in phase with 200 MHz, slower clock for decoder to meet timing constraints
--     reset_i : reset
--     serial_i : BuTis T0 100kHz signal with encoded timestamp
--
-- Outputs
--     BuTis_T0_o : BuTis T0 100kHz signal, 1 clock pulse without timestamp
--     timestamp_o : Timestamp value received
--     timestamp_write_o : Write signal for Timestamp_o: new value decoded
--     corrected_o : Error in serial burst was successfully corrected with Reed Solomon
--     error_o : error detected that could not be corrected
--
-- Components
--     RS_DEC4 : Open source Reed Solomon decoder by Anatoliy Sergienko, Volodya Lepeha
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


entity TimestampDecoder is
  generic(
	g_timestampbytes                         : integer := 8;
	g_clockcyclesperbit                      : integer := 4;
	g_RScodewords                            : integer := 4;
	g_BuTis_ratio                            : integer := 2000;
	g_BuTis_T0_precision                     : integer := 10);
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
end TimestampDecoder;

architecture rtl of TimestampDecoder is

component RS_DEC4 is
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC; 
		EN : in STD_LOGIC; 
		STR : in STD_LOGIC;
		D_IN : in STD_LOGIC_VECTOR(7 downto 0);
		RD : in STD_LOGIC;
		D_OUT : out STD_LOGIC_VECTOR(7 downto 0);
		S_er : out STD_LOGIC;		
		S_ok : out STD_LOGIC;
		SNB : out STD_LOGIC
	);
end component;

constant serialbytes_c                       : integer := g_timestampbytes + g_RScodewords;

type RS_decoder_mode_type is (WAITFORSIGNAL,SER2PAR,WAITRESULT,READRESULT,READRESULT_ODD,WAITFORZEROS);
signal RS_decoder_mode_s                     : RS_decoder_mode_type := WAITFORSIGNAL;
signal prev_RS_decoder_mode_s,prevprev_RS_decoder_mode_s                : RS_decoder_mode_type := WAITFORSIGNAL;

signal serial_s                              : std_logic := '0';
signal error_s                               : std_logic := '0';
signal RS_decoder_EN_s                       : std_logic := '0';
signal RS_decoder_Din_s                      : std_logic_vector(7 downto 0) := (others => '0');
signal RS_decoder_STR_s                      : std_logic := '0';
signal RS_decoder_RD_s                       : std_logic := '0';
signal RS_decoder_Dout_s                     : std_logic_vector(7 downto 0) := (others => '0');
signal RS_decoder_SNB_s                      : std_logic := '0';
signal RS_decoder_error_s                    : std_logic := '0';
signal RS_decoder_ok_s                       : std_logic := '0';
signal timestamp_s                           : std_logic_vector(g_timestampbytes*8-1 downto 0) := (others => '0');
signal phaseadjust_s                         : integer range 0 to 2;
signal phasecheck_counter_s                  : integer range 0 to 8;

signal prev_RS_decoder_EN_s                  : std_logic := '0';
signal RS_decoder_EN_div2_s                  : std_logic := '0';
signal RS_decoder_Din_div2_s                 : std_logic_vector(7 downto 0) := (others => '0');
signal RS_decoder_STR_div2_s                 : std_logic := '0';
signal RS_decoder_RD_div2_s                  : std_logic := '0';
signal RS_decoder_STR_div2_sync_s            : std_logic := '0';
signal BuTis_C2div2_phase_s                  : std_logic := '0';
			
signal clockcounter_s                        : integer range 0 to g_clockcyclesperbit-1 := 0;
signal bitcounter_s                          : integer range 0 to 7 := 0;
signal bytecounter_s                         : integer range 0 to g_timestampbytes+g_RScodewords := 0;
signal ratiocounter_s                        : integer range 0 to g_BuTis_ratio+g_BuTis_T0_precision := 0;
signal zeroscounter_s                        : integer range 0 to g_BuTis_ratio/2 := 0;
			
			
attribute syn_encoding : string;
attribute syn_encoding of RS_decoder_mode_type : type is "safe";

begin

RS_decoder: RS_DEC4 port map(
		CLK => BuTis_C2div2_i,
		RST => reset_i,
		EN => RS_decoder_EN_div2_s,
		STR => RS_decoder_STR_div2_s,
		D_IN => RS_decoder_Din_div2_s,
		RD => RS_decoder_RD_div2_s,
		D_OUT => RS_decoder_Dout_s,
		S_er => RS_decoder_error_s,	
		S_ok => RS_decoder_ok_s,
		SNB => RS_decoder_SNB_s);

		
-- process to synchronise decoder STR pulse to div2 clock, used for detecting phase between BuTis_C2_i and BuTis_C2div2_i
synchronize_STR_process: process(BuTis_C2div2_i)
begin
    if rising_edge(BuTis_C2div2_i)  then
		RS_decoder_STR_div2_sync_s <= RS_decoder_STR_div2_s;
	 end if;
end process;

-- process to have the decoder inputs on the div2 clock: on every RS_decoder_EN_s add another clock
decoder_inputs_process: process(BuTis_C2_i)
begin
    if rising_edge(BuTis_C2_i) then
		if (RS_decoder_EN_s='1') or (prev_RS_decoder_EN_s='0') then
			prev_RS_decoder_EN_s <= RS_decoder_EN_s;
			RS_decoder_EN_div2_s <= RS_decoder_EN_s;
			RS_decoder_STR_div2_s <= RS_decoder_STR_s;
			if (prev_RS_decoder_mode_s=WAITRESULT) and (prevprev_RS_decoder_mode_s=SER2PAR) and (BuTis_C2div2_phase_s='0') then
				-- when the state switches from SER2PAR to WAITRESULT and the phase is right the Data input should not yet be set to zero
			else
				RS_decoder_Din_div2_s <= RS_decoder_Din_s;
			end if;
		else 
			prev_RS_decoder_EN_s <= '0';
		end if;
		if RS_decoder_STR_s='1' then -- detect phase between BuTis_C2_i and BuTis_C2div2_i
			BuTis_C2div2_phase_s <= '0';
		elsif (RS_decoder_STR_div2_s='1') and (RS_decoder_STR_div2_sync_s='1') then
			BuTis_C2div2_phase_s <= '1';
		end if;
		prev_RS_decoder_mode_s <= RS_decoder_mode_s;
		prevprev_RS_decoder_mode_s <= prev_RS_decoder_mode_s;
	 end if;
end process;
RS_decoder_RD_div2_s <= RS_decoder_RD_s;


BuTis_T0_o <= '1' when (RS_decoder_mode_s=WAITFORSIGNAL) and (serial_i='1') and (serial_s='0') else '0';

-- process with state machine to translate serial data to parallel, feed it to the decoder and combine the result to one timestamp
BuTis_process : process(BuTis_C2_i)
begin
    if rising_edge(BuTis_C2_i) then
		if reset_i = '1' then
			RS_decoder_EN_s <= '1';
			RS_decoder_STR_s <= '0';
			RS_decoder_RD_s <= '0';
			timestamp_write_o <= '0'; 
			error_s <= '0';
			ratiocounter_s <= 0;
			RS_decoder_mode_s <= WAITFORSIGNAL;
		else
			timestamp_write_o <= '0'; 
			if ratiocounter_s<g_BuTis_ratio+g_BuTis_T0_precision then -- ratiocounter to check 100kHz period
				ratiocounter_s <= ratiocounter_s+1;
			end if;
			case RS_decoder_mode_s is
				when WAITFORSIGNAL => -- Wait for next BuTis_T0 signal with serial encoded timestamp
					RS_decoder_EN_s <= '1';
					RS_decoder_RD_s <= '0';
					clockcounter_s <= 0;
					bitcounter_s <= 0;
					bytecounter_s <= 0;
					if serial_i='1' then
						if serial_s='0' then
							if ratiocounter_s<g_BuTis_ratio-g_BuTis_T0_precision then
								error_s <= '1';
							else
								error_s <= '0';
							end if;
							RS_decoder_STR_s <= '1';
							RS_decoder_mode_s <= SER2PAR;
						else
							RS_decoder_STR_s <= '0';
							error_s <= '1';
						end if;
					else
						RS_decoder_STR_s <= '0';
					end if;
					phaseadjust_s <= 1;
					phasecheck_counter_s <= 0;
				when SER2PAR => -- do the serial to parallel conversion and feed the second and further bytes to the decoder
					RS_decoder_STR_s <= '0';
					RS_decoder_RD_s <= '0';
					zeroscounter_s <= 0;
					if clockcounter_s<g_clockcyclesperbit-1 then
						if clockcounter_s=g_clockcyclesperbit/2-1 then  -- phaseadjust_s then -- bit phase adjustment disabled
							RS_decoder_Din_s(7-bitcounter_s) <= serial_i; -- next bit in the middle of the g_clockcyclesperbit clock-cycles for each serial data-bit
						end if;
						if (clockcounter_s=g_clockcyclesperbit-2) and (serial_i='1') and (phasecheck_counter_s<8)
							and (bitcounter_s=0 or bitcounter_s=2 or bitcounter_s=4 or bitcounter_s=6) then
							phasecheck_counter_s <= phasecheck_counter_s+1; -- simple test to improve bit phase, doesn't improve!
						end if;
						
						clockcounter_s <= clockcounter_s+1;
						RS_decoder_EN_s <= '0';
					else
						if (serial_i='1') and (phasecheck_counter_s<8) 
							and (bitcounter_s=0 or bitcounter_s=2 or bitcounter_s=4 or bitcounter_s=6) then
							phasecheck_counter_s <= phasecheck_counter_s+1; -- simple test to improve bit phase, doesn't improve!
						end if;
						clockcounter_s <= 0;
						if bitcounter_s<7 then
							bitcounter_s <= bitcounter_s+1;
							RS_decoder_EN_s <= '0';
						else
							bitcounter_s <= 0;
							if (bytecounter_s=0) then  -- simple test to improve bit phase, doesn't improve! (disabled now)
								if phasecheck_counter_s>7 then -- first 8 bits is startbyte (0xaa)
									phaseadjust_s <= 0; -- 0;
								elsif phasecheck_counter_s<1 then 
									phaseadjust_s <= 2; 
								else
									phaseadjust_s <= 1; 
								end if;
								RS_decoder_EN_s <= '0';
							else
								RS_decoder_EN_s <= '1';
							end if;
							if bytecounter_s<g_timestampbytes+g_RScodewords then -- until all bytes are received
								bytecounter_s <= bytecounter_s+1;
							else
								bytecounter_s <= 0;
								RS_decoder_mode_s <= WAITRESULT;
							end if;
						end if;
					end if;
				when WAITRESULT => -- set the Reed Solomon decoder to work and wait for ready signal (RS_decoder_SNB_s)
					RS_decoder_EN_s <= '1';
					RS_decoder_STR_s <= '0';
					RS_decoder_Din_s <= (others => '0');
					clockcounter_s <= 0;
					bitcounter_s <= 0;
					bytecounter_s <= 0;
					if RS_decoder_RD_s='1' then
						RS_decoder_RD_s <= '1';
						RS_decoder_mode_s <= READRESULT_ODD; -- READRESULT;
					elsif RS_decoder_SNB_s='1' then
						RS_decoder_RD_s <= '1';
					else
						if zeroscounter_s<g_BuTis_ratio/2 then 
							zeroscounter_s <= zeroscounter_s+1;
						else
							zeroscounter_s <= 0;
							RS_decoder_mode_s <= WAITFORSIGNAL;
						end if;
						RS_decoder_RD_s <= '0';
					end if;
				when READRESULT => -- read the bytes from the decoder and combine to timestamp
					-- because the decoder runs at half clock speed the state switches alternately to READRESULT_ODD
					RS_decoder_EN_s <= '1';
					RS_decoder_STR_s <= '0';
					RS_decoder_RD_s <= '1';
					if bytecounter_s<g_timestampbytes-1 then
						timestamp_s((g_timestampbytes-bytecounter_s)*8-1 downto (g_timestampbytes-bytecounter_s-1)*8) 
							<= RS_decoder_Dout_s;
					elsif bytecounter_s=g_timestampbytes-1 then
						timestamp_o(g_timestampbytes*8-1 downto 8) <= timestamp_s(g_timestampbytes*8-1 downto 8);
						timestamp_o(7 downto 0) <= RS_decoder_Dout_s;
						timestamp_write_o <= '1'; 
						if ((RS_decoder_error_s='1') and (RS_decoder_ok_s='0')) or (error_s='1') then
							error_o <= '1';
						else
							error_o <= '0';
						end if;
						if ((RS_decoder_error_s='1') and (RS_decoder_ok_s='1')) and (error_s='0') then
							corrected_o <= '1';
						else
							corrected_o <= '0';
						end if;
					end if;
					if bytecounter_s<g_timestampbytes+g_RScodewords-1 then
						bytecounter_s <= bytecounter_s+1;
						RS_decoder_mode_s <= READRESULT_ODD;
					else
						zeroscounter_s <= 0;
						RS_decoder_mode_s <= WAITFORZEROS;
					end if;
				when READRESULT_ODD => -- state just to have one result in 2 clock-cycles because the decoder runs at half the speed
					RS_decoder_mode_s <= READRESULT;
				when WAITFORZEROS => -- after the data there should always be a gap filled with 0 before the next BuTiS_T0 pulse arrives
					if serial_i='0' then
						if zeroscounter_s<g_BuTis_ratio/4 then 
							zeroscounter_s <= zeroscounter_s+1;
						else
							zeroscounter_s <= 0;
							RS_decoder_mode_s <= WAITFORSIGNAL;
						end if;
					else
						zeroscounter_s <= 0;
					end if;
				when others =>
					RS_decoder_EN_s <= '1';
					RS_decoder_STR_s <= '0';
					RS_decoder_RD_s <= '0';
					RS_decoder_mode_s <= WAITFORSIGNAL;
			end case;
			serial_s <= serial_i;
		end if;
   end if;
end process;

  
end;

