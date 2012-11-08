----------------------------------------------------------------------------------
-- Company:       KVI/RUG/Groningen University
-- Engineer:      Peter Schakel
-- Create Date:   06-11-2008
-- Module Name:   RS232module
-- Description:   Module to send and receive data with a serial (RS232) connection 
----------------------------------------------------------------------------------
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

----------------------------------------------------------------------------------
-- RS232module
-- Module to send and receive data with a serial (RS232) connection 
-- A high frequency clock is used for timing 
--
-- Library
--
-- Generics:
--     CLOCK_FREQUENCY : clock frequency in Hz, used for calculate divide-factor for the rs232 signals
-- 
-- Inputs:
--     RS232clock : clock input
--     Reset : Asynchronous reset
--     baud : baudrate selection:
--         000 : RS232clock frequency
--         001 : 115200
--         010 : 57600
--         011 : 38400
--         100 : 19200
--         101 : 9600
--         110 : 4800
--         111 : 2400
--     RxIn : serial data from RS232 input pin
--     TxIn : 8 bits parallel data to send over RS232 serial line
--     TxLoad : write signal for the data to transmit
-- 
-- Outputs:
--     RxOut : data received from RS232 input pin and translated to parallel
--     RxPulse : write signal for received data
--     TxOut : serial data to RS232 output pin
--     TxBusy : Transmitter busy with sending data (please wait)
-- 
-- Components:
--
----------------------------------------------------------------------------------

entity RS232module is
	Generic(
		CLOCK_FREQUENCY : natural := 125000000
	);
	port(
		RS232clock              : in std_logic; 
		Reset                   : in std_logic; -- Asynchronous Reset
		baud                    : in std_logic_vector(2 downto 0); -- Bit rate selection
		
		RxIn                    : in std_logic; -- serial data in
		RxOut                   : out std_logic_vector(7 downto 0);
		RxPulse                 : out std_logic; -- pulse on data received
		
		TxIn                    : in std_logic_vector(7 downto 0);
		TxOut                   : out std_logic; -- serial data out
		TxLoad                  : in std_logic; -- load the transmitter
		TxBusy                  : out std_logic -- Transmitter is busy, please wait
	); 
end RS232module;


architecture behaviour of RS232module is

-- clock generation signals:
signal CLK : std_logic;
signal Top16 : std_logic;
signal TopTx : std_logic;
signal TopRx : std_logic;
signal ClrDiv : std_logic;
signal Div16 : integer range 0 to 16383;
signal Divisor : integer range 0 to 16383;
signal ClkDiv : integer range 0 to 15;
signal RxDiv : integer range 0 to 15;

-- transmitter signals
type TxStates is (Idle,Load_Tx,Shift_Tx,Stop_Tx);
signal TxFSM : TxStates;
signal Tx_Reg : std_logic_vector(9 downto 0); 
signal TxBitCnt : integer range 0 to 15;  -- index for txmtr
signal RegDin : std_logic_vector(7 downto 0); -- buffer for data to transmit

-- receiver signals
type RxState is (Idle,Start_Rx,Edge_Rx,Shift_Rx,Stop_Rx,RxOVF);
signal RxFSM : RxState;
signal Rx_Reg : std_logic_vector(7 downto 0); -- buffer for received data 
signal RxBitCnt : integer range 0 to 15;  -- counter for received bits
signal RxRdyi : std_logic; -- receiver ready
signal RxErr : std_logic; -- receiver error
signal RxInSync : std_logic; -- RxIn synchronised

begin  -- of architecture RS232module

process (CLK)
begin
	if rising_edge(CLK) then
		RxInSync <= RxIn;
	end if;
end process;

  CLK<=RS232clock;
