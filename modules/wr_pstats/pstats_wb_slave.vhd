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
-- Regsiter 0x0 : Read  -> read the overflow register for the counters
--                Write -> if bit 0 is 1 = reset the counters
-- Register 0x4 - 0xI -> the first c_events registers correspond the low 32 bits
--                       of the counters, the (c_events+1) - (2*c_events) are the
--                       high bits counters.
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
      port_cnt_i  : in  t_cnt_events;
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
    variable v_cnt_addr : std_logic_vector(c_events_l - 1 downto 0);
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
          if wb_slave_i.adr(7 downto 2) = "000000" then
            if wb_slave_i.we = '1' then -- reset counters
              s_cnt_rst     <= '1';
            else -- read overflow register               
              wb_slave_o.dat <= std_logic_vector(resize(unsigned(cnt_ovf_i), wb_slave_o.dat'length));
            end if;
          else   -- read counters
            for I in 1 to c_cnt_reg loop
              v_cnt_addr := std_logic_vector(to_unsigned(I,c_events_l));
              if wb_slave_i.adr(7 downto 2) = v_cnt_addr then
                if I <= c_events then
                 wb_slave_o.dat <= std_logic_vector(resize(unsigned(port_cnt_i(I - 1)(31 downto 0)), 
                                                    wb_slave_o.dat'length));
                else
                 wb_slave_o.dat <= std_logic_vector(resize(unsigned(port_cnt_i(I - c_events - 1)(c_cnt_density - 1 downto 32)), 
                                                    wb_slave_o.dat'length));
                end if;
              end if;
            end loop;
          end if;
        else
          s_cnt_rst <= '0';
        end if;
      end if;
    end if;
  end process;

end rtl;
