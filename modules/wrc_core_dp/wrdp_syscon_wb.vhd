---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for WR Core System Controller
---------------------------------------------------------------------------------------
-- File           : wrdp_syscon_wb.vhd
-- Author         : auto-generated by wbgen2 from wrdp_syscon_wb.wb
-- Created        : Wed Mar 30 13:52:52 2016
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE wrdp_syscon_wb.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.syscdp_wbgen2_pkg.all;


entity wrdp_syscon_wb is
  port (
    rst_n_i                                  : in     std_logic;
    clk_sys_i                                : in     std_logic;
    wb_adr_i                                 : in     std_logic_vector(2 downto 0);
    wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    wb_stall_o                               : out    std_logic;
    regs_i                                   : in     t_syscdp_in_registers;
    regs_o                                   : out    t_syscdp_out_registers
  );
end wrdp_syscon_wb;

architecture syn of wrdp_syscon_wb is

signal syscdp_rstr_rst_int                      : std_logic      ;
signal syscdp_gpsr_led_stat_dly0                : std_logic      ;
signal syscdp_gpsr_led_stat_int                 : std_logic      ;
signal syscdp_gpsr_led_link_dly0                : std_logic      ;
signal syscdp_gpsr_led_link_int                 : std_logic      ;
signal syscdp_gpsr_net_rst_dly0                 : std_logic      ;
signal syscdp_gpsr_net_rst_int                  : std_logic      ;
signal syscdp_gpcr_led_stat_dly0                : std_logic      ;
signal syscdp_gpcr_led_stat_int                 : std_logic      ;
signal syscdp_gpcr_led_link_dly0                : std_logic      ;
signal syscdp_gpcr_led_link_int                 : std_logic      ;
signal syscdp_gpcr_fmc_scl_dly0                 : std_logic      ;
signal syscdp_gpcr_fmc_scl_int                  : std_logic      ;
signal syscdp_gpcr_fmc_sda_dly0                 : std_logic      ;
signal syscdp_gpcr_fmc_sda_int                  : std_logic      ;
signal syscdp_gpcr_sfp0_scl_dly0                : std_logic      ;
signal syscdp_gpcr_sfp0_scl_int                 : std_logic      ;
signal syscdp_gpcr_sfp0_sda_dly0                : std_logic      ;
signal syscdp_gpcr_sfp0_sda_int                 : std_logic      ;
signal syscdp_gpcr_spi_sclk_dly0                : std_logic      ;
signal syscdp_gpcr_spi_sclk_int                 : std_logic      ;
signal syscdp_gpcr_spi_cs_dly0                  : std_logic      ;
signal syscdp_gpcr_spi_cs_int                   : std_logic      ;
signal syscdp_gpcr_spi_mosi_dly0                : std_logic      ;
signal syscdp_gpcr_spi_mosi_int                 : std_logic      ;
signal syscdp_gpcr_sfp1_scl_dly0                : std_logic      ;
signal syscdp_gpcr_sfp1_scl_int                 : std_logic      ;
signal syscdp_gpcr_sfp1_sda_dly0                : std_logic      ;
signal syscdp_gpcr_sfp1_sda_int                 : std_logic      ;
signal syscdp_tcr_enable_int                    : std_logic      ;
signal ack_sreg                                 : std_logic_vector(9 downto 0);
signal rddata_reg                               : std_logic_vector(31 downto 0);
signal wrdata_reg                               : std_logic_vector(31 downto 0);
signal bwsel_reg                                : std_logic_vector(3 downto 0);
signal rwaddr_reg                               : std_logic_vector(2 downto 0);
signal ack_in_progress                          : std_logic      ;
signal wr_int                                   : std_logic      ;
signal rd_int                                   : std_logic      ;
signal allones                                  : std_logic_vector(31 downto 0);
signal allzeros                                 : std_logic_vector(31 downto 0);

begin
-- Some internal signals assignments. For (foreseen) compatibility with other bus standards.
  wrdata_reg <= wb_dat_i;
  bwsel_reg <= wb_sel_i;
  rd_int <= wb_cyc_i and (wb_stb_i and (not wb_we_i));
  wr_int <= wb_cyc_i and (wb_stb_i and wb_we_i);
  allones <= (others => '1');
  allzeros <= (others => '0');
