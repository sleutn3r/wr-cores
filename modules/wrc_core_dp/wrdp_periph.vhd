-------------------------------------------------------------------------------
-- Title      : WhiteRabbit PTP Core peripherials
-- Project    : WhiteRabbit
-------------------------------------------------------------------------------
-- File       : wrdp_periph.vhd
-- Author     : hongming
-- Company    : tsinghua
-- Created    : 2016-03-30
-- Last update: 2016-03-30
-- Platform   : FPGA-generics
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- WRC_DP_PERIPH integrates WRC_SYSCON, UART/VUART, 1-Wire Master
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 hongming
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-03-30  1.0      hongming          Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wrdp_pkg.all;
use work.wishbone_pkg.all;
use work.syscdp_wbgen2_pkg.all;

entity wrdp_periph is
  generic(
    g_phys_uart       : boolean := true;
    g_virtual_uart    : boolean := false;
    g_cntr_period     : integer := 62500;
    g_mem_words       : integer := 16384;   --in 32-bit words
    g_vuart_fifo_size : integer := 1024
    );
  port(
    clk_sys_i    : in std_logic;
    rst_n_i      : in std_logic;

    rst_net_n_o  : out std_logic;
    rst_wrc_n_o  : out std_logic;

    led_link_o   : out std_logic;
    led_stat_o   : out std_logic;
    fpga_scl_o   : out std_logic;
    fpga_scl_i   : in  std_logic;
    fpga_sda_o   : out std_logic;
    fpga_sda_i   : in  std_logic;

    sfp0_scl_o   : out std_logic;
    sfp0_scl_i   : in  std_logic;
    sfp0_sda_o   : out std_logic;
    sfp0_sda_i   : in  std_logic;
    sfp0_det_i   : in  std_logic;

    sfp1_scl_o   : out std_logic;
    sfp1_scl_i   : in  std_logic;
    sfp1_sda_o   : out std_logic;
    sfp1_sda_i   : in  std_logic;
    sfp1_det_i   : in  std_logic;
    memsize_i    : in  std_logic_vector(3 downto 0);
    spi_sclk_o   : out std_logic;
    spi_ncs_o    : out std_logic;
    spi_mosi_o   : out std_logic;
    spi_miso_i   : in  std_logic;

    slave_i : in  t_wishbone_slave_in_array(0 to 2);
    slave_o : out t_wishbone_slave_out_array(0 to 2);

    uart_rxd_i : in  std_logic;
    uart_txd_o : out std_logic;

    -- 1-Wire
    owr_pwren_o: out std_logic_vector(1 downto 0);
    owr_en_o : out std_logic_vector(1 downto 0);
    owr_i    : in  std_logic_vector(1 downto 0)
    );
end wrdp_periph;

architecture struct of wrdp_periph is

  function f_cnt_memsize(words : integer) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(words * 4 / 1024 / 16 - 1, 4));
    -- *4     - to get size in bytes
    -- /1024  - to get size in kB
    -- /16 -1 - to get size in format of MEMSIZE@sysc_hwfr register
  end f_cnt_memsize;

  signal sysc_regs_i : t_syscdp_in_registers;
  signal sysc_regs_o : t_syscdp_out_registers;

  signal cntr_div      : unsigned(23 downto 0);
  signal cntr_tics     : unsigned(31 downto 0);
  signal cntr_overflow : std_logic;
  
  signal rst_wrc_n_o_reg : std_logic := '1';

