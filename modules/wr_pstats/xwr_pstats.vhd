--------------------------------------------------------------------------------
-- Title      : Port monitoring system
-- Project    : White Rabbit 
-------------------------------------------------------------------------------
-- File       : xwr_pstats.vhd
-- Author     : Cesar Prados
-- Company    : GSI
-- Created    : 2015-08-11
-- Platform   : FPGA-generic
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- This modules stores and exposes over wb bus the network statistic of the 
-- wr core. 
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

entity xwr_pstats is
  port(
    clk_i       : in  std_logic;
    rstn_i      : in  std_logic;
    events_i    : in  std_logic_vector(c_events - 1 downto 0);
    wb_slave_o  : out t_wishbone_slave_out;
    wb_slave_i  : in  t_wishbone_slave_in);
end xwr_pstats;

architecture rtl of xwr_pstats is
  signal s_cnt_reg  : t_cnt_events;
  signal s_cnt_ovf  : std_logic_vector(c_events - 1 downto 0);
  signal s_rstn     : std_logic;
  signal s_wb_rst   : std_logic;
begin

  s_rstn  <= rstn_i and (not s_wb_rst);

  GEN_STAT_EVENT: for I in 0 to c_events - 1 generate
    CNT_STAT : port_cntr port map (
      clk_i       =>  clk_i,
      rstn_i      =>  s_rstn,
      cnt_eo_i    =>  events_i(I),
      cnt_ovf_o   =>  s_cnt_ovf(I),
      cnt_o       =>  s_cnt_reg(I));
  end generate GEN_STAT_EVENT;  

  U_WB_SLAVE : pstats_wb_slave
    port map (
      clk_i         => clk_i,
      rstn_i        => rstn_i,
      reg_i         => s_cnt_reg,
      cnt_ovf_i     => s_cnt_ovf,
      cnt_rst_o     => s_wb_rst,
      wb_slave_i    => wb_slave_i,
      wb_slave_o    => wb_slave_o);

end rtl;
