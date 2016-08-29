library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.NUMERIC_STD.all;

entity cute_reset_gen is
  
  port (
    clk_sys_i : in std_logic;
    rst_n_o : out std_logic
    );

end cute_reset_gen;

architecture behavioral of cute_reset_gen is

  signal powerup_cnt     : unsigned(7 downto 0) := x"00";
  signal powerup_n       : std_logic            := '0';

begin  -- behavioral

  p_powerup_reset : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if(powerup_cnt /= x"ff") then
        powerup_cnt <= powerup_cnt + 1;
        powerup_n   <= '0';
      else
        powerup_n <= '1';
      end if;
    end if;
  end process;

  rst_n_o <= powerup_n;

end behavioral;
