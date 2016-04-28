-------------------------------------------------------------------------------
-- Title      : COM5402 module to MAC / Tx
-- Project    : 
-------------------------------------------------------------------------------
-- File       : c5402_to_mac.vhd
-- Author     : lihm
-- Company    : Tsinghua
-- Created    : 2015-01-26
-- Last update: 2016-01-26
-- Platform   : Xilinx Spartan 6
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Tx path, data goes from COM5042 module to MAC(WRPC).
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
-- 2016-01-26  2.0      lihm            Add more annotation and error handling
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.wr_fabric_pkg.all;
use work.wishbone_pkg.all;
use work.genram_pkg.all;

entity c5402_to_mac is
port(
    clk_wr   : in std_logic;
    clk_rd   : in std_logic;
    rst_n_i  : in std_logic;

    src_o    : out t_wrf_source_out;
    src_i    : in  t_wrf_source_in;

    data_i: in std_logic_vector(7 downto 0);
    data_valid_i: in std_logic;
    eof_i: in std_logic;
    cts_o: out std_logic
);
end c5402_to_mac;

architecture behavioral of c5402_to_mac is

constant C_FIFO_WIDTH : integer := 16 + 2;

signal src_out : t_wrf_source_out;
signal stall,ack,err,rty: std_logic;

signal fifo_wr_almost_full, fifo_wrreq, fifo_rdreq,fifo_empty: std_logic;
signal fifo_wrdata, fifo_rddata   : std_logic_vector(c_fifo_width-1 downto 0);

signal pre_eof: std_logic;
signal pre_sel: std_logic;
signal pre_data:std_logic_vector(15 downto 0);

type t_pre_state is(T_IDLE,T_START,T_DATA,T_WAIT,T_EVEN,T_ODD);
signal pre_state : t_pre_state;

signal post_eof : std_logic;  
signal post_sel,post_type: std_logic;
signal post_data:std_logic_vector(15 downto 0);

type t_post_state is(T_IDLE,T_SEND_STATUS,T_SEND_START,T_SEND_DATA,T_WAIT_LAST,T_CLR_FIFO);
signal post_state : t_post_state;

--component chipscope_ila
--port (
--    CONTROL : inout std_logic_vector(35 downto 0);
--    CLK     : in    std_logic;
--    TRIG0   : in    std_logic_vector(31 downto 0);
--    TRIG1   : in    std_logic_vector(31 downto 0);
--    TRIG2   : in    std_logic_vector(31 downto 0);
--    TRIG3   : in    std_logic_vector(31 downto 0)
--);
--end component;

--component chipscope_icon
--port (
--    CONTROL0 : inout std_logic_vector (35 downto 0));
--end component;

--signal CONTROL : std_logic_vector(35 downto 0);
--signal CLK     : std_logic;
--signal TRIG0   : std_logic_vector(31 downto 0);
--signal TRIG1   : std_logic_vector(31 downto 0);
--signal TRIG2   : std_logic_vector(31 downto 0);
--signal TRIG3   : std_logic_vector(31 downto 0);

begin

tx_data:process(clk_wr)
begin
if rising_edge(clk_wr) then
    if rst_n_i='0' then
        pre_state   <= T_IDLE;
        pre_eof     <='0';         
        pre_sel     <='0';
        pre_data    <=(others=>'0');
        fifo_wrreq  <='0';
    else
        pre_data  <= pre_data(7 downto 0) & data_i;

        case( pre_state ) is
        
        when T_IDLE=>
            pre_eof     <='0';                    
            pre_sel     <='0';
            fifo_wrreq  <='0';                    

            if(data_valid_i='1') then
                pre_state <= T_START;
            else
                pre_state <= T_IDLE;
            end if;

        when T_START=>
            if(data_valid_i='1') then
                pre_eof   <='0';
                pre_sel   <='0';
                fifo_wrreq<='1';
                pre_state <= T_DATA;
            else
                pre_state <= T_IDLE;
            end if;

        when T_DATA=>
            if(data_valid_i='1') then
                pre_eof   <='0';
                pre_sel   <='0';
                fifo_wrreq<= not fifo_wrreq;
                
                if(eof_i='1') then
                    pre_eof<='1';

                    if(fifo_wrreq='0') then
                        pre_state <= T_EVEN;
                    else
                        pre_state <= T_ODD;
                    end if;
                else
                    pre_state <= T_DATA;
                end if;
            else
                pre_state <= T_IDLE;
            end if;

        when T_EVEN=>
            fifo_wrreq<= not fifo_wrreq;
            pre_eof   <='0';
            pre_sel   <='0';            
            pre_state <= T_IDLE;

        when T_ODD=>
            fifo_wrreq<= not fifo_wrreq;
            pre_sel   <='1';
            pre_eof   <='1';
            pre_state <=T_IDLE;

        when others =>
            pre_state <=T_IDLE;           
        end case ;
    end if;
end if;
end process;

fifo_wrdata <= pre_eof & pre_sel & pre_data;