-- --------------------------
-- Baud rate selection : CLK=50e6, Diviser=divider+1
-- --------------------------
process (Reset, CLK)
begin
	if Reset='1' then
		Divisor <= 0;
	elsif rising_edge(CLK) then
	case Baud is
	
		when "000" => Divisor <= 1;
		when "001" => Divisor <= CLOCK_FREQUENCY/(115200*16)+1;
		when "010" => Divisor <= CLOCK_FREQUENCY/(57600*16)+1;
		when "011" => Divisor <= CLOCK_FREQUENCY/(38400*16)+1;
		when "100" => Divisor <= CLOCK_FREQUENCY/(19200*16)+1;
		when "101" => Divisor <= CLOCK_FREQUENCY/(9600*16)+1;
		when "110" => Divisor <= CLOCK_FREQUENCY/(4800*16)+1;
		when "111" => Divisor <= CLOCK_FREQUENCY/(2400*16)+1;
		when others => Divisor <= CLOCK_FREQUENCY/(115200*16)+1;
	
		-- 50MHz
--		when "000" => Divisor <= 27; -- 115.200 : 
--		when "001" => Divisor <= 53; -- 57.600
--		when "010" => Divisor <= 80; -- 38.400
--		when "011" => Divisor <= 162; -- 19.200
--		when "100" => Divisor <= 325; -- 9.600
--		when "101" => Divisor <= 650; -- 4.800
--		when "110" => Divisor <= 1301; -- 2.400
--		when "111" => Divisor <= 2603; -- 1.200
--		when others => Divisor <= 26; -- n.u.
		
		-- 14.7456 MHz
--		when "000" => Divisor <= 7; -- 115.200
--		when "001" => Divisor <= 15; -- 57.600
--		when "010" => Divisor <= 23; -- 38.400
--		when "011" => Divisor <= 47; -- 19.200
--		when "100" => Divisor <= 95; -- 9.600
--		when "101" => Divisor <= 191; -- 4.800
--		when "110" => Divisor <= 383; -- 2.400
--		when "111" => Divisor <= 767; -- 1.200
--		when others => Divisor <= 7;
		
	end case;
	end if;
end process;

-- --------------------------
-- Clk16 Clock Generation
-- --------------------------
process (Reset, CLK)
begin
	if Reset='1' then
		Top16 <= '0';
		Div16 <= 0;
	elsif rising_edge(CLK) then
		Top16 <= '0';
		if Div16 = Divisor then
			Div16 <= 0;
			Top16 <= '1';
		else
			Div16 <= Div16 + 1;
		end if;
	end if;
end process;

-- --------------------------
-- Tx Clock Generation
-- --------------------------
process (Reset, CLK)
begin
	if Reset='1' then
		TopTx <= '0';
		ClkDiv <= 0;
	elsif rising_edge(CLK) then
		TopTx <= '0';
		if Top16='1' then
			if ClkDiv = 15 then
				TopTx <= '1';
				ClkDiv <= 0;
			else
				ClkDiv <= ClkDiv + 1;
			end if;
		end if;
	end if;
end process;

-- ------------------------------
-- Rx Sampling Clock Generation
-- ------------------------------
process (Reset, CLK)
begin
	if Reset='1' then
		TopRx <= '0';
		RxDiv <= 0;
	elsif rising_edge(CLK) then
		TopRx <= '0';
		if ClrDiv='1' then
			RxDiv <= 0;
		elsif Top16='1' then
			if RxDiv = 7 then
				RxDiv <= 0;
				TopRx <= '1';
			else
				if RxDiv=15 then
					RxDiv <= 0;
				else
					RxDiv <= RxDiv + 1;
				end if;
			end if;
		end if;
	end if;
end process;


-- --------------------------
-- Transmit State Machine
-- --------------------------
TxOut <= Tx_Reg(0);
Tx_FSM: process (Reset, CLK)
begin
	if Reset='1' then
		Tx_Reg <= (others => '1');
		TxBitCnt <= 0;
		TxFSM <= idle;
		TxBusy <= '0';
		RegDin <= (others=>'0');
	elsif rising_edge(CLK) then
		TxBusy <= '1'; -- except when explicitly '0'
		case TxFSM is
		when Idle =>
			if TxLoad='1' then
				-- latch the input data immediately.
				RegDin <= TxIn;
				TxBusy <= '1';
				TxFSM <= Load_Tx;
			else
				TxBusy <= '0';
			end if;
		when Load_Tx =>
			if TopTx='1' then
				TxFSM <= Shift_Tx;