-- 
-- Main register bank access process.
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      ack_sreg <= "0000000000";
      ack_in_progress <= '0';
      rddata_reg <= "00000000000000000000000000000000";
      regs_o.rstr_trig_wr_o <= '0';
      syscdp_rstr_rst_int <= '0';
      syscdp_gpsr_led_stat_int <= '0';
      syscdp_gpsr_led_link_int <= '0';
      regs_o.gpsr_fmc_scl_load_o <= '0';
      regs_o.gpsr_fmc_sda_load_o <= '0';
      syscdp_gpsr_net_rst_int <= '0';
      regs_o.gpsr_sfp0_scl_load_o <= '0';
      regs_o.gpsr_sfp0_sda_load_o <= '0';
      regs_o.gpsr_spi_sclk_load_o <= '0';
      regs_o.gpsr_spi_ncs_load_o <= '0';
      regs_o.gpsr_spi_mosi_load_o <= '0';
      regs_o.gpsr_sfp1_scl_load_o <= '0';
      regs_o.gpsr_sfp1_sda_load_o <= '0';
      syscdp_gpcr_led_stat_int <= '0';
      syscdp_gpcr_led_link_int <= '0';
      syscdp_gpcr_fmc_scl_int <= '0';
      syscdp_gpcr_fmc_sda_int <= '0';
      syscdp_gpcr_sfp0_scl_int <= '0';
      syscdp_gpcr_sfp0_sda_int <= '0';
      syscdp_gpcr_spi_sclk_int <= '0';
      syscdp_gpcr_spi_cs_int <= '0';
      syscdp_gpcr_spi_mosi_int <= '0';
      syscdp_gpcr_sfp1_scl_int <= '0';
      syscdp_gpcr_sfp1_sda_int <= '0';
      syscdp_tcr_enable_int <= '0';
    elsif rising_edge(clk_sys_i) then
