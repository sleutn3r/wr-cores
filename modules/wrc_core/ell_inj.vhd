-------------------------------------------------------------------------------
-- Title      : WRPC Extra Low Latency Injector (a.k.a supertrigger)
-- Project    : WhiteRabbit
-------------------------------------------------------------------------------
-- File       : ell_inj.vhd
-- Author     : Grzegorz Daniluk
-- Company    : CERN
-- Created    : 2016-10-18
-- Last update: 2016-10-18
-- Platform   : FPGA-generics
-- Standard   : VHDL
-------------------------------------------------------------------------------
--
-- Copyright (c) 2016 CERN
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

entity ell_inj is
  port (
    clk_tx_i    :  in std_logic;
    clk_rx_i    : in std_logic;
    rst_n_i     : in std_logic;
    
    trig_i      : in  std_logic;
    trig_o      : out std_logic;
    tx_trig_o   : out std_logic;
    
    inp_data_i : in std_logic_vector(7 downto 0);
    inp_k_i    : in std_logic;
    inp_enc_err_i : in std_logic;

    outp_data_i : in std_logic_vector(7 downto 0); 
    outp_k_i    : in std_logic; 
    outp_enc_err_i : in std_logic;
    outp_disp_i : in std_logic;
    outp_data_o : out std_logic_vector(7 downto 0); 
    outp_k_o    : out std_logic);
end ell_inj;

architecture behav of ell_inj is
  -- K28.0 is our trigger character
  constant c_TRIG_CHAR : std_logic_vector(7 downto 0) := x"1c";
  --constant c_CNT_PERIOD : integer := 125000000;
  constant c_CNT_PERIOD : integer := 25;
  signal trig_cnt : unsigned(31 downto 0);
  signal fake_trig, main_trig : std_logic;
  signal trig_out : std_logic;

  component chipscope_ila
    port (
      CONTROL : inout std_logic_vector(35 downto 0);
      CLK     : in    std_logic;
      TRIG0   : in    std_logic_vector(31 downto 0);
      TRIG1   : in    std_logic_vector(31 downto 0);
      TRIG2   : in    std_logic_vector(31 downto 0);
      TRIG3   : in    std_logic_vector(31 downto 0));
  end component;

  component chipscope_icon
    port (
      CONTROL0 : inout std_logic_vector (35 downto 0));
  end component;

  signal CONTROL : std_logic_vector(35 downto 0);
  signal CLK     : std_logic;
  signal TRIG0   : std_logic_vector(31 downto 0);
  signal TRIG1   : std_logic_vector(31 downto 0);
  signal TRIG2   : std_logic_vector(31 downto 0);
  signal TRIG3   : std_logic_vector(31 downto 0);



begin

  -- temp trig generation
  process(clk_tx_i)
  begin
    if rising_edge(clk_tx_i) then
      if rst_n_i = '0' then
        trig_cnt <= (others=>'0');
        fake_trig <= '0';
      elsif(trig_cnt = c_CNT_PERIOD-1) then
        trig_cnt <= (others=>'0');
        fake_trig <= '1';
      else
        trig_cnt <= trig_cnt + 1;
        fake_trig <= '0';
      end if;
    end if;
  end process;
  -----------------------
  main_trig <= fake_trig or trig_i;
  tx_trig_o <= main_trig;

  outp_data_o <= outp_data_i when (main_trig = '0') else
                 c_TRIG_CHAR;
  outp_k_o    <= outp_k_i when (main_trig = '0') else
                 '1';

  --outp_data_o <= outp_data_i;
  --outp_k_o    <= outp_k_i;



  --------------------------------
  -- generating trigger on K28.0 detection
  process(clk_rx_i)
  begin
    if rising_edge(clk_rx_i) then
      if rst_n_i = '0' then
        trig_out <= '0';
      elsif(inp_data_i = c_TRIG_CHAR and inp_k_i = '1') then
        trig_out <= '1';
      else
        trig_out <= '0';
      end if;
    end if;
  end process;
  trig_o <= trig_out;


  chipscope_ila_1 : chipscope_ila
    port map (
      CONTROL => CONTROL,
      CLK     => clk_tx_i,
      TRIG0   => TRIG0,
      TRIG1   => TRIG1,
      TRIG2   => TRIG2,
      TRIG3   => TRIG3);

  chipscope_icon_1 : chipscope_icon
    port map (
      CONTROL0 => CONTROL);

  TRIG0(0) <= main_trig;
  TRIG0(1) <= trig_out;
  TRIG0(2) <= outp_k_i;
  TRIG0(3) <= outp_k_i when (main_trig = '0') else
              '1';
  TRIG0(4) <= inp_k_i;
  TRIG0(5) <= inp_enc_err_i;
  TRIG0(6) <= outp_enc_err_i;
  TRIG0(7) <= outp_disp_i;

  TRIG0(15 downto 8)  <= outp_data_i;
  TRIG0(23 downto 16) <= outp_data_i when (main_trig = '0') else
                          c_TRIG_CHAR;

  TRIG0(31 downto 24) <= inp_data_i;


end behav;
