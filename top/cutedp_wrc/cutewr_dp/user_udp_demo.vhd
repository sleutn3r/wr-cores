library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.genram_pkg.all;
use work.memory_loader_pkg.all;

entity user_udp_demo is
generic(
  g_meas_channel_num  : integer :=2;
  g_timestamp_width   : integer := 40
  );
port(
	clk_i 				   	      : in std_logic;
	rst_n_i 					      : in std_logic;

  fifo_wrreq_i            : in std_logic_vector(g_meas_channel_num-1 downto 0);
	fifo_wrdata_i           : in std_logic_vector(g_timestamp_width*g_meas_channel_num-1 downto 0);
	
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
  
	signal fifo_wrreq:std_logic_vector(g_meas_channel_num-1 downto 0);
	signal fifo_rdreq:std_logic_vector(g_meas_channel_num-1 downto 0);
	signal fifo_almost_full: std_logic_vector(g_meas_channel_num-1 downto 0);
	signal fifo_full:std_logic_vector(g_meas_channel_num-1 downto 0);
	signal fifo_empty: std_logic_vector(g_meas_channel_num-1 downto 0);
	signal fifo_wrdata:std_logic_vector(g_timestamp_width*g_meas_channel_num-1 downto 0);
	signal fifo_rddata:std_logic_vector(g_timestamp_width*g_meas_channel_num-1 downto 0);
	
  signal rddata :std_logic_vector(g_timestamp_width-1 downto 0);
	
	signal word_cnt: integer range 0 to 15 :=0;
	signal tx_cnt: integer range 0 to 511 :=0;

	constant timestamp_bytes: integer:=g_timestamp_width/8-1;

begin

fifo_wrreq <= fifo_wrreq_i and not fifo_full;
fifo_wrdata <= fifo_wrdata_i;

 gen_TS_FIFO:for i in 0 to g_meas_channel_num-1 generate

  U_TS_fifo : generic_sync_fifo
  generic map(
      g_data_width             => g_timestamp_width,
      g_size                   => 2048,
      g_with_empty             => true,
      g_with_full              => true,
      g_with_almost_full       => true,
      g_almost_full_threshold  => 256)
  port map(
      rst_n_i        => rst_n_i,
      clk_i          => clk_i,
      d_i            => fifo_wrdata(i*g_timestamp_width+g_timestamp_width-1 downto i*g_timestamp_width),
      we_i           => fifo_wrreq(i),
      q_o            => fifo_rddata(i*g_timestamp_width+g_timestamp_width-1 downto i*g_timestamp_width),
      rd_i           => fifo_rdreq(i),
      empty_o        => fifo_empty(i),
      full_o         => fifo_full(i),
      almost_full_o  => fifo_almost_full(i)
  );

end generate ; -- U_TM_FIFO

udp_tx_data <= rddata(rddata'high downto rddata'high-7);

U_udp_tx : process( clk_i )
begin
    if rising_edge(clk_i) then
        if rst_n_i = '0' then
            udp_tx_sof        <= '0';
            udp_tx_eof        <= '0';
            udp_tx_data_valid <= '0';
            rddata            <= (others=>'0');
						fifo_rdreq(0)     <= '0';
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
                    if (fifo_almost_full(0) = '1' and udp_tx_cts = '1') then
                        tx_state <= T_WAIT;
                        fifo_rdreq(0) <= '1';
                    end if ;
										
                when T_WAIT =>
								    tx_state          <= T_START;
										udp_tx_sof        <= '0';
                    udp_tx_eof        <= '0';
                    udp_tx_data_valid <= '0';
										fifo_rdreq(0)     <= '0';
                    rddata            <= (others=>'0');
										
                when T_START =>
                    udp_tx_sof        <= '1';
                    udp_tx_eof        <= '0';
                    udp_tx_data_valid <= '1';
                    rddata            <= fifo_rddata(g_timestamp_width-1 downto 0);
										tx_cnt            <= 256;
										word_cnt          <= timestamp_bytes;
                    tx_state          <= T_DATA;

                when T_DATA =>
                    udp_tx_sof        <= '0';
                    udp_tx_eof        <= '0';
                    udp_tx_data_valid <= '1';
										
										if word_cnt > 1 then
										    rddata            <= rddata(rddata'high-8 downto 0) & x"00";
												word_cnt <= word_cnt - 1;
												fifo_rdreq(0)  <= '0';

										elsif word_cnt = 1 then
										    rddata            <= rddata(rddata'high-8 downto 0) & x"00";
										    word_cnt          <= word_cnt - 1;

												if  tx_cnt = 0 then
														udp_tx_eof    <= '1';
														fifo_rdreq(0)    <= '0';
														tx_state      <= T_END;
                        else
                            fifo_rdreq(0)    <= '1';
                            tx_cnt        <= tx_cnt - 1;
                        end if;												
												
										else 
										    rddata <= fifo_rddata(g_timestamp_width-1 downto 0);
												fifo_rdreq(0)  <= '0';
												word_cnt <= timestamp_bytes;
										end if;
										
                when T_END =>
                    udp_tx_sof        <= '0';
                    udp_tx_eof        <= '0';
                    udp_tx_data_valid <= '0';
										fifo_rdreq(0)    <= '0';
										tx_cnt <= 0;
										tx_state      <= T_IDLE;
								
								when others =>
								    tx_state <= T_IDLE;
            end case ;
        end if ;
    end if ;
end process ;

end beha;
