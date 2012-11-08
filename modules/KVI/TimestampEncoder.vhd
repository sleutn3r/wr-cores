-------------------------------------------------------------------------------
-- Title      : Timestamp Encoder
-- Project    : White Rabbit generator
-------------------------------------------------------------------------------
-- File       : TimestampEncoder.vhd
-- Author     : Peter Schakel
-- Company    : KVI
-- Created    : 2012-08-27
-- Last update: 2012-09-28
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- Translates a Timestamp in serial burst with Forward Error Correction code. 
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
-- Generics
--     g_timestampbytes : number of bytes for the timestamp, (8 means 64-bit timestamp)
--     g_clockcyclesperbit : number 200MHz clock cycles for each serial bit (default 4)
--     g_RScodewords : number of code words (=bytes) for Reed Solomons code, (4 means that upto 2 erroneous bytes can be corrected)
--     g_BuTis_ratio : Ratio between BuTiS C2 clock (200MHz) and T0 signal (100kHz)
--
-- Inputs
--     BuTis_C2_i : BuTiS 200 MHz clock
--     BuTis_T0_i : BuTis T0 100kHz signal
--     reset_i : reset
--     timestamp_i : Timestamp value to set with settimestamp_i
--     settimestamp_i : sets the current timestamp to the value at input timestamp_i
--
-- Outputs
--     serial_o : BuTis T0 100kHz signal with encoded timestamp
--     error_o : error detected: BuTis_T0_i signal period is not exactly 2000 clock cycles
--
-- Components
--     RS_EN4 : Open source Reed Solomon encoder by Anatoliy Sergienko, Volodya Lepeha
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


entity TimestampEncoder is
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
end TimestampEncoder;

architecture rtl of TimestampEncoder is

component RS_EN4 is	  	 
--generic( G_range:  integer := 4;
--	A_range:  integer := 9);
	 port(
		 CLK : in STD_LOGIC;
		 RST : in STD_LOGIC;
		 EN : in STD_LOGIC;
		 D_IN : in STD_LOGIC_VECTOR(7 downto 0);  
		 STR : in STD_LOGIC;
		 RD : in STD_LOGIC;
		 D_OUT : out STD_LOGIC_VECTOR(7 downto 0);
		 SNB : out STD_LOGIC
	     );
end component;	  

constant serialbytes_c                       : integer := g_timestampbytes + g_RScodewords;

type RS_encoder_mode_type is (STARTBYTE,PAR2SER,NEXTTIMESTAMP);
signal RS_encoder_mode_s                     : RS_encoder_mode_type := NEXTTIMESTAMP;

signal RS_encoder_EN_s                       : std_logic := '0';
signal RS_encoder_Din_s                      : std_logic_vector(7 downto 0) := (others => '0');
signal RS_encoder_STR_s                      : std_logic := '0';
signal RS_encoder_RD_s                       : std_logic := '0';
signal RS_encoder_Dout_s                     : std_logic_vector(7 downto 0) := (others => '0');
signal RS_encoder_SNB_s                      : std_logic := '0';
signal BuTis_T0_s                            : std_logic := '0';
signal serial_s                              : std_logic := '0';
signal timestamp_s                           : std_logic_vector(g_timestampbytes*8-1 downto 0) := (others => '0');
signal timestampcounter_s                    : std_logic_vector(g_timestampbytes*8-1 downto 0) := (others => '0');

signal RS_encoder_enable_s                   : std_logic;
signal clockcounter_s                        : integer range 0 to g_clockcyclesperbit-1 := 0;
signal bitcounter_s                          : integer range 0 to 7 := 0;
signal bytecounter_s                         : integer range 0 to g_timestampbytes+g_RScodewords-1 := 0;
signal tsbytecounter_s                       : integer range 0 to g_timestampbytes := 0;
signal BuTis_T0_counter_s                    : integer range 0 to g_BuTis_ratio := 0;

begin
serial_o <= serial_s;

RS_encoder: RS_EN4 port map(	  	 
	CLK => BuTis_C2_i,
	RST => reset_i,
	EN => RS_encoder_EN_s,
	D_IN => RS_encoder_Din_s,
	STR => RS_encoder_STR_s,
	RD => RS_encoder_RD_s,
	D_OUT => RS_encoder_Dout_s,
	SNB => RS_encoder_SNB_s);
	
 -- process for timestamp counter and check for time between BuTiS_T0 100kHz pulses
