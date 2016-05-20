library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity user_udp_demo is
port(
	clk_i 				   	      : in std_logic;
	rst_n_i 					      : in std_logic;

	udp_rx_data         		: in std_logic_vector(7 downto 0);
	udp_rx_data_valid   		: in std_logic;
	udp_rx_sof          		: in std_logic;
	udp_rx_eof          		: in std_logic;

	udp_tx_data         		: out std_logic_vector(7 downto 0);
	udp_tx_data_valid   		: out std_logic;
	udp_tx_sof          		: out std_logic;
	udp_tx_eof          		: out std_logic;
	udp_tx_cts          		: in std_logic;
	udp_tx_ack          		: in std_logic;
	udp_tx_nak          		: in std_logic;
	udp_tx_dest_ip_addr			: out std_logic_vector(127 downto 0);
	udp_tx_dest_port_no			: out std_logic_vector(15 downto 0)
);
end entity;

architecture beha of user_udp_demo is

  type t_tx_state is(T_IDLE,T_START,T_DATA,T_WAIT);
  signal tx_state : t_tx_state;

  signal tx_cnt : integer;
  signal wt_cnt : integer;
  signal rx_data: std_logic_vector(7 downto 0);
  signal tx_data: std_logic_vector(7 downto 0);
  signal tx_sof: std_logic;
  signal tx_eof: std_logic;
  signal tx_data_valid:std_logic;

begin

udp_tx_dest_ip_addr <= x"000000000000000000000000C0A80001";
udp_tx_dest_port_no <= x"1234";
udp_tx_data <= tx_data;
udp_tx_sof <= tx_sof;
udp_tx_eof <= tx_eof;
udp_tx_data_valid <= tx_data_valid;

U_udp_tx_demo : process( clk_i )
begin
    if rising_edge(clk_i) then
        if rst_n_i = '0' then
            tx_sof        <= '0';
            tx_eof        <= '0';
            tx_data_valid <= '0';
            tx_data       <= (others=>'0');
            rx_data       <= (others=>'0');
            tx_cnt        <= 1024;
            wt_cnt        <= 0;
            tx_state  <= T_IDLE;
        else
            case( tx_state ) is
                when T_IDLE =>
                    wt_cnt        <= 0;
                    tx_sof        <= '0';
                    tx_eof        <= '0';
                    tx_data_valid <= '0';
                    tx_data <= (others=>'0');
                    rx_data <= (others=>'0');
                    if (udp_rx_data_valid = '1') and (udp_tx_cts = '1') then
                        tx_state <= T_START;
                        tx_cnt   <= tx_cnt+1;
                        rx_data  <= udp_rx_data;
                    end if ;

                when T_START =>
                    wt_cnt        <= 0;
                    tx_sof        <= '1';
                    tx_eof        <= '0';
                    tx_data_valid <= '1';
                    tx_data <= rx_data + 1;
                    tx_state <= T_DATA;

                when T_DATA =>
                    tx_sof        <= '0';
                    tx_eof        <= '0';
                    tx_data_valid <= '1';
                    tx_data       <= rx_data + wt_cnt;
                    wt_cnt        <= wt_cnt + 1;
                    if ( wt_cnt > tx_cnt ) then
                        tx_state  <= T_WAIT;
                        tx_eof    <= '1';
                        wt_cnt    <= 0;
                    end if;

                when T_WAIT =>
                    wt_cnt        <= 0;
                    rx_data       <= (others=>'0');
                    tx_sof        <= '0';
                    tx_eof        <= '0';
                    tx_data_valid <= '0';
                    tx_data       <= (others=>'0');
                    tx_state      <= T_IDLE;

                when others =>
                    tx_state <= T_IDLE;

            end case ;
        end if ;
    end if ;
end process ;

end beha;
