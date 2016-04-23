-------------------------------------------------------------------------------
-- Title      : get ip through wishbone interface
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ip_wb_config.vhd
-- Author     : lihm
-- Company    : Tsinghua
-- Created    : 2015-01-26
-- Last update: 2016-01-26
-- Platform   : Xilinx Spartan 6
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Get IP address through wishbone interface for COM5402 module.
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
use ieee.numeric_std.all;
use work.wishbone_pkg.all;

entity ip_wb_config is
port(
    clk_i :  in std_logic;
    rst_n_i   :  in std_logic;
    ----
    my_mac_o  : out std_logic_vector(47 downto 0);
    my_ip_o   : out std_logic_vector(31 downto 0);
    my_port_o : out std_logic_vector(15 downto 0);
    ----
    cfg_i  : in t_wishbone_slave_in;
    cfg_o  : out t_wishbone_slave_out
);
end ip_wb_config;

architecture rtl of ip_wb_config is
  
  constant c_pad  : std_logic_vector(31 downto 16) := (others => '0');
  
  signal r_mac  : std_logic_vector(6*8-1 downto 0);
  signal r_ip   : std_logic_vector(4*8-1 downto 0);
  signal r_port : std_logic_vector(2*8-1 downto 0);
  
  impure function update(x : std_logic_vector) return std_logic_vector is
    alias    y : std_logic_vector(x'length-1 downto 0) is x;
    variable o : std_logic_vector(x'length-1 downto 0);
  begin
    for i in (y'length/8)-1 downto 0 loop
      if cfg_i.sel(i) = '1' then
        o(i*8+7 downto i*8) := cfg_i.dat(i*8+7 downto i*8);
      else
        o(i*8+7 downto i*8) := y(i*8+7 downto i*8);
      end if;
    end loop;
    
    return o;
  end update;
  
begin

  cfg_o.int <= '0';
  cfg_o.err <= '0';
  cfg_o.rty <= '0';
  cfg_o.stall <= '0';

  cfg_wbs : process(rst_n_i, clk_i) is
  begin
    if rst_n_i = '0' then
      r_mac  <= x"D15EA5EDBEEF";
      r_ip   <= x"C0A80064";
      r_port <= x"EBC0";
      
      cfg_o.ack <= '0';
      cfg_o.dat <= (others => '0');
    elsif rising_edge(clk_i) then
      if cfg_i.cyc = '1' and cfg_i.stb = '1' and cfg_i.we = '1' then
        case to_integer(unsigned(cfg_i.adr(4 downto 2))) is
          when 4 => r_mac(47 downto 32) <= update(r_mac(47 downto 32));
          when 5 => r_mac(31 downto  0) <= update(r_mac(31 downto  0));
          when 6 => r_ip   <= update(r_ip);
          when 7 => r_port <= update(r_port);
          when others => null;
        end case;
      end if;
      
      cfg_o.ack <= cfg_i.cyc and cfg_i.stb;
      
      case to_integer(unsigned(cfg_i.adr(4 downto 2))) is
        when 0 => cfg_o.dat <= (others =>'0');
        when 1 => cfg_o.dat <= (others =>'0');
        when 2 => cfg_o.dat <= (others => '0');
        when 3 => cfg_o.dat <= (others => '0');
        when 4 => cfg_o.dat <= c_pad & r_mac(47 downto 32);
        when 5 => cfg_o.dat <= r_mac(31 downto 0);
        when 6 => cfg_o.dat <= r_ip;
        when others => cfg_o.dat <= c_pad & r_port;
      end case;
      
    end if;
  end process;
    
  my_mac_o  <= r_mac;
  my_ip_o   <= r_ip;
  my_port_o <= r_port;

end rtl;