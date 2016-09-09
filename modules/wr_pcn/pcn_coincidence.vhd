-------------------------------------------------------------------------------
-- Title      : PCN Coincidence Module
-- Project    : White Rabbit 
-------------------------------------------------------------------------------
-- File       : pcn_coincidence.vhd
-- Author     : hongming
-- Company    : THU-DEP
-- Created    : 2016-08-29
-- Last update: 2016-08-29
-- Platform   : FPGA-generic
-- Standard   : VHDL '93
-------------------------------------------------------------------------------
-- Description: Gets data from two fifos, output the difference value if these
-- data are in a preset window.
-------------------------------------------------------------------------------
--
-- Copyright (c) 2016 - 2017 THU / DEP
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pcn_coincidence is

  generic(
-- clock frequency
    g_clk_freq : natural := 62500000;
-- fifo data width
    g_data_width : natural := 32;
-- coincidence window, 16 ns * ( 2^g_windows_width -1 )
    g_window_width : natural := 10;
-- diff data width
    g_diff_width : natural := 18
   );
  port (
    clk_sys_i : in std_logic:='0';
    rst_n_i	  : in std_logic:='0';
    
    fifoa_empty_i : in std_logic:='0';
    fifoa_rd_o    : out std_logic;
    fifoa_rddata_i  : in  std_logic_vector(g_diff_width-1 downto 0):=(others=>'0');
    
    fifob_empty_i : in std_logic:='0';
    fifob_rd_o    : out std_logic;
    fifob_rddata_i  : in  std_logic_vector(g_diff_width-1 downto 0):=(others=>'0');

    diff_fifo_wr_o   : out std_logic;
    diff_fifo_wrdata_o : out std_logic_vector(g_diff_width downto 0);
    diff_fifo_full_i : in std_logic:='0'
  );

end pcn_coincidence;

architecture behavioral of pcn_coincidence is

    type t_coincidence_state is (S_IDLE, S_READA, S_READB, S_WAIT_READ,S_CAL_DIFF);
    signal state : t_coincidence_state;

    signal coincidence_cntr : unsigned(g_window_width-1 downto 0);
    constant C_COINCIDENCE_WINDOW: unsigned(g_window_width-1 downto 0):=(others=>'1');

    signal fifoa_rddata,fifob_rddata:unsigned(g_diff_width downto 0);
    signal diff_value : unsigned(g_diff_width downto 0);
    signal diff_valid : std_logic;

begin
  
  fifoa_rddata <= unsigned('0' & fifoa_rddata_i(g_diff_width-1 downto 0));
  fifob_rddata <= unsigned('0' & fifob_rddata_i(g_diff_width-1 downto 0));
  diff_fifo_wr_o <= diff_valid and (not diff_fifo_full_i);
  diff_fifo_wrdata_o <= std_logic_vector(diff_value);

  g_coincidence_proc : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if (rst_n_i = '0')then
        state <= S_IDLE;
        diff_valid <= '0';
        diff_value <= (others=>'0');
        fifoa_rd_o <= '0';
        fifob_rd_o <= '0';
        coincidence_cntr <= (others=>'0');
      else
        case( state ) is
          when S_IDLE  =>
            diff_valid <= '0';
            diff_value <= (others=>'0');
            coincidence_cntr <= (others=>'0');
            fifoa_rd_o <= '0';
            fifob_rd_o <= '0';
            if (fifoa_empty_i='0') and (fifob_empty_i='0') then
              state <= S_WAIT_READ;
              fifoa_rd_o <= '1';
              fifob_rd_o <= '1';
            elsif (fifoa_empty_i='0') then
              state <= S_READA;
              fifoa_rd_o <= '1';
            elsif (fifob_empty_i='0') then
              state <= S_READB;
              fifob_rd_o <= '1';
            else
              state <= S_IDLE;
            end if ;

          when S_READA =>            
            diff_valid <= '0';
            fifoa_rd_o <= '0';
            if (fifob_empty_i='0') then
              state <= S_WAIT_READ;
              fifob_rd_o <= '1';
              coincidence_cntr <= (others=>'0');
            elsif coincidence_cntr < C_COINCIDENCE_WINDOW then
              coincidence_cntr <= coincidence_cntr + 1;
            else
              coincidence_cntr <= (others=>'0');
              state <= S_IDLE;
            end if;

          when S_READB =>
            diff_valid <= '0';
            fifob_rd_o <= '0';
            if (fifoa_empty_i='0') then
              fifoa_rd_o <= '1';
              state <= S_WAIT_READ;
              coincidence_cntr <= (others=>'0');
            elsif coincidence_cntr < C_COINCIDENCE_WINDOW then
              coincidence_cntr <= coincidence_cntr + 1;
            else
              coincidence_cntr <= (others=>'0');
              state <= S_IDLE;
            end if;

          when S_WAIT_READ =>
            fifoa_rd_o <= '0';
            fifob_rd_o <= '0';
            diff_valid <= '0';
            state <= S_CAL_DIFF;

          when S_CAL_DIFF =>
            diff_valid <= '1';
            diff_value <= fifoa_rddata - fifob_rddata;
            coincidence_cntr <= (others=>'0');
            if (fifoa_empty_i='0') and (fifob_empty_i='0') then
              state <= S_WAIT_READ;
              fifoa_rd_o <= '1';
              fifob_rd_o <= '1';
            elsif (fifoa_empty_i='0') then
              state <= S_READA;
              fifoa_rd_o <= '1';
            elsif (fifob_empty_i='0') then
              state <= S_READB;
              fifob_rd_o <= '1';
            else
              state <= S_IDLE;
            end if ;

          when others  =>
            state <= S_IDLE;
        end case ;
      end if ;
    end if ;
  end process ; -- g_coincidence_proc

end architecture ; -- behavioral