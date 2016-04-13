-------------------------------------------------------------------------------
-- Title      : TCP module COM5402 with wishbone fabric interface
-- Project    : 
-------------------------------------------------------------------------------
-- File       : xwb_tcp_core.vhd
-- Author     : lihm
-- Company    : Tsinghua
-- Created    : 2015-01-26
-- Last update: 2016-01-26
-- Platform   : Xilinx Spartan 6
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: TCP module COM5402 with wishbone fabric interface, connected
-- with WRPC. 
-------------------------------------------------------------------------------
--
-- Copyright (c) 2011 CERN
--
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2015-01-26  1.0      lihm            Created
-- 2016-01-26  2.0      lihm            Add more annotation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.wrcore_pkg.all;
use work.wr_fabric_pkg.all;
use work.wishbone_pkg.all;
use work.com5402pkg.all;  -- defines global types, number of tcp streams, etc

entity xwb_udp_core is
port(
    clk_ref : in std_logic;
    clk_sys  : in std_logic;
    rst_n_i : IN std_logic;

    snk_i : in  t_wrf_sink_in;
    snk_o : out t_wrf_sink_out;
    UDP_RX_DATA: out std_logic_vector(7 downto 0);
    UDP_RX_DATA_VALID: out std_logic;
    UDP_RX_SOF: out std_logic;
    UDP_RX_EOF: out std_logic;

    src_o : out t_wrf_source_out;
    src_i : in  t_wrf_source_in;
    
    UDP_TX_DATA: in std_logic_vector(7 downto 0);
    UDP_TX_DATA_VALID: in std_logic;
    UDP_TX_SOF: in std_logic;
    UDP_TX_EOF: in std_logic;
    UDP_TX_CTS: out std_logic;
    UDP_TX_ACK: out std_logic;
    UDP_TX_NAK: out std_logic;

    wb_i : in t_wishbone_master_in;
    wb_o : out t_wishbone_master_out
);
end xwb_udp_core;

architecture behavioral of xwb_udp_core is

component com5402
generic (
    clk_frequency: integer;
    simulation: std_logic
);  
port(
    clk : in std_logic;
    async_reset : in std_logic;
    sync_reset : in std_logic;
    mac_addr : in std_logic_vector(47 downto 0);
    ipv4_addr : in std_logic_vector(31 downto 0);
    ipv6_addr : in std_logic_vector(127 downto 0);
    subnet_mask: in std_logic_vector(31 downto 0);
    gateway_ip_addr: in std_logic_vector(31 downto 0);
    mac_tx_cts : in std_logic;
    mac_rx_data : in std_logic_vector(7 downto 0);
    mac_rx_data_valid : in std_logic;
    mac_rx_sof : in std_logic;
    mac_rx_eof : in std_logic;          
    mac_tx_data : out std_logic_vector(7 downto 0);
    mac_tx_data_valid : out std_logic;
    mac_tx_eof : out std_logic;
    udp_rx_data: out std_logic_vector(7 downto 0);
    udp_rx_data_valid: out std_logic;
    udp_rx_sof: out std_logic;  
    udp_rx_eof: out std_logic;  
    udp_rx_dest_port_no: in std_logic_vector(15 downto 0);
    udp_tx_data: in std_logic_vector(7 downto 0);
    udp_tx_data_valid: in std_logic;
    udp_tx_sof: in std_logic; 
    udp_tx_eof: in std_logic; 
    udp_tx_cts: out std_logic;  
    udp_tx_ack: out std_logic;  
    udp_tx_nak: out std_logic;  
    udp_tx_dest_ip_addr: in std_logic_vector(127 downto 0);
    udp_tx_dest_port_no: in std_logic_vector(15 downto 0);
    udp_tx_source_port_no: in std_logic_vector(15 downto 0);
    tcp_rx_data: out slv8xntcpstreamstype;
    tcp_rx_data_valid: out std_logic_vector((ntcpstreams-1) downto 0);
    tcp_rx_rts: out std_logic;
    tcp_rx_cts: in std_logic;
    tcp_tx_data: in slv8xntcpstreamstype;
    tcp_tx_data_valid: in std_logic_vector((ntcpstreams-1) downto 0);
    tcp_tx_cts: out std_logic_vector((ntcpstreams-1) downto 0); 

    tp : out std_logic_vector(31 downto 0)
);
end component;

