-------------------------------------------------------------------------------
-- Title      : Simple RS232 module
-- Project    : White Rabbit pattern generator
-------------------------------------------------------------------------------
-- File       : simplers232module.vhd
-- Author     : Peter Schakel
-- Company    : KVI
-- Created    : 2012-09-07
-- Last update: 2012-09-07
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
-- Wishbone Bus module for communicates over serial connection : 
--     baudrate : fixed to 11k5
--     data bits : 8 bits
--     stop bits : 1
-- 
-- Receiver part has not been used nor tested.
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
use ieee.std_logic_unsigned.all ;
use ieee.std_logic_arith.all ;

library work;
use work.genram_pkg.all;
use work.wishbone_pkg.all;

entity simplers232module is
	generic(
		CLOCK_FREQUENCY    : integer := 125000000
	);
	port(
		clk_sys_i                              : in std_logic;
		rst_n_i                                : in std_logic;
		gpio_slave_i                           : in t_wishbone_slave_in;
		gpio_slave_o                           : out t_wishbone_slave_out;
		serial_i                               : in std_logic;
		serial_o                               : out std_logic
    );
end simplers232module;

architecture struct of simplers232module is

component wb_rs232 is
  port (
-- 
    rst_n_i                                  : in     std_logic;
-- 
    wb_clk_i                                 : in     std_logic;
-- 
    wb_addr_i                                : in     std_logic_vector(2 downto 0);
-- 
    wb_data_i                                : in     std_logic_vector(31 downto 0);
-- 
    wb_data_o                                : out    std_logic_vector(31 downto 0);
-- 
    wb_cyc_i                                 : in     std_logic;
-- 
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
-- 
    wb_stb_i                                 : in     std_logic;
-- 
    wb_we_i                                  : in     std_logic;
-- 
    wb_ack_o                                 : out    std_logic;
-- Ports for PASS_THROUGH field: 'senddata' in reg: 'send data'
    wbrs232_send_data_o                      : out    std_logic_vector(7 downto 0);
    wbrs232_send_data_wr_o                   : out    std_logic;
-- Port for std_logic_vector field: 'readdata' in reg: 'read data'
    wbrs232_read_data_i                      : in     std_logic_vector(7 downto 0);
-- Ports for PASS_THROUGH field: 'done' in reg: 'reading done'
    wbrs232_done_done_o                      : out    std_logic_vector(31 downto 0);
    wbrs232_done_done_wr_o                   : out    std_logic;
-- Port for std_logic_vector field: 'sending allowed' in reg: 'status'
    wbrs232_status_allowed_i                 : in     std_logic_vector(0 downto 0);
-- Port for std_logic_vector field: 'data available' in reg: 'status'
    wbrs232_status_available_i               : in     std_logic_vector(0 downto 0);
-- Port for std_logic_vector field: 'baudrate' in reg: 'control'
    wbrs232_control_baud_o                   : out    std_logic_vector(2 downto 0)
  );
end component;

component generic_sync_fifo is
  generic (
    g_data_width : natural := 8;
    g_size       : natural := 64;
    g_show_ahead : boolean := true;

    -- Read-side flag selection
    g_with_empty        : boolean := true;   -- with empty flag
    g_with_full         : boolean := true;   -- with full flag
    g_with_almost_empty : boolean := false;
    g_with_almost_full  : boolean := false;
    g_with_count        : boolean := false;  -- with words counter

    g_almost_empty_threshold : integer := 0;  -- threshold for almost empty flag
    g_almost_full_threshold  : integer := 0   -- threshold for almost full flag
    );

  port (
    rst_n_i : in std_logic := '1';

    clk_i : in std_logic;
    d_i   : in std_logic_vector(g_data_width-1 downto 0);
    we_i  : in std_logic;

    q_o  : out std_logic_vector(g_data_width-1 downto 0);
    rd_i : in  std_logic;

    empty_o        : out std_logic;
    full_o         : out std_logic;
    almost_empty_o : out std_logic;
    almost_full_o  : out std_logic;
    count_o        : out std_logic_vector(f_log2_size(g_size)-1 downto 0)
    );
end component;

component RS232module is
	Generic(
		CLOCK_FREQUENCY : natural := CLOCK_FREQUENCY
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
end component;


signal wbrs232_data_o_s                      : std_logic_vector(7 downto 0);
signal wbrs232_data_i_s                      : std_logic_vector(7 downto 0);
signal wbrs232_data_wr_s                     : std_logic;
signal wbrs232_done_wr_s                     : std_logic;
signal wbrs232_status_allowed_s              : std_logic_vector(0 downto 0);
signal wbrs232_status_available_s            : std_logic_vector(0 downto 0);
signal wbrs232_control_baud_s                : std_logic_vector(2 downto 0);
signal rs232_data_in_s                       : std_logic_vector(7 downto 0);
signal rs232_busy_s                          : std_logic;
signal readfifo_empty_s                      : std_logic;
signal rs232_data_in_wr_s                    : std_logic;
signal reset_S                               : std_logic;

	
begin

		
		
wb_rs2321: wb_rs232 port map(
	rst_n_i => rst_n_i,
	wb_clk_i => clk_sys_i,
	wb_addr_i => gpio_slave_i.adr(4 downto 2),
	wb_data_i => gpio_slave_i.dat,
	wb_data_o => gpio_slave_o.dat,
	wb_cyc_i => gpio_slave_i.cyc,
	wb_sel_i => gpio_slave_i.sel,
	wb_stb_i => gpio_slave_i.stb,
	wb_we_i => gpio_slave_i.we,
	wb_ack_o => gpio_slave_o.ack ,
	wbrs232_send_data_o => wbrs232_data_o_s,
	wbrs232_send_data_wr_o => wbrs232_data_wr_s,
	wbrs232_read_data_i => wbrs232_data_i_s,
	wbrs232_done_done_o => open,
	wbrs232_done_done_wr_o => wbrs232_done_wr_s,
	wbrs232_status_allowed_i => wbrs232_status_allowed_s,
	wbrs232_status_available_i => wbrs232_status_available_s,
	wbrs232_control_baud_o => wbrs232_control_baud_s
	);
	 
 reset_s <= not rst_n_i;
 RS232module1: RS232module
	port map(
	RS232clock => clk_sys_i,
	Reset => reset_s,
	baud => wbrs232_control_baud_s,
	RxIn => serial_i,
	RxOut => rs232_data_in_s,
	RxPulse => rs232_data_in_wr_s,
	TxIn => wbrs232_data_o_s,
	TxOut => serial_o,
	TxLoad => wbrs232_data_wr_s,
	TxBusy => rs232_busy_s); 

	
 wbrs232_status_allowed_s(0) <= '1' when rs232_busy_s='0' else '0';
 wbrs232_status_available_s(0) <= '1' when readfifo_empty_s='0' else '0';
 readfifo: generic_sync_fifo 
  port map (
    rst_n_i => rst_n_i,
    clk_i => clk_sys_i,
    d_i => rs232_data_in_s,
    we_i => rs232_data_in_wr_s,
    q_o => wbrs232_data_i_s,
    rd_i => wbrs232_done_wr_s,
    empty_o => readfifo_empty_s,
    full_o => open,
    almost_empty_o => open,
    almost_full_o => open,
    count_o => open);
  
end struct;

