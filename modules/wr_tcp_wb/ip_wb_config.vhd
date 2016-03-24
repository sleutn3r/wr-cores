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
    clk_sys_i        :  in std_logic;
    rst_n_i          :  in std_logic;
    ----
    our_mac_address_o:  out std_logic_vector(47 downto 0);
    our_ip_address_o :  out std_logic_vector(31 downto 0);
    dst_ip_address_o :  out std_logic_vector(31 downto 0);
    dst_port_o       :  out std_logic_vector(15 downto 0);
    ip_config_done_o :  out std_logic;
    ----
    wb_o             :  out t_wishbone_master_out;
    wb_i             :  in  t_wishbone_master_in
);
end ip_wb_config;

architecture beha of ip_wb_config is

type t_config_state is (INIT, RD_MACH, RD_MACL, RD_IP, DONE);
signal config_state : t_config_state;

signal rdreq : std_logic;
signal init_cnt : unsigned(31 downto 0);
signal our_ip_address : std_logic_vector(31 downto 0);

begin

dst_ip_address_o <= X"C0A8000C";  -- 192.168.0.12
dst_port_o <= std_logic_vector(unsigned(our_ip_address(7 downto 0)) + to_unsigned(10000,16));
our_ip_address_o <= our_ip_address;
   
p_wb_fsm : process(clk_sys_i)
begin
if rising_edge(clk_sys_i) then
    if rst_n_i = '0' then
        wb_o.cyc <= '0';
        wb_o.stb <= '0';
        wb_o.sel <= "1111";
        wb_o.we  <= '0';
        wb_o.dat <= (others => '0');
    else
        if rdreq = '1' then 
            wb_o.cyc <= '1';
        elsif wb_i.ack = '1' or wb_i.err = '1' then
            wb_o.cyc <= '0';
        end if;

        if rdreq = '1' then
            wb_o.stb <= '1';
        elsif wb_i.stall = '0' then
            wb_o.stb <= '0';
        end if;
    end if;
end if;
end process p_wb_fsm;

with config_state select
    wb_o.adr(31 downto 0) <=  X"00020124" when rd_mach, -- endpoint_mach
                              X"00020128" when rd_macl, -- endpoint_macl
                              X"00020718" when rd_ip,   -- etherbone_ip
                              (others => '0') when others;

p_rd_config : process(clk_sys_i)
begin
if rising_edge(clk_sys_i) then
    if rst_n_i = '0' then
        config_state      <= INIT;
        init_cnt          <= (others => '0');
        ip_config_done_o  <= '0';
        rdreq             <= '0';
        our_mac_address_o <= X"080030902496";
        our_ip_address    <= X"C0A80019";
    else
        case config_state is
        when INIT =>      -- wait for stable mac and ip
            if init_cnt <= X"10000000" then  -- wait 4 seconds to load correct mac and ip address
                init_cnt <= init_cnt +1;
            else
                config_state <= RD_MACH;
                rdreq <= '1';
            end if;
            ip_config_done_o <= '0';
         
        when RD_MACH =>
            rdreq <= '0';
            if wb_i.ack = '1' then
                rdreq <= '1';
                config_state <= RD_MACL;
                our_mac_address_o(47 downto 32) <= wb_i.dat(15 downto 0);
            end if;

        when RD_MACL =>
            rdreq <= '0';
            if wb_i.ack = '1' then
                rdreq <= '1';
                config_state <= RD_IP;
                our_mac_address_o(31 downto 0) <= wb_i.dat;
            end if;

        when RD_IP =>
            rdreq <= '0';
            if wb_i.ack = '1' then
                config_state  <= DONE;
                our_ip_address<= wb_i.dat;
            end if;

        when DONE => 
            ip_config_done_o <= '1';
          
        when others => 
            config_state <= INIT;
        
        end case;
    end if;
end if;
end process p_rd_config;

end beha;