begin

  rst_wrc_n_o <= rst_n_i and rst_wrc_n_o_reg;
  process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if(rst_n_i = '0') then
        rst_net_n_o <= '0';
        rst_wrc_n_o_reg <= '1';
      else

        if(sysc_regs_o.rstr_trig_wr_o = '1' and sysc_regs_o.rstr_trig_o = x"deadbee") then
          rst_wrc_n_o_reg <= not sysc_regs_o.rstr_rst_o;
        end if; 
            
        rst_net_n_o <= not sysc_regs_o.gpsr_net_rst_o;
      end if; 
    end if; 
  end process;
  
  -------------------------------------
  -- LEDs
  -------------------------------------
  process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if(sysc_regs_o.gpsr_led_link_o = '1') then
        led_link_o <= '1';
      elsif(sysc_regs_o.gpcr_led_link_o = '1') then
        led_link_o <= '0';
      end if;

      if(sysc_regs_o.gpsr_led_stat_o = '1') then
        led_stat_o <= '1';
      elsif(sysc_regs_o.gpcr_led_stat_o = '1') then
        led_stat_o <= '0';
      end if;
    end if;
  end process;

  -------------------------------------
  -- MEMSIZE
  -------------------------------------
  sysc_regs_i.hwfr_memsize_i(3 downto 0) <= f_cnt_memsize(g_mem_words);

  -------------------------------------
  -- TIMER
  -------------------------------------
  sysc_regs_i.tvr_i <= std_logic_vector(cntr_tics);

  process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if(rst_n_i = '0') then
        cntr_div      <= (others => '0');
        cntr_overflow <= '0';
      elsif(sysc_regs_o.tcr_enable_o = '1') then
        if(cntr_div = g_cntr_period-1) then
          cntr_div      <= (others => '0');
          cntr_overflow <= '1';
        else
          cntr_div      <= cntr_div + 1;
          cntr_overflow <= '0';
        end if;
      end if;
    end if;
  end process;

  --msec counter
  process(clk_sys_i)
  begin
    if(rising_edge(clk_sys_i)) then
      if(rst_n_i = '0') then
        cntr_tics <= (others => '0');
      elsif(cntr_overflow = '1') then
        cntr_tics <= cntr_tics + 1;
      end if;
    end if;
  end process;

  -------------------------------------
  -- I2C - FMC
  -------------------------------------
  p_drive_i2c : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_n_i = '0' then
        fpga_scl_o <= '1';
        fpga_sda_o <= '1';
      else
        if(sysc_regs_o.gpsr_fmc_sda_load_o = '1' and sysc_regs_o.gpsr_fmc_sda_o = '1') then
          fpga_sda_o <= '1';
        elsif(sysc_regs_o.gpcr_fmc_sda_o = '1') then
          fpga_sda_o <= '0';
        end if;

        if(sysc_regs_o.gpsr_fmc_scl_load_o = '1' and sysc_regs_o.gpsr_fmc_scl_o = '1') then
          fpga_scl_o <= '1';
        elsif(sysc_regs_o.gpcr_fmc_scl_o = '1') then
          fpga_scl_o <= '0';
        end if;
      end if;
    end if;
  end process;

  sysc_regs_i.gpsr_fmc_sda_i <= fpga_sda_i;
  sysc_regs_i.gpsr_fmc_scl_i <= fpga_scl_i;

  -------------------------------------
  -- I2C - SFP0
  -------------------------------------
  p_drive_sfp0i2c : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_n_i = '0' then
        sfp0_scl_o <= '1';
        sfp0_sda_o <= '1';
      else
        if(sysc_regs_o.gpsr_sfp0_sda_load_o = '1' and sysc_regs_o.gpsr_sfp0_sda_o = '1') then
          sfp0_sda_o <= '1';
        elsif(sysc_regs_o.gpcr_sfp0_sda_o = '1') then
          sfp0_sda_o <= '0';
        end if;

        if(sysc_regs_o.gpsr_sfp0_scl_load_o = '1' and sysc_regs_o.gpsr_sfp0_scl_o = '1') then
          sfp0_scl_o <= '1';
        elsif(sysc_regs_o.gpcr_sfp0_scl_o = '1') then
          sfp0_scl_o <= '0';
        end if;
      end if;
    end if;
  end process;

  sysc_regs_i.gpsr_sfp0_sda_i <= sfp0_sda_i;
  sysc_regs_i.gpsr_sfp0_scl_i <= sfp0_scl_i;

  sysc_regs_i.gpsr_sfp0_det_i <= sfp0_det_i;

  -------------------------------------
  -- I2C - SFP1
  -------------------------------------
  p_drive_sfp1i2c : process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_n_i = '0' then
        sfp1_scl_o <= '1';
        sfp1_sda_o <= '1';
      else
        if(sysc_regs_o.gpsr_sfp1_sda_load_o = '1' and sysc_regs_o.gpsr_sfp1_sda_o = '1') then
          sfp1_sda_o <= '1';
        elsif(sysc_regs_o.gpcr_sfp1_sda_o = '1') then
          sfp1_sda_o <= '0';
        end if;

        if(sysc_regs_o.gpsr_sfp1_scl_load_o = '1' and sysc_regs_o.gpsr_sfp1_scl_o = '1') then
          sfp1_scl_o <= '1';
        elsif(sysc_regs_o.gpcr_sfp1_scl_o = '1') then
          sfp1_scl_o <= '0';
        end if;
      end if;
    end if;
  end process;

  sysc_regs_i.gpsr_sfp1_sda_i <= sfp1_sda_i;
  sysc_regs_i.gpsr_sfp1_scl_i <= sfp1_scl_i;

  sysc_regs_i.gpsr_sfp1_det_i <= sfp1_det_i;

  -------------------------------------
  -- SPI - Flash
  -------------------------------------
  p_drive_spi: process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_n_i = '0' then
        spi_sclk_o  <= '0';
        spi_mosi_o  <= '0';
        spi_ncs_o   <= '1';
      else
        if(sysc_regs_o.gpsr_spi_sclk_load_o = '1' and sysc_regs_o.gpsr_spi_sclk_o = '1') then
          spi_sclk_o <= '1';
        elsif(sysc_regs_o.gpcr_spi_sclk_o = '1') then
          spi_sclk_o <= '0';
        end if;

        if(sysc_regs_o.gpsr_spi_ncs_load_o = '1' and sysc_regs_o.gpsr_spi_ncs_o = '1') then
          spi_ncs_o <= '1';
        elsif(sysc_regs_o.gpcr_spi_cs_o = '1') then
          spi_ncs_o <= '0';
        end if;

        if(sysc_regs_o.gpsr_spi_mosi_load_o = '1' and sysc_regs_o.gpsr_spi_mosi_o = '1') then
          spi_mosi_o <= '1';
        elsif(sysc_regs_o.gpcr_spi_mosi_o = '1') then
          spi_mosi_o <= '0';
        end if;
      end if;
    end if;
  end process;
  sysc_regs_i.gpsr_spi_sclk_i <= '0';
  sysc_regs_i.gpsr_spi_ncs_i  <= '0';
  sysc_regs_i.gpsr_spi_mosi_i <= '0';
  sysc_regs_i.gpsr_spi_miso_i <= spi_miso_i;

  ----------------------------------------
  -- SYSCON
  ----------------------------------------
  SYSCON : xwrdp_syscon_wb
    generic map(
      g_interface_mode      => PIPELINED,
      g_address_granularity => BYTE
      )
    port map(
      rst_n_i   => rst_n_i,
      clk_sys_i => clk_sys_i,

      slave_i => slave_i(0),
      slave_o => slave_o(0),

      regs_i => sysc_regs_i,
      regs_o => sysc_regs_o
      );

  --------------------------------------
  -- UART
  --------------------------------------
  UART : xwb_simple_uart
    generic map(
      g_with_virtual_uart   => g_virtual_uart,
      g_with_physical_uart  => g_phys_uart,
      g_interface_mode      => PIPELINED,
      g_address_granularity => BYTE,
      g_vuart_fifo_size     => g_vuart_fifo_size
      )
    port map(
      clk_sys_i => clk_sys_i,
      rst_n_i   => rst_n_i,

      -- Wishbone
      slave_i => slave_i(1),
      slave_o => slave_o(1),
      desc_o  => open,

      uart_rxd_i => uart_rxd_i,
      uart_txd_o => uart_txd_o
      );

  --------------------------------------
  -- 1-WIRE
  --------------------------------------
  ONEWIRE : xwb_onewire_master
    generic map(
      g_interface_mode      => PIPELINED,
      g_address_granularity => BYTE,
      g_num_ports           => 2,
      g_ow_btp_normal       => "5.0",
      g_ow_btp_overdrive    => "1.0"
      )
    port map(
      clk_sys_i => clk_sys_i,
      rst_n_i   => rst_n_i,

      -- Wishbone
      slave_i => slave_i(2),
      slave_o => slave_o(2),
      desc_o  => open,

      owr_pwren_o => owr_pwren_o,
      owr_en_o => owr_en_o,
      owr_i    => owr_i
      );

end struct;
