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

    user_rx_data: in std_logic_vector(7 downto 0);
    user_rx_dvalid:in std_logic;
    user_tx_data: out std_logic_vector(7 downto 0);
    user_tx_dvalid:out std_logic;
    user_tx_cts: in std_logic;
    user_rx_rts: in std_logic
    
  ) ;
end entity ; -- user_tcp_demo

architecture behavioral of user_tcp_demo is

signal user_data:std_logic_vector(7 downto 0);
signal user_dvalid:std_logic;

type t_tx_state is(T_IDLE,T_START,T_DATA,T_WAIT);
signal tx_state : t_tx_state;

begin

user_tx_dvalid <= user_dvalid;
user_tx_data <= user_data;

U_tcp_tx_demo : process( clk_i )
begin
    if rising_edge(clk_i) then
        if rst_n_i = '0' then
            user_dvalid <= '0';
            user_data   <= (others=>'0');
            tx_state <= T_IDLE;			
        else
            case( tx_state ) is
                when T_IDLE =>
                    user_dvalid <= '0';
                    user_data <= (others=>'0');
					if user_rx_dvalid = '1' then
                        tx_state<= T_START;
                    end if ;
                when T_START =>
                    user_dvalid <= '1';
                    user_data <= user_rx_data;
					tx_state <= T_DATA;
                when T_DATA =>
                    user_dvalid <= '1';
                    user_data <= user_data + 1;
					if user_tx_cts = '0' then
                        tx_state<= T_WAIT;
                    end if ;
                when T_WAIT =>
                    user_dvalid <= '0';
                    user_data <= (others=>'0');
                    
					if user_tx_cts = '1' then
                        tx_state<= T_DATA;
                    end if;

                    if user_rx_dvalid = '1' then
                        tx_state <= T_IDLE;
                    end if ;
                when others =>
                    user_dvalid <= '0';
                    user_data <= (others=>'0');
					tx_state <= T_IDLE;
            end case ;
        end if ;
    end if ;
end process ; -- U_tcp_tx_demo

end behavioral;
