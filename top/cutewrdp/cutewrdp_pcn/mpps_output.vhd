library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity mpps_output is
  generic(
    g_clk_frequency : natural := 125000000;
		g_mpps_width : natural := 10);
  port (
    clk_i : in std_logic;
    rst_n_i: in std_logic;
    pps_i : in std_logic;

    mpps_o: out std_logic
  ) ;
end entity ; -- mpps_output

architecture behav of mpps_output is
  
  constant m_period : integer := g_clk_frequency / 1000;
  signal pps_d : std_logic;
	signal m_counter : integer range 0 to m_period;
  
begin
  
  pps_latch : process( clk_i )
  begin
    if rising_edge(clk_i) then
      pps_d <= pps_i;
    end if ;
  end process ; -- pps_latch

  p_mpps : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        mpps_o <= '0';
        m_counter <= 0;
      else        
        m_counter <= m_counter + 1;  
        
        if m_counter = m_period -1 then
          m_counter <= 0;
        elsif pps_i = '1' and pps_d = '0' then
          m_counter <= 0;
        end if ;

        if m_counter = m_period -2 then
          mpps_o <= '1';
				elsif m_counter = g_mpps_width-1 then
				  mpps_o <= '0';
        end if ;
      end if ;
    end if ;
  end process ; -- p_mpps

end architecture ; -- behav