-- advance the ACK generator shift register
      ack_sreg(8 downto 0) <= ack_sreg(9 downto 1);
      ack_sreg(9) <= '0';
      if (ack_in_progress = '1') then
        if (ack_sreg(0) = '1') then
          regs_o.rstr_trig_wr_o <= '0';
          syscdp_gpsr_led_stat_int <= '0';
          syscdp_gpsr_led_link_int <= '0';
          regs_o.gpsr_fmc_scl_load_o <= '0';
          regs_o.gpsr_fmc_sda_load_o <= '0';
          syscdp_gpsr_net_rst_int <= '0';
          regs_o.gpsr_sfp0_scl_load_o <= '0';
          regs_o.gpsr_sfp0_sda_load_o <= '0';
          regs_o.gpsr_spi_sclk_load_o <= '0';
          regs_o.gpsr_spi_ncs_load_o <= '0';
          regs_o.gpsr_spi_mosi_load_o <= '0';
          regs_o.gpsr_sfp1_scl_load_o <= '0';
          regs_o.gpsr_sfp1_sda_load_o <= '0';
          syscdp_gpcr_led_stat_int <= '0';
          syscdp_gpcr_led_link_int <= '0';
          syscdp_gpcr_fmc_scl_int <= '0';
          syscdp_gpcr_fmc_sda_int <= '0';
          syscdp_gpcr_sfp0_scl_int <= '0';
          syscdp_gpcr_sfp0_sda_int <= '0';
          syscdp_gpcr_spi_sclk_int <= '0';
          syscdp_gpcr_spi_cs_int <= '0';
          syscdp_gpcr_spi_mosi_int <= '0';
          syscdp_gpcr_sfp1_scl_int <= '0';
          syscdp_gpcr_sfp1_sda_int <= '0';
          ack_in_progress <= '0';
        else
          regs_o.rstr_trig_wr_o <= '0';
          regs_o.gpsr_fmc_scl_load_o <= '0';
          regs_o.gpsr_fmc_sda_load_o <= '0';
          regs_o.gpsr_sfp0_scl_load_o <= '0';
          regs_o.gpsr_sfp0_sda_load_o <= '0';
          regs_o.gpsr_spi_sclk_load_o <= '0';
          regs_o.gpsr_spi_ncs_load_o <= '0';
          regs_o.gpsr_spi_mosi_load_o <= '0';
          regs_o.gpsr_sfp1_scl_load_o <= '0';
          regs_o.gpsr_sfp1_sda_load_o <= '0';
        end if;
      else
        if ((wb_cyc_i = '1') and (wb_stb_i = '1')) then
          case rwaddr_reg(2 downto 0) is
          when "000" => 
            if (wb_we_i = '1') then
              regs_o.rstr_trig_wr_o <= '1';
              syscdp_rstr_rst_int <= wrdata_reg(28);
            end if;
            rddata_reg(28) <= syscdp_rstr_rst_int;
            rddata_reg(0) <= 'X';
            rddata_reg(1) <= 'X';
            rddata_reg(2) <= 'X';
            rddata_reg(3) <= 'X';
            rddata_reg(4) <= 'X';
            rddata_reg(5) <= 'X';
            rddata_reg(6) <= 'X';
            rddata_reg(7) <= 'X';
            rddata_reg(8) <= 'X';
            rddata_reg(9) <= 'X';
            rddata_reg(10) <= 'X';
            rddata_reg(11) <= 'X';
            rddata_reg(12) <= 'X';
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
            rddata_reg(16) <= 'X';
            rddata_reg(17) <= 'X';
            rddata_reg(18) <= 'X';
            rddata_reg(19) <= 'X';
            rddata_reg(20) <= 'X';
            rddata_reg(21) <= 'X';
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "001" => 
            if (wb_we_i = '1') then
              syscdp_gpsr_led_stat_int <= wrdata_reg(0);
              syscdp_gpsr_led_link_int <= wrdata_reg(1);
              regs_o.gpsr_fmc_scl_load_o <= '1';
              regs_o.gpsr_fmc_sda_load_o <= '1';
              syscdp_gpsr_net_rst_int <= wrdata_reg(4);
              regs_o.gpsr_sfp0_scl_load_o <= '1';
              regs_o.gpsr_sfp0_sda_load_o <= '1';
              regs_o.gpsr_spi_sclk_load_o <= '1';
              regs_o.gpsr_spi_ncs_load_o <= '1';
              regs_o.gpsr_spi_mosi_load_o <= '1';
              regs_o.gpsr_sfp1_scl_load_o <= '1';
              regs_o.gpsr_sfp1_sda_load_o <= '1';
            end if;
            rddata_reg(0) <= '0';
            rddata_reg(1) <= '0';
            rddata_reg(2) <= regs_i.gpsr_fmc_scl_i;
            rddata_reg(3) <= regs_i.gpsr_fmc_sda_i;
            rddata_reg(4) <= '0';
            rddata_reg(7) <= regs_i.gpsr_sfp0_det_i;
            rddata_reg(8) <= regs_i.gpsr_sfp0_scl_i;
            rddata_reg(9) <= regs_i.gpsr_sfp0_sda_i;
            rddata_reg(10) <= regs_i.gpsr_spi_sclk_i;
            rddata_reg(11) <= regs_i.gpsr_spi_ncs_i;
            rddata_reg(12) <= regs_i.gpsr_spi_mosi_i;
            rddata_reg(13) <= regs_i.gpsr_spi_miso_i;
            rddata_reg(14) <= regs_i.gpsr_sfp1_det_i;
            rddata_reg(15) <= regs_i.gpsr_sfp1_scl_i;
            rddata_reg(16) <= regs_i.gpsr_sfp1_sda_i;
            rddata_reg(5) <= 'X';
            rddata_reg(6) <= 'X';
            rddata_reg(17) <= 'X';
            rddata_reg(18) <= 'X';
            rddata_reg(19) <= 'X';
            rddata_reg(20) <= 'X';
            rddata_reg(21) <= 'X';
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(2) <= '1';
            ack_in_progress <= '1';
          when "010" => 
            if (wb_we_i = '1') then
              syscdp_gpcr_led_stat_int <= wrdata_reg(0);
              syscdp_gpcr_led_link_int <= wrdata_reg(1);
              syscdp_gpcr_fmc_scl_int <= wrdata_reg(2);
              syscdp_gpcr_fmc_sda_int <= wrdata_reg(3);
              syscdp_gpcr_sfp0_scl_int <= wrdata_reg(8);
              syscdp_gpcr_sfp0_sda_int <= wrdata_reg(9);
              syscdp_gpcr_spi_sclk_int <= wrdata_reg(10);
              syscdp_gpcr_spi_cs_int <= wrdata_reg(11);
              syscdp_gpcr_spi_mosi_int <= wrdata_reg(12);
              syscdp_gpcr_sfp1_scl_int <= wrdata_reg(14);
              syscdp_gpcr_sfp1_sda_int <= wrdata_reg(15);
            end if;
            rddata_reg(0) <= '0';
            rddata_reg(1) <= '0';
            rddata_reg(2) <= '0';
            rddata_reg(3) <= '0';
            rddata_reg(8) <= '0';
            rddata_reg(9) <= '0';
            rddata_reg(10) <= '0';
            rddata_reg(11) <= '0';
            rddata_reg(12) <= '0';
            rddata_reg(14) <= '0';
            rddata_reg(15) <= '0';
            rddata_reg(0) <= 'X';
            rddata_reg(1) <= 'X';
            rddata_reg(2) <= 'X';
            rddata_reg(3) <= 'X';
            rddata_reg(4) <= 'X';
            rddata_reg(5) <= 'X';
            rddata_reg(6) <= 'X';
            rddata_reg(7) <= 'X';
            rddata_reg(8) <= 'X';
            rddata_reg(9) <= 'X';
            rddata_reg(10) <= 'X';
            rddata_reg(11) <= 'X';
            rddata_reg(12) <= 'X';
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
            rddata_reg(16) <= 'X';
            rddata_reg(17) <= 'X';
            rddata_reg(18) <= 'X';
            rddata_reg(19) <= 'X';
            rddata_reg(20) <= 'X';
            rddata_reg(21) <= 'X';
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(2) <= '1';
            ack_in_progress <= '1';
          when "011" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(3 downto 0) <= regs_i.hwfr_memsize_i;
            rddata_reg(4) <= 'X';
            rddata_reg(5) <= 'X';
            rddata_reg(6) <= 'X';
            rddata_reg(7) <= 'X';
            rddata_reg(8) <= 'X';
            rddata_reg(9) <= 'X';
            rddata_reg(10) <= 'X';
            rddata_reg(11) <= 'X';
            rddata_reg(12) <= 'X';
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
            rddata_reg(16) <= 'X';
            rddata_reg(17) <= 'X';
            rddata_reg(18) <= 'X';
            rddata_reg(19) <= 'X';
            rddata_reg(20) <= 'X';
            rddata_reg(21) <= 'X';
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            rddata_reg(31) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "100" => 
            if (wb_we_i = '1') then
              syscdp_tcr_enable_int <= wrdata_reg(31);
            end if;
            rddata_reg(11 downto 0) <= regs_i.tcr_tdiv_i;
            rddata_reg(31) <= syscdp_tcr_enable_int;
            rddata_reg(12) <= 'X';
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
            rddata_reg(16) <= 'X';
            rddata_reg(17) <= 'X';
            rddata_reg(18) <= 'X';
            rddata_reg(19) <= 'X';
            rddata_reg(20) <= 'X';
            rddata_reg(21) <= 'X';
            rddata_reg(22) <= 'X';
            rddata_reg(23) <= 'X';
            rddata_reg(24) <= 'X';
            rddata_reg(25) <= 'X';
            rddata_reg(26) <= 'X';
            rddata_reg(27) <= 'X';
            rddata_reg(28) <= 'X';
            rddata_reg(29) <= 'X';
            rddata_reg(30) <= 'X';
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when "101" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(31 downto 0) <= regs_i.tvr_i;
            ack_sreg(0) <= '1';
            ack_in_progress <= '1';
          when others =>
