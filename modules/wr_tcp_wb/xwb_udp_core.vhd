-------------------------------------------------------------------------------
-- Title      : UDP module COM5402 with wishbone fabric interface
-- Project    : 
-------------------------------------------------------------------------------
-- File       : xwb_udp_core.vhd
-- Author     : lihm
-- Company    : Tsinghua
-- Created    : 2015-01-26
-- Last update: 2016-01-26
-- Platform   : Xilinx Spartan 6
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: UDP module COM5402 with wishbone fabric interface, connected
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
    udp_rx_data: out std_logic_vector(7 downto 0);
    udp_rx_data_valid: out std_logic;
    udp_rx_sof: out std_logic;
    udp_rx_eof: out std_logic;

    src_o : out t_wrf_source_out;
    src_i : in  t_wrf_source_in;
    
    udp_tx_data: in std_logic_vector(7 downto 0);
    udp_tx_data_valid: in std_logic;
    udp_tx_sof: in std_logic;
    udp_tx_eof: in std_logic;
    udp_tx_cts: out std_logic;
    udp_tx_ack: out std_logic;
    udp_tx_nak: out std_logic;

    udp_tx_dest_ip_addr:    in std_logic_vector(127 downto 0);
    udp_tx_dest_port_no:    in std_logic_vector(15 downto 0); 

    ext_cfg_slave_in : in t_wishbone_slave_in;
    ext_cfg_slave_out : out t_wishbone_slave_out
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
    udp_tx_source_port_no: in std_logic_vector(15 downto 0)
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
    clk_i :  in std_logic;
    rst_n_i   :  in std_logic;
    ----
    my_mac_o : out std_logic_vector(47 downto 0);
    my_ip_o  : out std_logic_vector(31 downto 0);
    my_port_o: out std_logic_vector(15 downto 0);
    ----
    cfg_i : in t_wishbone_slave_in;
    cfg_o : out t_wishbone_slave_out
);
end component;
  
signal rst:std_logic;
signal my_mac : std_logic_vector(47 downto 0) := (others => '0');
signal my_ip  : std_logic_vector(31 downto 0) := (others => '0'); 
signal my_port: std_logic_vector(15 downto 0);
signal my_gateway: std_logic_vector(31 downto 0) := (others => '0'); 

signal mac_rx_data : std_logic_vector(7 downto 0) := (others => '0');
signal mac_rx_data_valid : std_logic := '0';
signal mac_rx_sof : std_logic := '0';
signal mac_rx_eof : std_logic := '0';
  
signal mac_tx_data : std_logic_vector(7 downto 0);
signal mac_tx_data_valid : std_logic;
signal mac_tx_eof : std_logic;
signal mac_tx_cts : std_logic := '1'; 

signal test_point:std_logic_vector(31 downto 0);

begin

my_gateway <= my_ip(31 downto 8) & x"01";
rst <= not rst_n_i;

inst_com5402 : com5402
generic map(
    clk_frequency       => 125,  -- 125 mhz clock (8ns simulation period), use for time and frequency
    simulation          => '0'
)
port map (
    clk                 => clk_ref,
    async_reset         => rst,
    sync_reset          => rst,
    mac_addr            => my_mac,
    ipv4_addr           => my_ip,
    ipv6_addr           => x"0123456789abcdef00112233ac100180",
    subnet_mask         => x"ffffff00",
    gateway_ip_addr     => my_gateway,
    mac_tx_data         => mac_tx_data,
    mac_tx_data_valid   => mac_tx_data_valid,
    mac_tx_eof          => mac_tx_eof,
    mac_tx_cts          => mac_tx_cts,
    mac_rx_data         => mac_rx_data,
    mac_rx_data_valid   => mac_rx_data_valid,
    mac_rx_sof          => mac_rx_sof,
    mac_rx_eof          => mac_rx_eof,
    -- udp rx
    udp_rx_data         => udp_rx_data,
    udp_rx_data_valid   => udp_rx_data_valid,
    udp_rx_sof          => udp_rx_sof,
    udp_rx_eof          => udp_rx_eof,
    udp_rx_dest_port_no => my_port,
    -- udp tx
    udp_tx_data         => udp_tx_data,
    udp_tx_data_valid   => udp_tx_data_valid,
    udp_tx_sof          => udp_tx_sof,
    udp_tx_eof          => udp_tx_eof,
    udp_tx_cts          => udp_tx_cts,
    udp_tx_ack          => udp_tx_ack,
    udp_tx_nak          => udp_tx_nak,
    udp_tx_dest_ip_addr => udp_tx_dest_ip_addr,
    udp_tx_dest_port_no => udp_tx_dest_port_no,
    udp_tx_source_port_no => my_port
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
    src_o       => src_o,
    data_i      => mac_tx_data,
    data_valid_i=> mac_tx_data_valid,
    eof_i       => mac_tx_eof,
    cts_o       => mac_tx_cts
);

U_ip_wb_config : ip_wb_config
port map(
    clk_i       => clk_sys,
    rst_n_i     => rst_n_i,
    my_mac_o    => my_mac,
    my_ip_o     => my_ip,
    my_port_o   => my_port,
    cfg_i       => ext_cfg_slave_in,
    cfg_o       => ext_cfg_slave_out
);

end behavioral;

