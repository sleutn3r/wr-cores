-------------------------------------------------------------------------------
-- Title      : MAC to COM5402 module / Rx
-- Project    : 
-------------------------------------------------------------------------------
-- File       : mac_to_5402.vhd
-- Author     : lihm
-- Company    : Tsinghua
-- Created    : 2015-01-26
-- Last update: 2016-01-26
-- Platform   : Xilinx Spartan 6
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Rx path, data goes from MAC(WRPC) to COM5042 module.
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
-- 2016-03-09  3.0      lihm            Rewrite
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.genram_pkg.all;
use work.wr_fabric_pkg.all;
use work.wrcore_pkg.all;

entity mac_to_c5402 is
port (
    clk_wr    :   in std_logic;
    clk_rd    :   in std_logic;
    rst_n_i   :   in std_logic;

    snk_i     :   in  t_wrf_sink_in;
    snk_o     :   out t_wrf_sink_out;
    data_o    :   out std_logic_vector(7 downto 0);
    data_valid_o: out std_logic;
    sof_o     :   out std_logic;
    eof_o     :   out std_logic
);
end mac_to_c5402;

architecture rtl of mac_to_c5402 is

signal snk_out : t_wrf_sink_out;

signal dvalid:std_logic;
signal bytesel:std_logic;
signal data:std_logic_vector(15 downto 0);
signal eof:std_logic;
signal sof:std_logic;

type t_state is(T_IDLE,T_START,T_EVEN,T_ODD);
signal state : t_state;

function f_b2s (x : boolean)
    return std_logic is
begin
    if(x) then
        return '1';
    else
        return '0';
    end if;
end function;  

begin  -- rtl

snk_o         <= snk_out;
snk_out.stall <= '0';
snk_out.err   <= '0';
snk_out.rty   <= '0';

p_gen_ack : process(clk_wr)
begin
if rising_edge(clk_wr) then
    if rst_n_i = '0' then
        snk_out.ack <= '0';
    else
        snk_out.ack <= snk_i.cyc and snk_i.stb and snk_i.we and not snk_out.stall;
    end if;
end if;
end process;

dvalid <= f_b2s(snk_i.adr=C_WRF_DATA) and snk_i.cyc and snk_i.stb;-- data valid

sof_o <= sof;
eof_o <= eof;
data_o <= data(15 downto 8) when bytesel = '1' else
			 data(7 downto 0);

p_rd_fsm: process (clk_rd)
begin
if rising_edge(clk_rd) then
    if rst_n_i = '0' then
        sof <= '0';
        eof <= '0';
        data_valid_o <='0';
        bytesel <= '0';
        data <= (others=>'0');
    else

        case( state ) is
            when T_IDLE =>
                sof <= '0';
                eof <= '0';
                data_valid_o <= '0';
                bytesel <= '0';
                data <= (others=>'0');
                
                if dvalid = '1' then
                    state <= T_START;
                end if ;

            when T_START =>
                sof <= '1';
                eof <= '0';					 
                data_valid_o <= '1';
                bytesel <= '1';
                data <= snk_i.dat;
                state <= T_ODD;

            when T_ODD =>
                sof <= '0';
                if dvalid = '0' then
                    if eof = '1' then
                        eof <= '0';
                        data_valid_o <= '0';
                        bytesel <= '0';
                    else
                        eof <= '1';
                        data_valid_o <= '1';
                        bytesel <= '0';
                    end if;
                    state <= T_IDLE;
                else
                    eof <= '0';
                    data_valid_o <= '1';
                    bytesel <= '0';
                    state <= T_EVEN;
                end if ;

            when T_EVEN =>
                sof <= '0';
                eof <= '0';
                data_valid_o <= '1';
                bytesel <= '1';
                data <= snk_i.dat;
                state <= T_ODD;
                if snk_i.sel = "10" then
                    eof <= '1';
                end if;

            when others =>
                state <= T_IDLE;
        end case ;
    end if ;
end if ;
end process;

end rtl;