post_eof    <= fifo_rddata(17);
post_sel    <= fifo_rddata(16);
post_data   <= fifo_rddata(15 downto 0);

stall       <= src_i.stall;
ack         <= src_i.ack;
err         <= src_i.err;
rty         <= src_i.rty;

src_o       <= src_out;
src_out.dat <= post_data when post_type = '1' else
               (others=>'0');
src_out.sel <= "10" when post_sel='1' and post_type ='1'  else
               "11";

cts_o <= not fifo_wr_almost_full;

tx_fsm : process( clk_rd )
begin
if rising_edge(clk_rd) then
    if rst_n_i='0' then
        fifo_rdreq  <='0';
        src_out.cyc <= '0';
        src_out.stb <= '0';
        src_out.adr <=(others=>'0');
        src_out.we  <= '1';      
        post_type   <='0';
    else
        case( post_state ) is

        when T_IDLE =>
            src_out.cyc <= '0';
            src_out.stb <= '0';
            src_out.we  <= '1';
            src_out.adr <= (others => '0');
            post_type   <='0';

            if fifo_empty='0' then
                fifo_rdreq <='1';
                post_state <= T_SEND_STATUS;
            end if ;
      
        when T_SEND_STATUS =>
            src_out.stb <= '1';
            src_out.cyc <= '1';
            src_out.adr <= c_WRF_STATUS;
            post_type   <='0';
            fifo_rdreq  <='0';
            post_state  <= T_SEND_START;
        
        when T_SEND_START =>
            if stall = '0' then
                src_out.adr <= c_WRF_DATA;                 
                post_type   <='1';
                fifo_rdreq  <= '1';
                post_state  <= T_SEND_DATA;
            end if;

        when T_SEND_DATA =>
            if stall = '0' then

                if fifo_empty='0' then
                    fifo_rdreq <='1';
                else
                    fifo_rdreq <='0';
                    post_state <= T_IDLE;
                end if;

                if post_eof='1' then
                    post_state <= T_WAIT_LAST;
                end if ;
            else
                fifo_rdreq <='0';
            end if;
            
            if err = '1' then
                post_state <= T_WAIT_LAST;
            end if; 

        when T_WAIT_LAST=>
            src_out.stb <= '0';
            src_out.cyc <= '0';

            if fifo_empty='0' then
                fifo_rdreq <='1';            
                post_state  <= T_CLR_FIFO;
            else
                fifo_rdreq  <='0';
                post_state <= T_IDLE;
            end if;

        when T_CLR_FIFO=>
            
            if fifo_empty='0' then
                fifo_rdreq <='1';
            else
                fifo_rdreq <='0';            
                post_state <=T_IDLE;
            end if ;

        when others =>
            post_state <= T_IDLE;

        end case ;
    end if ;
end if ;
end process ; 



U_tcp_tx_fifo : generic_async_fifo
generic map (
    g_data_width             => c_fifo_width,
    g_size                   => 256,
    g_with_rd_empty          => true,
    g_with_rd_almost_empty   => false,
    g_with_rd_count          => false,
    g_with_wr_almost_full    => true,
    g_almost_empty_threshold => 8,
    g_almost_full_threshold  => 240
)
port map (
    rst_n_i           => rst_n_i,
    clk_wr_i          => clk_wr,
    d_i               => fifo_wrdata,
    we_i              => fifo_wrreq,
    wr_empty_o        => open,
    wr_full_o         => open,
    wr_almost_empty_o => open,
    wr_almost_full_o  => fifo_wr_almost_full,
    wr_count_o        => open,
    clk_rd_i          => clk_rd,
    q_o               => fifo_rddata,
    rd_i              => fifo_rdreq,
    rd_empty_o        => fifo_empty,
    rd_full_o         => open,
    rd_almost_empty_o => open,
    rd_almost_full_o  => open,
    rd_count_o        => open
);

--   chipscope_ila_1 : chipscope_ila
--     port map (
--       CONTROL => CONTROL,
--       CLK     => clk_wr,
--       TRIG0   => TRIG0,
--       TRIG1   => TRIG1,
--       TRIG2   => TRIG2,
--       TRIG3   => TRIG3);
--
--   chipscope_icon_1 : chipscope_icon
--     port map (
--       CONTROL0 => CONTROL);
--
--   trig0(7 downto 0)  <= data_i;
--   trig0(8)  <= data_valid_i;
--   trig0(9)  <= eof_i;
--   trig0(31 downto 16) <= pre_data;
--
--   trig1(15 downto 0)  <= src_out.dat;
--   trig1(16)  <= src_out.cyc;
--   trig1(17)  <= src_out.stb;
--   trig1(19 downto 18)  <= src_out.sel;
--   trig1(21 downto 20) <= src_out.adr;
--   trig1(22) <=stall;
--   trig1(23) <=ack;
--  
--   trig2(17 downto 0) <= fifo_rddata;
--   trig2(18) <= fifo_empty;
--   trig2(19) <= fifo_rdreq;
--
--   trig3(17 downto 0) <= fifo_wrdata;
--   trig3(18)<= fifo_wrreq;

end behavioral;
