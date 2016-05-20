library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.tdcpkg.all;
use work.tdc_general_pkg.all;

entity tdc_read is
generic(
    g_tdc_buf_data_width : integer := 8;
    g_tdc_buf_size       : integer := 2045;
    g_tdc_buf_ready_threshold: integer := 1024
);
port (
    clk_ref_i   : in std_logic;
    rst_n_i     : in std_logic;

    tdc_buf_rdreq_o   : out std_logic;
    tdc_buf_rddata_i  : in  std_logic_vector(g_tdc_buf_data_width-1 downto 0);
    tdc_buf_rdusedw_i : in std_logic_vector(f_log2_size(g_tdc_buf_size)-1 downto 0);

    udp_rx_data_valid       : in  std_logic;
    udp_tx_data         		: out std_logic_vector(7 downto 0);
  	udp_tx_data_valid   		: out std_logic;
  	udp_tx_sof          		: out std_logic;
  	udp_tx_eof          		: out std_logic;
  	udp_tx_cts          		: in std_logic;
  	udp_tx_ack          		: in std_logic;
  	udp_tx_nak          		: in std_logic;
  	udp_tx_dest_ip_addr			: out std_logic_vector(127 downto 0);
  	udp_tx_dest_port_no			: out std_logic_vector(15 downto 0)
) ;
end entity ; -- tdc_read

architecture arch of tdc_read is

    type t_tx_state is (s_idle, s_start,s_data1,s_data2,s_data3,s_data4);
    signal tx_state : t_tx_state;

    signal tx_cnt: integer range 0 to 2047;
    signal tx_data: std_logic_vector(7 downto 0);
    signal tx_sof: std_logic;
    signal tx_eof: std_logic;
    signal tx_data_valid:std_logic;

begin

  udp_tx_dest_ip_addr <= x"000000000000000000000000C0A80001";
  udp_tx_dest_port_no <= x"8234";
  udp_tx_data <= tx_data;
  udp_tx_sof <= tx_sof;
  udp_tx_eof <= tx_eof;
  udp_tx_data_valid <= tx_data_valid;

p_tdc_tx : process( clk_ref_i )
begin
    if rising_edge(clk_ref_i) then
        if rst_n_i = '0' then
            tx_sof          <= '0';
            tx_eof          <= '0';
            tx_data_valid   <= '0';
            tx_data         <= (others=>'0');
            tx_cnt          <=  0 ;
            tdc_buf_rdreq_o <= '0';
            tx_state        <= s_idle;
        else
            case( tx_state ) is

								when s_idle =>
                    tx_sof          <= '0';
                    tx_eof          <= '0';
                    tx_data_valid   <= '0';
                    tx_data         <= (others=>'0');
                    tdc_buf_rdreq_o <= '0';
                    tx_cnt          <=  0 ;

                    if (tdc_buf_rdusedw_i > g_tdc_buf_ready_threshold) and ( udp_tx_cts = '1') then
                        tx_cnt          <= g_tdc_buf_ready_threshold-1;
                        tdc_buf_rdreq_o <= '1';
                        tx_state        <= s_start;
                    end if ;

                when s_start =>
                    tdc_buf_rdreq_o <= '0';
                    tx_sof          <= '1';
                    tx_eof          <= '0';
                    tx_data_valid   <= '1';
                    tx_data         <= tdc_buf_rddata_i(31 downto 24);
                    tx_state        <= s_data2;

                when s_data1  =>
                    tdc_buf_rdreq_o <= '0';
                    tx_sof          <= '0';
                    tx_eof          <= '0';
                    tx_data_valid   <= '1';
                    tx_data         <= tdc_buf_rddata_i(31 downto 24);
                    tx_state        <= s_data2;

                when s_data2  =>
                    tdc_buf_rdreq_o <= '0';
                    tx_sof          <= '0';
                    tx_eof          <= '0';
                    tx_data_valid   <= '1';
                    tx_data         <= tdc_buf_rddata_i(23 downto 16);
                    tx_state        <= s_data3;

                when s_data3  =>
                    tdc_buf_rdreq_o <= '0';
                    tx_sof          <= '0';
                    tx_eof          <= '0';
                    tx_data_valid   <= '1';
                    tx_data         <= tdc_buf_rddata_i(15 downto 8);
                    tx_state        <= s_data4;

                when s_data4  =>
                    tdc_buf_rdreq_o <= '1';
                    tx_sof          <= '0';
                    tx_eof          <= '0';
                    tx_data_valid   <= '1';
                    tx_data         <= tdc_buf_rddata_i(7 downto 0);
                    if tx_cnt > 0 then
                        tx_cnt          <=  tx_cnt - 1 ;
                        tx_state        <= s_data1;
                    else
                        tx_eof          <= '1';
                        tx_state        <= s_idle;
                    end if;

                when others =>
                    tx_state <= s_idle;
            end case ;
        end if ;
    end if ;
end process ; -- p_tdc_tx

end architecture ; -- arch