component mac_to_c5402
port(
    clk_wr       : in std_logic;
    clk_rd       : in std_logic;
    rst_n_i     : in std_logic;

    snk_i       : in  t_wrf_sink_in;
    snk_o       : out t_wrf_sink_out;
    data_o      : out std_logic_vector(7 downto 0);
    data_valid_o: out std_logic;
    sof_o       : out std_logic;
    eof_o       : out std_logic
);
end component;

component c5402_to_mac
port(
  clk_wr       : in std_logic;
  clk_rd       : in std_logic;
  rst_n_i     : in std_logic;
   
  src_o       : out t_wrf_source_out;
  src_i       : in  t_wrf_source_in;
  data_i      : in std_logic_vector(7 downto 0);
  data_valid_i: in std_logic;
  eof_i       : in std_logic;
  cts_o       : out std_logic);
end component;

component ip_wb_config is
port(
  clk_sys_i :  in std_logic;
  rst_n_i   :  in std_logic;
  ----
  our_mac_address_o : out std_logic_vector(47 downto 0);
  our_ip_address_o  : out std_logic_vector(31 downto 0);
  dst_ip_address_o  : out std_logic_vector(31 downto 0);
  dst_port_o        : out std_logic_vector(15 downto 0);
  ip_config_done_o  : out std_logic;
  ----
  wb_o              : out t_wishbone_master_out;
  wb_i              : in  t_wishbone_master_in);
end component;
  
signal rst:std_logic;
signal our_mac_address : std_logic_vector(47 downto 0) := (others => '0');
signal our_ip_address  : std_logic_vector(31 downto 0) := (others => '0'); 
signal ip_config_done:std_logic;

signal mac_rx_data : std_logic_vector(7 downto 0) := (others => '0');
signal mac_rx_data_valid : std_logic := '0';
signal mac_rx_sof : std_logic := '0';
signal mac_rx_eof : std_logic := '0';
  
signal mac_tx_data : std_logic_vector(7 downto 0);
signal mac_tx_data_valid : std_logic;
signal mac_tx_eof : std_logic;
signal mac_tx_cts : std_logic := '1'; 

signal test_point:std_logic_vector(31 downto 0);
signal src : t_wrf_source_out;

--component chipscope_ila
--port (
--  CONTROL : inout std_logic_vector(35 downto 0);
--  CLK     : in    std_logic;
--  TRIG0   : in    std_logic_vector(31 downto 0);
--  TRIG1   : in    std_logic_vector(31 downto 0);
--  TRIG2   : in    std_logic_vector(31 downto 0);
--  TRIG3   : in    std_logic_vector(31 downto 0));
--end component;

--component chipscope_icon
--port (
--  CONTROL0 : inout std_logic_vector (35 downto 0));
--end component;

--signal CONTROL : std_logic_vector(35 downto 0);
--signal CLK     : std_logic;
--signal TRIG0   : std_logic_vector(31 downto 0);
--signal TRIG1   : std_logic_vector(31 downto 0);
--signal TRIG2   : std_logic_vector(31 downto 0);
--signal TRIG3   : std_logic_vector(31 downto 0);

begin

