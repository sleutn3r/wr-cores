-------------------------------------------------------------------------------
-- Title      : WB interface for the pstats module
-- Project    : White Rabbit 
-------------------------------------------------------------------------------
-- File       : pstats_wb_slave.vhd
-- Author     : Cesar Prados
-- Company    : GSI
-- Created    : 2015-08-11
-- Platform   : FPGA-generic
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- Slave WB interface. It rolls as many registers as stat events (max 32)
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Cesar Prados c.prados@gsi.de / GSI
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.wr_pstats_pkg.all;

entity pstats_wb_slave is
    port (
      clk_i       : in  std_logic;
      rstn_i      : in  std_logic;
      reg_i       : in  t_cnt_events;
      cnt_ovf_i   : in  std_logic_vector(c_events - 1 downto 0);
      cnt_rst_o   : out std_logic;
      wb_slave_o  : out t_wishbone_slave_out;
      wb_slave_i  : in  t_wishbone_slave_in);
end pstats_wb_slave;

architecture rtl of pstats_wb_slave is
    signal s_cnt_switch : std_logic;
    signal s_cnt_rst    : std_logic;
begin

  cnt_rst_o <= s_cnt_rst;

  WB_SLAVE  : process(clk_i)
    variable v_cnt_adr : std_logic_vector(4 downto 0);
  begin
    if rising_edge(clk_i) then
      if rstn_i = '0' then
        wb_slave_o.ack  <= '0';
        wb_slave_o.dat  <= (others => '0');
        s_cnt_switch    <= '0';
        s_cnt_rst       <= '0';
      else
        wb_slave_o.ack <= wb_slave_i.cyc and wb_slave_i.stb;

        if wb_slave_i.cyc = '1' and wb_slave_i.stb = '1' then
          if wb_slave_i.adr(6 downto 2) = "00000" then
            if wb_slave_i.we = '1' then
              if wb_slave_i.dat(0) = '0' then 
                s_cnt_switch  <= wb_slave_i.dat(1);
              elsif wb_slave_i.dat(0) = '1' then
                s_cnt_rst     <= '1';
              end if;
            else
              wb_slave_o.dat  <= std_logic_vector(resize(unsigned(cnt_ovf_i), wb_slave_o.dat'length));
            end if;
          else
            for I in 1 to c_events loop
              v_cnt_adr := std_logic_vector(to_unsigned(I,5));
              if wb_slave_i.adr(6 downto 2) = v_cnt_adr then
                if s_cnt_switch = '0' then
                  wb_slave_o.dat  <= std_logic_vector(resize(unsigned(reg_i(I - 1).L1_cnt), wb_slave_o.dat'length));
                else
                  wb_slave_o.dat  <= std_logic_vector(resize(unsigned(reg_i(I - 1).L2_cnt), wb_slave_o.dat'length));
                end if;
              end if;
            end loop;
          end if;
        else
          s_cnt_rst     <= '0';
        end if;
      end if;
    end if;
  end process;

end rtl;