-- prevent the slave from hanging the bus on invalid address
            ack_in_progress <= '1';
            ack_sreg(0) <= '1';
          end case;
        end if;
      end if;
    end if;
  end process;
  
  
-- Drive the data output bus
  wb_dat_o <= rddata_reg;
-- Reset trigger
-- pass-through field: Reset trigger in register: Syscon reset register
  regs_o.rstr_trig_o <= wrdata_reg(27 downto 0);
-- Reset line state value
  regs_o.rstr_rst_o <= syscdp_rstr_rst_int;
-- Status LED
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpsr_led_stat_dly0 <= '0';
      regs_o.gpsr_led_stat_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpsr_led_stat_dly0 <= syscdp_gpsr_led_stat_int;
      regs_o.gpsr_led_stat_o <= syscdp_gpsr_led_stat_int and (not syscdp_gpsr_led_stat_dly0);
    end if;
  end process;
  
  
-- Link LED
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpsr_led_link_dly0 <= '0';
      regs_o.gpsr_led_link_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpsr_led_link_dly0 <= syscdp_gpsr_led_link_int;
      regs_o.gpsr_led_link_o <= syscdp_gpsr_led_link_int and (not syscdp_gpsr_led_link_dly0);
    end if;
  end process;
  
  
-- FMC I2C bitbanged SCL
  regs_o.gpsr_fmc_scl_o <= wrdata_reg(2);