inst_com5402 : com5402
generic map(
    clk_frequency=> 125,  -- 125 mhz clock (8ns simulation period), use for time and frequency
    simulation     => '0'
)
port map (
    clk         => clk_ref,
    async_reset => rst,
    sync_reset  => rst,
    mac_addr    => our_mac_address,
    --mac_addr => x"001aa9c4ad0b",
    ipv4_addr   => our_ip_address,
    --ipv4_addr => x"c0a82573",
    ipv6_addr   => x"0123456789abcdef00112233ac100180",
    --ipv6_addr => ipv6_addr,
    subnet_mask => x"ffffff00",
    --gateway_ip_addr => gateway_ip_addr,
    gateway_ip_addr =>x"c0a82501",
    mac_tx_data => mac_tx_data,
    mac_tx_data_valid => mac_tx_data_valid,
    mac_tx_eof  => mac_tx_eof,
    mac_tx_cts  => mac_tx_cts,
    mac_rx_data => mac_rx_data,
    mac_rx_data_valid => mac_rx_data_valid,
    mac_rx_sof  => mac_rx_sof,
    mac_rx_eof  => mac_rx_eof,
    -- udp rx
    udp_rx_data => UDP_RX_DATA,
    udp_rx_data_valid => UDP_RX_DATA_VALID,
    udp_rx_sof  => UDP_RX_SOF,
    udp_rx_eof  => UDP_RX_EOF,
    udp_rx_dest_port_no => x"5555",
    -- udp tx
    udp_tx_data => UDP_TX_DATA,
    udp_tx_data_valid => UDP_TX_DATA_VALID,
    udp_tx_sof  => UDP_TX_SOF,
    udp_tx_eof  => UDP_TX_EOF,
    udp_tx_cts  => UDP_TX_CTS,
    udp_tx_ack  => UDP_TX_ACK,
    udp_tx_nak  => UDP_TX_NAK,
    udp_tx_dest_ip_addr => x"000000000000000000000000FFFFFFFF",
    udp_tx_dest_port_no => x"5555",
    udp_tx_source_port_no => x"2222",
    -- tcp rx streams
    tcp_rx_data         => open,
    tcp_rx_data_valid   => open,
    tcp_rx_rts          => open,
    tcp_rx_cts          => '1',
    -- tcp tx streams
    tcp_tx_data         => (others => (others => '0')),
    tcp_tx_data_valid   => (others => '0'),
    tcp_tx_cts          => open,
    -- monitoring
    tp => test_point
);

inst_macto5402 :mac_to_c5402
port map(
    clk_wr  => clk_sys,
    clk_rd  => clk_ref,
    rst_n_i => rst_n_i,

    snk_o       => snk_o,
    snk_i       => snk_i,

    data_o      => mac_rx_data,
    data_valid_o=> mac_rx_data_valid,
    sof_o       => mac_rx_sof,
    eof_o       => mac_rx_eof
);

inst_c5402tomac : c5402_to_mac
port map(
    clk_wr      => clk_ref,
    clk_rd      => clk_sys,
    rst_n_i     => rst_n_i,

    src_i       => src_i,
    src_o       => src,
    data_i      => mac_tx_data,
    data_valid_i=> mac_tx_data_valid,
    eof_i       => mac_tx_eof,
    cts_o       => mac_tx_cts
);

U_ip_wb_config : ip_wb_config
port map(
    clk_sys_i   => clk_sys,
    rst_n_i     => rst_n_i,
    our_mac_address_o => our_mac_address,
    our_ip_address_o  => our_ip_address,
    dst_ip_address_o  => open,
    dst_port_o        => open,
    ip_config_done_o  => ip_config_done,
    wb_o              => wb_o,
    wb_i              => wb_i
);

rst <= not ip_config_done;
src_o <= src;

--   chipscope_ila_1 : chipscope_ila
--     port map (
--       CONTROL => CONTROL,
--       CLK     => CLK_125,
--       TRIG0   => TRIG0,
--       TRIG1   => TRIG1,
--       TRIG2   => TRIG2,
--       TRIG3   => TRIG3);

--   chipscope_icon_1 : chipscope_icon
--     port map (
--       CONTROL0 => CONTROL);

--   trig0(15 downto 0)  <= snk_i.dat;
--   trig0(17 downto 16)  <= snk_i.adr;
--   trig0(18)  <= snk_i.cyc;
--   trig0(19)  <= snk_i.stb;
--   trig0(20)  <= snk_i.we;
--   trig0(22 downto 21)  <= snk_i.sel;

--   trig1(7 downto 0)  <= MAC_RX_DATA;
--   trig1(8)  <= MAC_RX_DATA_VALID;
--   trig1(9)  <= MAC_RX_SOF;
--   trig1(10) <= MAC_RX_EOF;
--   trig1(18 downto 11)  <= MAC_TX_DATA;
--   trig1(19)  <= MAC_TX_DATA_VALID;
--   trig1(20)  <= MAC_TX_EOF;
--   trig1(21) <= MAC_TX_CTS;

--   trig2 <= TEST_POINT;

--   trig3(15 downto 0)  <= src.dat;
--   trig3(17 downto 16)  <= src.adr;
--   trig3(18)  <= src.cyc;
--   trig3(19)  <= src.stb;
--   trig3(20)  <= src.we;
--   trig3(22 downto 21)  <= src.sel;
--   trig3(23) <= src_i.ack;
--   trig3(24) <= src_i.stall;
--   trig3(25) <= src_i.err;
--   trig3(26) <= src_i.rty;

end behavioral;

