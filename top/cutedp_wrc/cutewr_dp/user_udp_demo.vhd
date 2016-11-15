library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.genram_pkg.all;
use work.memory_loader_pkg.all;

entity user_udp_demo is
port(
	clk_i 				   	      : in std_logic;
	rst_n_i 					      : in std_logic;

  fifo_wrreq_i            : in std_logic;
	fifo_wrdata_i           : in std_logic_vector(31 downto 0);
	
	udp_rx_data         		: in std_logic_vector(7 downto 0):=(others=>'0');
	udp_rx_data_valid   		: in std_logic:='0';
	udp_rx_sof          		: in std_logic:='0';
	udp_rx_eof          		: in std_logic:='0';

	udp_tx_data         		: out std_logic_vector(7 downto 0);
	udp_tx_data_valid   		: out std_logic;
	udp_tx_sof          		: out std_logic;
	udp_tx_eof          		: out std_logic;
	udp_tx_cts          		: in std_logic;
	udp_tx_ack          		: in std_logic:='0';
	udp_tx_nak          		: in std_logic:='0'
);
end entity;

architecture beha of user_udp_demo is
  	
  type t_tx_state is(T_IDLE,T_WAIT,T_START,T_DATA,T_END);
  signal tx_state : t_tx_state;
  
	signal fifo_wrreq:std_logic;
	signal fifo_rdreq:std_logic;
	signal fifo_almost_full: std_logic;
	signal fifo_full:std_logic;
	signal fifo_empty: std_logic;
	signal fifo_wrdata:std_logic_vector(31 downto 0);
	signal fifo_rddata:std_logic_vector(31 downto 0);
	signal rddata :std_logic_vector(31 downto 0);
	
	signal word_cnt: integer range 0 to 3 :=0;
	signal tx_cnt: integer range 0 to 511 :=0;
	
begin

fifo_wrreq <= fifo_wrreq_i and not fifo_full;
fifo_wrdata <= fifo_wrdata_i;

U_udp_fifo : generic_sync_fifo
generic map(
    g_data_width             => 32,
    g_size                   => 2048,
    g_with_empty             => true,
    g_with_full              => true,
    g_with_almost_full       => true,
    g_almost_full_threshold  => 256)
port map(
    rst_n_i        => rst_n_i,
    clk_i          => clk_i,
    d_i            => fifo_wrdata,
    we_i           => fifo_wrreq,
    q_o            => fifo_rddata,
    rd_i           => fifo_rdreq,
    empty_o        => fifo_empty,
    full_o         => fifo_full,
    almost_full_o  => fifo_almost_full
);

udp_tx_data <= rddata(31 downto 24);

U_udp_tx : process( clk_i )
begin
    if rising_edge(clk_i) then
        if rst_n_i = '0' then
            udp_tx_sof        <= '0';
            udp_tx_eof        <= '0';
            udp_tx_data_valid <= '0';
            rddata            <= (others=>'0');
						fifo_rdreq        <= '0';
						word_cnt          <= 0;
            tx_state          <= T_IDLE;
						tx_cnt            <= 0;
        else
            case( tx_state ) is
                when T_IDLE =>
                    udp_tx_sof        <= '0';
                    udp_tx_eof        <= '0';
                    udp_tx_data_valid <= '0';
                    rddata            <= (others=>'0');
										word_cnt          <= 0;
                    if (fifo_almost_full = '1' and udp_tx_cts = '1') then
                        tx_state <= T_WAIT;
                        fifo_rdreq <= '1';
                    end if ;
										
                when T_WAIT =>
								    tx_state          <= T_START;
										udp_tx_sof        <= '0';
                    udp_tx_eof        <= '0';
                    udp_tx_data_valid <= '0';
										fifo_rdreq        <= '0';
                    rddata            <= (others=>'0');
										
                when T_START =>
                    udp_tx_sof        <= '1';
                    udp_tx_eof        <= '0';
                    udp_tx_data_valid <= '1';
                    rddata            <= fifo_rddata;
										tx_cnt            <= 350;
										word_cnt          <= 3;
                    tx_state          <= T_DATA;

                when T_DATA =>
                    udp_tx_sof        <= '0';
                    udp_tx_eof        <= '0';
                    udp_tx_data_valid <= '1';
										
										if word_cnt > 1 then
										    rddata            <= rddata(23 downto 0) & x"00";
												word_cnt <= word_cnt - 1;
												fifo_rdreq  <= '0';
										elsif word_cnt = 1 then
										    rddata            <= rddata(23 downto 0) & x"00";
										    word_cnt          <= word_cnt - 1;
												if ( fifo_empty = '1' ) or (tx_cnt = 0) then
														udp_tx_eof    <= '1';
														fifo_rdreq    <= '0';
														tx_state      <= T_END;
														tx_cnt        <= tx_cnt - 1;
                        else
												    fifo_rdreq    <= '1';
                        end if;												
												
										else 
										    rddata <= fifo_rddata;
												fifo_rdreq  <= '0';
												word_cnt <= 3;
										end if;
										
                when T_END =>
                    udp_tx_sof        <= '0';
                    udp_tx_eof        <= '0';
                    udp_tx_data_valid <= '0';
										fifo_rdreq    <= '0';
										tx_cnt <= 0;
										tx_state      <= T_IDLE;
								
								when others =>
								    tx_state <= T_IDLE;
            end case ;
        end if ;
    end if ;
end process ;

end beha;
