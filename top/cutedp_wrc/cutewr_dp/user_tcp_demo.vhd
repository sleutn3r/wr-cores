-------------------------------------------------------------------------------
-- Title      : Demo for TCP transmitting & receiving with cutewr-tcp
-- Project    : 
-------------------------------------------------------------------------------
-- File       : user_tcp_demo.vhd
-- Author     : lihm
-- Company    : Tsinghua
-- Created    : 2016-03-11
-- Last update: 2016-03-11
-- Platform   : Xilinx Spartan 6
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: A simple demo for TCP transmitting and receiving. 
-- Usage: Send me a normal tcp connect request from ip_address:8000. Then I 
-- will send out tcp frame as much as possible.
-------------------------------------------------------------------------------
--
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-03-11  1.0      lihm            Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity user_tcp_demo is
port (
  clk_i : in std_logic;
  rst_n_i: in std_logic;
  tcp_rx_data: in std_logic_vector(7 downto 0);
  tcp_rx_data_valid:in std_logic;
  tcp_tx_data: out std_logic_vector(7 downto 0);
  tcp_tx_data_valid:out std_logic;
  tcp_tx_cts: in std_logic;
  tcp_rx_rts: in std_logic) ;
end entity ; -- user_tcp_demo

architecture behavioral of user_tcp_demo is

  signal tcp_data:std_logic_vector(7 downto 0);
  signal tcp_data_valid:std_logic;

  type t_tx_state is(T_IDLE,T_START,T_DATA,T_END);
  signal tx_state : t_tx_state;

begin

  tcp_tx_data_valid <= tcp_data_valid;
  tcp_tx_data <= tcp_data;

U_tcp_tx_demo : process( clk_i )
begin
  if rising_edge(clk_i) then
    if rst_n_i = '0' then
      tcp_data_valid <= '0';
      tcp_data   <= (others=>'0');
      tx_state <= T_IDLE;			
    else
      case( tx_state ) is
        when T_IDLE =>
          tcp_data_valid <= '0';
          tcp_data <= (others=>'0');
          if tcp_rx_data_valid = '1' and tcp_tx_cts = '1' then
            tx_state<= T_START;
            tcp_data_valid <= '1';
            tcp_data <= tcp_rx_data;
          end if ;
			  
				when T_START =>
            tcp_data       <= tcp_rx_data;
            tcp_data_valid <= '1';
            if tcp_rx_data_valid = '0' then
              tx_state <= T_END;
              tcp_data_valid <= '0';
              tcp_data       <= (others=>'0');
            end if ;
        
				when T_END =>
            tcp_data_valid <= '0';
            tcp_data   <= (others=>'0');
            tx_state <= T_IDLE;
        
				when others =>
            tx_state <= T_IDLE;
      end case ;
    end if ;
  end if ;
end process ; -- U_tcp_tx_demo

end behavioral;
