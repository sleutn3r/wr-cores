library ieee;
use ieee.std_logic_1164.all;

use work.genram_pkg.all;
use work.endpoint_private_pkg.all;

entity ep_clock_alignment_fifo is

  generic(
    g_size                  : integer := 64;
    g_almostfull_threshold : integer := 56;
    g_early_eof             : boolean := false
    );

  port(
    rst_n_i : in std_logic;

    clk_wr_i : in std_logic;
    clk_rd_i : in std_logic;

    we_i : in std_logic;
    dreq_i: in std_logic;

    fab_i : in  t_ep_internal_fabric;
    fab_o : out t_ep_internal_fabric;

    full_o       : out std_logic;
    empty_o      : out std_logic;
    almostfull_o : out std_logic
    );
end ep_clock_alignment_fifo;

architecture structural of ep_clock_alignment_fifo is
  signal fifo_in   : std_logic_vector(17 downto 0);
  signal fifo_out  : std_logic_vector(17 downto 0);
  signal rx_rdreq  : std_logic;
  signal empty_int : std_logic;
  signal valid_int : std_logic;
  
begin

  fifo_in <= f_pack_fifo_contents (
    fab_i.data,
    fab_i.sof,
    fab_i.eof,
    fab_i.bytesel,
    fab_i.error,
    g_early_eof);

-- Clock adjustment FIFO
  U_FIFO : generic_async_fifo
    generic map (
      g_data_width            => 18,
      g_size                  => g_size,
      g_with_wr_almost_full   => true,
      g_almost_full_threshold => g_almostfull_threshold)

    port map (
      rst_n_i           => rst_n_i,
      clk_wr_i          => clk_wr_i,
      d_i               => fifo_in,
      we_i              => we_i,
      wr_empty_o        => open,
      wr_full_o         => full_o,
      wr_almost_empty_o => open,
      wr_almost_full_o  => almostfull_o,
      wr_count_o        => open,
      clk_rd_i          => clk_rd_i,
      q_o               => fifo_out,
      rd_i              => rx_rdreq,
      rd_empty_o        => empty_int,
      rd_full_o         => open,
      rd_almost_empty_o => open,
      rd_almost_full_o  => open,
      rd_count_o        => open);

  rx_rdreq <= (not empty_int) and dreq_i;

  p_gen_valid : process (clk_rd_i, rst_n_i)
  begin
    if rising_edge(clk_rd_i) then
      if(rst_n_i = '0') then
        valid_int <= '0';
      else
        valid_int <= rx_rdreq;
      end if;
    end if;
  end process;

  -- FIFO output data formatting
  fab_o.sof     <= f_fifo_is_sof(fifo_out, valid_int);
  fab_o.eof     <= f_fifo_is_eof(fifo_out, valid_int);
  fab_o.error   <= f_fifo_is_error(fifo_out, valid_int);
  fab_o.dvalid  <= f_fifo_is_data(fifo_out, valid_int);
  fab_o.bytesel <= f_fifo_is_single_byte(fifo_out, valid_int);
  fab_o.data    <= fifo_out(15 downto 0);

  empty_o <= empty_int;
  
end structural;