-- FMC I2C bitbanged SDA
  regs_o.gpsr_fmc_sda_o <= wrdata_reg(3);
-- Network AP reset
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpsr_net_rst_dly0 <= '0';
      regs_o.gpsr_net_rst_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpsr_net_rst_dly0 <= syscdp_gpsr_net_rst_int;
      regs_o.gpsr_net_rst_o <= syscdp_gpsr_net_rst_int and (not syscdp_gpsr_net_rst_dly0);
    end if;
  end process;
  
  
-- SFP0 detect (MOD_DEF0 signal)
-- SFP0 I2C bitbanged SCL
  regs_o.gpsr_sfp0_scl_o <= wrdata_reg(8);
-- SFP0 I2C bitbanged SDA
  regs_o.gpsr_sfp0_sda_o <= wrdata_reg(9);
-- SPI bitbanged SCLK
  regs_o.gpsr_spi_sclk_o <= wrdata_reg(10);
-- SPI bitbanged NCS
  regs_o.gpsr_spi_ncs_o <= wrdata_reg(11);
-- SPI bitbanged MOSI
  regs_o.gpsr_spi_mosi_o <= wrdata_reg(12);
-- SPI bitbanged MISO
-- SFP1 detect (MOD_DEF0 signal)
-- SFP1 I2C bitbanged SCL
  regs_o.gpsr_sfp1_scl_o <= wrdata_reg(15);
-- SFP1 I2C bitbanged SDA
  regs_o.gpsr_sfp1_sda_o <= wrdata_reg(16);
-- Status LED
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpcr_led_stat_dly0 <= '0';
      regs_o.gpcr_led_stat_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpcr_led_stat_dly0 <= syscdp_gpcr_led_stat_int;
      regs_o.gpcr_led_stat_o <= syscdp_gpcr_led_stat_int and (not syscdp_gpcr_led_stat_dly0);
    end if;
  end process;
  
  
-- Link LED
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpcr_led_link_dly0 <= '0';
      regs_o.gpcr_led_link_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpcr_led_link_dly0 <= syscdp_gpcr_led_link_int;
      regs_o.gpcr_led_link_o <= syscdp_gpcr_led_link_int and (not syscdp_gpcr_led_link_dly0);
    end if;
  end process;
  
  
-- FMC I2C bitbanged SCL
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpcr_fmc_scl_dly0 <= '0';
      regs_o.gpcr_fmc_scl_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpcr_fmc_scl_dly0 <= syscdp_gpcr_fmc_scl_int;
      regs_o.gpcr_fmc_scl_o <= syscdp_gpcr_fmc_scl_int and (not syscdp_gpcr_fmc_scl_dly0);
    end if;
  end process;
  
  
