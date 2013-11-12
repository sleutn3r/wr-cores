library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity trig_delay is
  
  generic (
    g_length : integer := 64);

  port (
    d_i : in  std_logic;
    q_o : out std_logic;

    clk_i   : in std_logic;
    rst_n_i : in std_logic;

    sr_rst_i : in std_logic;
    sr_d_i   : in std_logic;
    sr_en_i  : in std_logic
    );

end trig_delay;

architecture rtl of trig_delay is

  component LUT6
    generic (
      INIT : bit_vector);
    port (
      O  : out std_ulogic;
      I0 : in  std_ulogic;
      I1 : in  std_ulogic;
      I2 : in  std_ulogic;
      I3 : in  std_ulogic;
      I4 : in  std_ulogic;
      I5 : in  std_ulogic);
  end component;

  signal dly, dly_d     : std_logic_vector(g_length downto 0);
  signal sel_reg : std_logic_vector(g_length-1 downto 0);
  signal en_d0   : std_logic;
  
begin  -- rtl


  gen_dl : for i in 0 to g_length-1 generate

    LUT6_1 : LUT6
      generic map (
        INIT => x"00000000000000d8")
      port map (
        O  => dly(i+1),
        I0 => sel_reg(i),
        I1 => dly(i),
        I2 => d_i,
        I3 => '0',
        I4 => '0',
        I5 => '0');

--    dly(i+1) <= transport dly_d(i+1) after 100ps; 

  end generate gen_dl;

  dly(0) <= d_i;
  q_o    <= dly(g_length);

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' or sr_rst_i = '1' then
        sel_reg <= (others => '0');
        en_d0   <= '0';
      else
        if(sr_en_i = '1' and en_d0 = '0') then
          sel_reg <= sel_reg(sel_reg'length-2 downto 0) & sr_d_i;
        end if;
        en_d0 <= sr_en_i;
      end if;
    end if;
  end process;
  

end rtl;