--				if parity then  // no parity
--					-- start + data + parity
--					TxBitCnt <= (NDBits + 2);
--					Tx_Reg <= make_parity(RegDin,even) & Din & '0';
--				else
					TxBitCnt <= 11; -- start + data = 9 bits  -- 1 more stopbit : 11 insteadof 9
					Tx_reg <= '1' & RegDin & '0';
--				end if;
			end if;
		when Shift_Tx =>
			if TopTx='1' then
				TxBitCnt <= TxBitCnt - 1;
				Tx_reg <= '1' & Tx_reg (Tx_reg'high downto 1);
				if TxBitCnt=1 then
					TxFSM <= Stop_Tx;
				end if;
			end if;
		when Stop_Tx =>
			if TopTx='1' then
				TxFSM <= Idle;
			end if;
		when others =>
			TxFSM <= Idle;
		end case;
	end if;
end process;

Rx_pulseproc: process (Reset, CLK)
variable vRxPulse : std_logic;
begin
	if Reset='1' then
		RxPulse <= '0';
		vRxPulse := '0';
	elsif rising_edge(CLK) then
		if RxRdyi='1'  and vRxPulse = '0' then
			RxPulse <= '1';
			vRxPulse := '1'; 
		else
			RxPulse <= '0';
			vRxPulse := '0'; 
		end if;
	end if;
end process;
-- RxIn <= Tx_Reg(0); --testje
-- ------------------------
-- RECEIVE State Machine
-- ------------------------
Rx_FSM: process (Reset, CLK)
begin
	if Reset='1' then
		Rx_Reg <= (others => '0');
		RxOut <= (others => '0');
		RxBitCnt <= 0;
		RxFSM <= Idle;
		RxRdyi <= '0';
		ClrDiv <= '0';
		RxErr <= '0';
	elsif rising_edge(CLK) then
		ClrDiv <= '0'; -- default value
		-- reset error when a word has been received Ok:
		if RxRdyi='1' then
			RxErr <= '0';
			RxRdyi <= '0';
		else
	case RxFSM is
		when Idle => -- wait on start bit
			RxBitCnt <= 0;
			if Top16='1' then
				if RxInSync='0' then
					RxFSM <= Start_Rx;
					ClrDiv <='1'; -- Synchronize the divisor
				end if; -- else false start, stay in Idle
			end if;
		when Start_Rx => -- wait on first data bit
			if TopRx = '1' then
				if RxInSync='1' then -- framing error
					RxFSM <= RxOVF;
--					report "Start bit error." severity note;
				else
					RxFSM <= Edge_Rx;
				end if;
			end if;
		when Edge_Rx => -- should be near Rx edge
			if TopRx = '1' then
				RxFSM <= Shift_Rx;
				if RxBitCnt = 8 then -- 8 bits
					RxFSM <= Stop_Rx;
				else
					RxFSM <= Shift_Rx;
				end if;
			end if;
		when Shift_Rx => -- Sample data !
			if TopRx = '1' then
				RxBitCnt <= RxBitCnt + 1;
				-- shift right :
				Rx_Reg <= RxInSync & Rx_Reg (Rx_Reg'high downto 1);
				RxFSM <= Edge_Rx;
			end if;
		when Stop_Rx => -- during Stop bit
			if TopRx = '1' then
				RxOut <= Rx_reg;
				RxRdyi <='1';
				RxFSM <= Idle;
			end if;
		when RxOVF => -- Overflow / Error
			RxErr <= '1';
			if RxInSync='1' then
				RxFSM <= Idle;
			end if;
		when others =>
			RxFSM <= Idle;
		end case;
		end if;
	end if;
end process;

end behaviour;

