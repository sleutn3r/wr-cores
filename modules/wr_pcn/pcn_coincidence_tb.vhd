library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pcn_coincidence_tb is

end pcn_coincidence_tb;

architecture behavioral of pcn_coincidence_tb is

  component pcn_coincidence is

    generic(
  -- clock frequency
      g_clk_freq : natural := 62500000;
  -- fifo data width
      g_data_width : natural := 32;
  -- coincidence window, 16 ns * ( 2^g_windows_width -1 )
      g_window_width : natural := 10;
  -- diff data width
      g_diff_width : natural := 18
      );
    port (
      clk_sys_i : in std_logic:='0';
      rst_n_i   : in std_logic:='0';
      
      fifoa_empty_i : in std_logic:='0';
      fifoa_rd_o    : out std_logic;
      fifoa_data_i  : in  std_logic_vector(g_data_width-1 downto 0):=(others=>'0');
      
      fifob_empty_i : in std_logic:='0';
      fifob_rd_o    : out std_logic;
      fifob_data_i  : in  std_logic_vector(g_data_width-1 downto 0):=(others=>'0');

      diff_wr_o   : out std_logic;
      diff_data_o : out std_logic_vector(g_diff_width downto 0);
      diff_full_i : in std_logic
    );

  end component;
  
  constant clk_period:time:= 16 ns;
  constant rst_time: time:= 20 ns;

  signal clk_sys_i:std_logic;
  signal rst_n_i:std_logic;
  signal fifoa_empty_i:std_logic;
  signal fifoa_rd_o:std_logic;
  signal fifoa_data_i:std_logic_vector(15 downto 0);
  signal fifob_empty_i:std_logic;
  signal fifob_rd_o:std_logic;
  signal fifob_data_i:std_logic_vector(15 downto 0);
  signal diff_wr_o:std_logic;
  signal diff_data_o:std_logic_vector(8 downto 0);
  signal diff_full_i:std_logic;

begin
  
  clk_sys_gen : process  -- 62.5MHz
  begin
    clk_sys_i <= '0';
    wait for clk_period/2;
    clk_sys_i <= '1';
    wait for clk_period/2;
  end process;
  
  rst_gen: process
  begin
    rst_n_i <= '0';
    wait for rst_time;
    rst_n_i <= '1';
    wait for 1000 ms;
  end process;

  u_coincidence:pcn_coincidence
  generic map(
    g_data_width => 16,
    g_window_width => 3,
    g_diff_width => 8)
  port map(
    clk_sys_i => clk_sys_i,
    rst_n_i => rst_n_i,
    
    fifoa_empty_i => fifoa_empty_i,
    fifoa_rd_o => fifoa_rd_o,
    fifoa_data_i => fifoa_data_i,
    
    fifob_empty_i => fifob_empty_i,
    fifob_rd_o => fifob_rd_o,
    fifob_data_i => fifob_data_i,

    diff_wr_o => diff_wr_o,
    diff_data_o => diff_data_o,
    diff_full_i => diff_full_i
    );

  fifoa_empty_i <= '0';
  fifob_empty_i <= '0';
  diff_full_i <= '0';

  p_data : process( clk_sys_i )
  begin
    if rising_edge(clk_sys_i) then
      if fifoa_rd_o='1' then
        fifoa_data_i <= x"1114";
      end if ;

      if fifob_rd_o='1' then
        fifob_data_i <= x"1123";
      end if ;    
    end if ;
  end process ; -- p_data
end architecture ; -- behavioral