-- FMC I2C bitbanged SDA
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpcr_fmc_sda_dly0 <= '0';
      regs_o.gpcr_fmc_sda_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpcr_fmc_sda_dly0 <= syscdp_gpcr_fmc_sda_int;
      regs_o.gpcr_fmc_sda_o <= syscdp_gpcr_fmc_sda_int and (not syscdp_gpcr_fmc_sda_dly0);
    end if;
  end process;
  
  
-- SFP0 I2C bitbanged SCL
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpcr_sfp0_scl_dly0 <= '0';
      regs_o.gpcr_sfp0_scl_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpcr_sfp0_scl_dly0 <= syscdp_gpcr_sfp0_scl_int;
      regs_o.gpcr_sfp0_scl_o <= syscdp_gpcr_sfp0_scl_int and (not syscdp_gpcr_sfp0_scl_dly0);
    end if;
  end process;
  
  
-- SFP0 I2C bitbanged SDA
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpcr_sfp0_sda_dly0 <= '0';
      regs_o.gpcr_sfp0_sda_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpcr_sfp0_sda_dly0 <= syscdp_gpcr_sfp0_sda_int;
      regs_o.gpcr_sfp0_sda_o <= syscdp_gpcr_sfp0_sda_int and (not syscdp_gpcr_sfp0_sda_dly0);
    end if;
  end process;
  
  
-- SPI bitbanged SCLK
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpcr_spi_sclk_dly0 <= '0';
      regs_o.gpcr_spi_sclk_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpcr_spi_sclk_dly0 <= syscdp_gpcr_spi_sclk_int;
      regs_o.gpcr_spi_sclk_o <= syscdp_gpcr_spi_sclk_int and (not syscdp_gpcr_spi_sclk_dly0);
    end if;
  end process;
  
  
-- SPI bitbanged CS
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpcr_spi_cs_dly0 <= '0';
      regs_o.gpcr_spi_cs_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpcr_spi_cs_dly0 <= syscdp_gpcr_spi_cs_int;
      regs_o.gpcr_spi_cs_o <= syscdp_gpcr_spi_cs_int and (not syscdp_gpcr_spi_cs_dly0);
    end if;
  end process;
  
  
-- SPI bitbanged MOSI
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpcr_spi_mosi_dly0 <= '0';
      regs_o.gpcr_spi_mosi_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpcr_spi_mosi_dly0 <= syscdp_gpcr_spi_mosi_int;
      regs_o.gpcr_spi_mosi_o <= syscdp_gpcr_spi_mosi_int and (not syscdp_gpcr_spi_mosi_dly0);
    end if;
  end process;
  
  
-- SFP1 I2C bitbanged SCL
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpcr_sfp1_scl_dly0 <= '0';
      regs_o.gpcr_sfp1_scl_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpcr_sfp1_scl_dly0 <= syscdp_gpcr_sfp1_scl_int;
      regs_o.gpcr_sfp1_scl_o <= syscdp_gpcr_sfp1_scl_int and (not syscdp_gpcr_sfp1_scl_dly0);
    end if;
  end process;
  
  
-- SFP1 I2C bitbanged SDA
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      syscdp_gpcr_sfp1_sda_dly0 <= '0';
      regs_o.gpcr_sfp1_sda_o <= '0';
    elsif rising_edge(clk_sys_i) then
      syscdp_gpcr_sfp1_sda_dly0 <= syscdp_gpcr_sfp1_sda_int;
      regs_o.gpcr_sfp1_sda_o <= syscdp_gpcr_sfp1_sda_int and (not syscdp_gpcr_sfp1_sda_dly0);
    end if;
  end process;
  
  
-- Memory size
-- Timer Divider
-- Timer Enable
  regs_o.tcr_enable_o <= syscdp_tcr_enable_int;
-- Timer Counter Value
  rwaddr_reg <= wb_adr_i;
  wb_stall_o <= (not ack_sreg(0)) and (wb_stb_i and wb_cyc_i);
-- ACK signal generation. Just pass the LSB of ACK counter.
  wb_ack_o <= ack_sreg(0);
end syn;