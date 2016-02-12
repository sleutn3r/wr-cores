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
-- Simply counters with overflow bit
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

  signal s_cnt      : t_cnt;
  signal s_ovf      : std_logic;
  signal s_cnt_ovf  : std_logic;
  signal s_toggle   : std_logic;
begin

  CNT  : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rstn_i = '0' then
        s_cnt  <= (others => '0');
      else
        if cnt_eo_i = '1' then
          s_cnt <= s_cnt + 1; 
        else
          s_cnt <= s_cnt; 
        end if;

        if s_ovf = '1' and s_toggle = '0' then
          s_cnt_ovf   <= '1';
          s_toggle    <= '1';
        end if;
      end if;
    end if;
  end process;

  s_ovf  <= '1' when s_cnt = (2**c_cnt_density - 1) else '0';

  cnt_ovf_o     <= s_cnt_ovf;
  cnt_o         <= s_cnt; 
end rtl;
