-------------------------------------------------------------------------------
-- Title      : Port Event Counter 
-- Project    : White Rabbit 
-------------------------------------------------------------------------------
-- File       : port_cntr.vhd
-- Author     : Cesar Prados
-- Company    : GSI
-- Created    : 2015-08-11
-- Platform   : FPGA-generic
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- Simply counters in two layers organized. L1 is the basic counter and L2,
-- counts the overflow of L1. One bit to sign overflow of L2 counter.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Cesar Prados c.prados@gsi.de / GSI
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.wr_pstats_pkg.all;

entity port_cntr is
  port(
    clk_i       : in  std_logic;
    rstn_i      : in  std_logic;
    cnt_eo_i    : in  std_logic;
    cnt_ovf_o   : out std_logic;
    cnt_o       : out t_cnt);
end port_cntr;

architecture rtl of port_cntr is

  signal s_L1_cnt     : unsigned(c_L1_cnt_density - 1 downto 0);
  signal s_L2_cnt     : unsigned(c_L2_cnt_density - 1 downto 0);
  signal s_L1_ovf     : std_logic;
  signal s_L2_ovf     : std_logic;
  signal s_L1_ovf_d   : std_logic;
  signal s_L1_ovf_r   : std_logic;
  signal s_cnt_ovf    : std_logic;
  signal s_toggle     : std_logic;
begin

  L1_CNT  : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rstn_i = '0' then
        s_L1_cnt  <= (others => '0');
        s_L1_ovf_d <= '0';
      else
        if cnt_eo_i = '1' then
          s_L1_cnt <= s_L1_cnt + 1; 
        else
          s_L1_cnt <= s_L1_cnt; 
        end if;
        s_L1_ovf_d <= s_L1_ovf;
      end if;
    end if;
  end process;

  s_L1_ovf <= '1' when s_L1_cnt = (2**c_L1_cnt_density - 1) else '0';
  s_L1_ovf_r <= (not s_L1_ovf_d) and s_L1_ovf; 
  
  L2_CNT  : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rstn_i = '0' then
        s_L2_cnt    <= (others => '0');
        s_toggle    <= '0';
        s_cnt_ovf   <= '0';
      else
        if s_L1_ovf_r = '1' then
          s_L2_cnt <= s_L2_cnt + 1; 
        else
          s_L2_cnt <= s_L2_cnt; 
        end if;

        if s_L2_ovf = '1' and s_toggle = '0' then
          s_cnt_ovf   <= '1';
          s_toggle    <= '1';
        end if;
      end if;
    end if;
  end process;

  s_L2_ovf  <= '1' when s_L2_cnt = (2**c_L2_cnt_density - 1) else '0';

  cnt_ovf_o     <= s_cnt_ovf;
  cnt_o.L1_cnt  <= std_logic_vector(s_L1_cnt); 
  cnt_o.L2_cnt  <= std_logic_vector(s_L2_cnt);

end rtl;