timestamp_process : process(BuTis_C2_i)
begin
    if rising_edge(BuTis_C2_i) then
		if reset_i = '1' then
			timestampcounter_s <= (others => '0');
		else
			if settimestamp_i='1' then
				timestampcounter_s <= timestamp_i; 
			else
				timestampcounter_s <= timestampcounter_s+1; 
			end if;
			if BuTis_T0_i='1' and BuTis_T0_s='0' then -- rising edge BuTis_T0
				timestamp_s <= timestampcounter_s;
				if BuTis_T0_counter_s/=g_BuTis_ratio-1 then
					error_o <= '1';
				else
					error_o <= '0';
				end if;
				BuTis_T0_counter_s <= 0;
				RS_encoder_STR_s <= '1';
				tsbytecounter_s <= 0;
			else -- increment counter for BuTiS_T0 period check
				if BuTis_T0_counter_s<=g_BuTis_ratio-1 then
					BuTis_T0_counter_s <= BuTis_T0_counter_s+1;
				end if;					
				RS_encoder_STR_s <= '0';
				if tsbytecounter_s<g_timestampbytes then
					RS_encoder_Din_s <= timestamp_s(g_timestampbytes*8-tsbytecounter_s*8-1 downto g_timestampbytes*8-tsbytecounter_s*8-8);
					tsbytecounter_s <= tsbytecounter_s+1;
				else
					RS_encoder_Din_s <= (others => '0');
				end if;
			end if;
		end if;
	end if;
end process;

RS_encoder_RD_s <= '1' when -- read signal for Reed Solomon encoder module
	(RS_encoder_mode_s=PAR2SER) and (clockcounter_s=g_clockcyclesperbit-1) and (bitcounter_s=7) and (bytecounter_s<serialbytes_c-1)
		else '0';
RS_encoder_EN_s <= '1' when -- enable signal for Reed Solomon encoder module
		(reset_i='0') 
		or (BuTis_T0_i='1' and BuTis_T0_s='0')
		or ((RS_encoder_enable_s='1') and (RS_encoder_mode_s=STARTBYTE))
		or (RS_encoder_RD_s='1')
		or (RS_encoder_mode_s=NEXTTIMESTAMP)
	else '0';
	
 -- process with statemachine to encode byte-wide data and serialize the result
BuTis_process : process(BuTis_C2_i)
begin
    if rising_edge(BuTis_C2_i) then
		if reset_i = '1' then
			BuTis_T0_s <= '0';
			RS_encoder_mode_s <= NEXTTIMESTAMP;
			serial_s <= '0';
			RS_encoder_enable_s <= '1';
		else
			BuTis_T0_s <= BuTis_T0_i;
			
			if BuTis_T0_i='1' and BuTis_T0_s='0' then -- check for rising edge BuTis_T0 (100kHz pulse)
				RS_encoder_mode_s <= STARTBYTE; -- go to state STARTBYTE: send one byte serially 
				clockcounter_s <= 0;
				bitcounter_s <= 0;
				bytecounter_s <= 0;
				serial_s <= '0';
				RS_encoder_enable_s <= '1';
			elsif RS_encoder_mode_s=STARTBYTE then -- state STARTBYTE: send one byte serially startbyte is 0x55
				if clockcounter_s=0 then
					serial_s <= not serial_s;
				end if;
				if clockcounter_s<g_clockcyclesperbit-1 then
					clockcounter_s <= clockcounter_s+1;
				else
					clockcounter_s <= 0;
					if bitcounter_s<7 then
						bitcounter_s <= bitcounter_s+1;
					else
						bitcounter_s <= 0;
						RS_encoder_mode_s <= PAR2SER;
					end if;
				end if;
				bytecounter_s <= 0;
				if RS_encoder_SNB_s='1' then
					RS_encoder_enable_s <= '0';
				end if;
			elsif RS_encoder_mode_s=PAR2SER then -- state PAR2SER: translate byte-wise encoded data to serial
				if clockcounter_s=0 then
					serial_s <= RS_encoder_Dout_s(7-bitcounter_s);
				end if;
				if clockcounter_s<g_clockcyclesperbit-1 then
					clockcounter_s <= clockcounter_s+1;
				else
					clockcounter_s <= 0;
					if bitcounter_s<7 then
						bitcounter_s <= bitcounter_s+1;
					else
						bitcounter_s <= 0;
						if bytecounter_s<serialbytes_c-1 then
							bytecounter_s <= bytecounter_s+1;
						else
							RS_encoder_mode_s <= NEXTTIMESTAMP;
							bytecounter_s <= 0;
						end if;
					end if;
				end if;
			elsif RS_encoder_mode_s=NEXTTIMESTAMP then -- state NEXTTIMESTAMP: serial output is 0, rising edge BuTis_T0 will leave this state
				serial_s <= '0';
			end if;
		end if;
   end if;
end process;

  
end;

