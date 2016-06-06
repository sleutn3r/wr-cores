---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for WR Core System Controller
---------------------------------------------------------------------------------------
-- File           : wrc_syscon_pkg.vhd
-- Author         : auto-generated by wbgen2 from wrc_syscon_wb.wb
-- Created        : Mon Jun  6 15:29:37 2016
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE wrc_syscon_wb.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sysc_wbgen2_pkg is
  
  
  -- Input registers (user design -> WB slave)
  
  type t_sysc_in_registers is record
    gpsr_fmc_scl_i                           : std_logic;
    gpsr_fmc_sda_i                           : std_logic;
    gpsr_btn1_i                              : std_logic;
    gpsr_btn2_i                              : std_logic;
    gpsr_sfp_det_i                           : std_logic;
    gpsr_sfp_scl_i                           : std_logic;
    gpsr_sfp_sda_i                           : std_logic;
    gpsr_spi_sclk_i                          : std_logic;
    gpsr_spi_ncs_i                           : std_logic;
    gpsr_spi_mosi_i                          : std_logic;
    gpsr_spi_miso_i                          : std_logic;
    gpsr_fmc_sel_i                           : std_logic;
    gpsr_fmc_lck_i                           : std_logic;
    hwfr_memsize_i                           : std_logic_vector(3 downto 0);
    tcr_tdiv_i                               : std_logic_vector(11 downto 0);
    tvr_i                                    : std_logic_vector(31 downto 0);
    end record;
  
  constant c_sysc_in_registers_init_value: t_sysc_in_registers := (
    gpsr_fmc_scl_i => '0',
    gpsr_fmc_sda_i => '0',
    gpsr_btn1_i => '0',
    gpsr_btn2_i => '0',
    gpsr_sfp_det_i => '0',
    gpsr_sfp_scl_i => '0',
    gpsr_sfp_sda_i => '0',
    gpsr_spi_sclk_i => '0',
    gpsr_spi_ncs_i => '0',
    gpsr_spi_mosi_i => '0',
    gpsr_spi_miso_i => '0',
    gpsr_fmc_sel_i => '0',
    gpsr_fmc_lck_i => '0',
    hwfr_memsize_i => (others => '0'),
    tcr_tdiv_i => (others => '0'),
    tvr_i => (others => '0')
    );
    
    -- Output registers (WB slave -> user design)
    
    type t_sysc_out_registers is record
      rstr_trig_o                              : std_logic_vector(27 downto 0);
      rstr_trig_wr_o                           : std_logic;
      rstr_rst_o                               : std_logic;
      gpsr_led_stat_o                          : std_logic;
      gpsr_led_link_o                          : std_logic;
      gpsr_fmc_scl_o                           : std_logic;
      gpsr_fmc_scl_load_o                      : std_logic;
      gpsr_fmc_sda_o                           : std_logic;
      gpsr_fmc_sda_load_o                      : std_logic;
      gpsr_net_rst_o                           : std_logic;
      gpsr_sfp_scl_o                           : std_logic;
      gpsr_sfp_scl_load_o                      : std_logic;
      gpsr_sfp_sda_o                           : std_logic;
      gpsr_sfp_sda_load_o                      : std_logic;
      gpsr_spi_sclk_o                          : std_logic;
      gpsr_spi_sclk_load_o                     : std_logic;
      gpsr_spi_ncs_o                           : std_logic;
      gpsr_spi_ncs_load_o                      : std_logic;
      gpsr_spi_mosi_o                          : std_logic;
      gpsr_spi_mosi_load_o                     : std_logic;
      gpsr_fmc_sel_o                           : std_logic;
      gpsr_fmc_sel_load_o                      : std_logic;
      gpcr_led_stat_o                          : std_logic;
      gpcr_led_link_o                          : std_logic;
      gpcr_fmc_scl_o                           : std_logic;
      gpcr_fmc_sda_o                           : std_logic;
      gpcr_sfp_scl_o                           : std_logic;
      gpcr_sfp_sda_o                           : std_logic;
      gpcr_spi_sclk_o                          : std_logic;
      gpcr_spi_cs_o                            : std_logic;
      gpcr_spi_mosi_o                          : std_logic;
      gpcr_fmc_sel_o                           : std_logic;
      tcr_enable_o                             : std_logic;
      end record;
    
    constant c_sysc_out_registers_init_value: t_sysc_out_registers := (
      rstr_trig_o => (others => '0'),
      rstr_trig_wr_o => '0',
      rstr_rst_o => '0',
      gpsr_led_stat_o => '0',
      gpsr_led_link_o => '0',
      gpsr_fmc_scl_o => '0',
      gpsr_fmc_scl_load_o => '0',
      gpsr_fmc_sda_o => '0',
      gpsr_fmc_sda_load_o => '0',
      gpsr_net_rst_o => '0',
      gpsr_sfp_scl_o => '0',
      gpsr_sfp_scl_load_o => '0',
      gpsr_sfp_sda_o => '0',
      gpsr_sfp_sda_load_o => '0',
      gpsr_spi_sclk_o => '0',
      gpsr_spi_sclk_load_o => '0',
      gpsr_spi_ncs_o => '0',
      gpsr_spi_ncs_load_o => '0',
      gpsr_spi_mosi_o => '0',
      gpsr_spi_mosi_load_o => '0',
      gpsr_fmc_sel_o => '0',
      gpsr_fmc_sel_load_o => '0',
      gpcr_led_stat_o => '0',
      gpcr_led_link_o => '0',
      gpcr_fmc_scl_o => '0',
      gpcr_fmc_sda_o => '0',
      gpcr_sfp_scl_o => '0',
      gpcr_sfp_sda_o => '0',
      gpcr_spi_sclk_o => '0',
      gpcr_spi_cs_o => '0',
      gpcr_spi_mosi_o => '0',
      gpcr_fmc_sel_o => '0',
      tcr_enable_o => '0'
      );
    function "or" (left, right: t_sysc_in_registers) return t_sysc_in_registers;
    function f_x_to_zero (x:std_logic) return std_logic;
    function f_x_to_zero (x:std_logic_vector) return std_logic_vector;
end package;

package body sysc_wbgen2_pkg is
function f_x_to_zero (x:std_logic) return std_logic is
begin
if x = '1' then
return '1';
else
return '0';
end if;
end function;
function f_x_to_zero (x:std_logic_vector) return std_logic_vector is
variable tmp: std_logic_vector(x'length-1 downto 0);
begin
for i in 0 to x'length-1 loop
if(x(i) = 'X' or x(i) = 'U') then
tmp(i):= '0';
else
tmp(i):=x(i);
end if; 
end loop; 
return tmp;
end function;
function "or" (left, right: t_sysc_in_registers) return t_sysc_in_registers is
variable tmp: t_sysc_in_registers;
begin
tmp.gpsr_fmc_scl_i := f_x_to_zero(left.gpsr_fmc_scl_i) or f_x_to_zero(right.gpsr_fmc_scl_i);
tmp.gpsr_fmc_sda_i := f_x_to_zero(left.gpsr_fmc_sda_i) or f_x_to_zero(right.gpsr_fmc_sda_i);
tmp.gpsr_btn1_i := f_x_to_zero(left.gpsr_btn1_i) or f_x_to_zero(right.gpsr_btn1_i);
tmp.gpsr_btn2_i := f_x_to_zero(left.gpsr_btn2_i) or f_x_to_zero(right.gpsr_btn2_i);
tmp.gpsr_sfp_det_i := f_x_to_zero(left.gpsr_sfp_det_i) or f_x_to_zero(right.gpsr_sfp_det_i);
tmp.gpsr_sfp_scl_i := f_x_to_zero(left.gpsr_sfp_scl_i) or f_x_to_zero(right.gpsr_sfp_scl_i);
tmp.gpsr_sfp_sda_i := f_x_to_zero(left.gpsr_sfp_sda_i) or f_x_to_zero(right.gpsr_sfp_sda_i);
tmp.gpsr_spi_sclk_i := f_x_to_zero(left.gpsr_spi_sclk_i) or f_x_to_zero(right.gpsr_spi_sclk_i);
tmp.gpsr_spi_ncs_i := f_x_to_zero(left.gpsr_spi_ncs_i) or f_x_to_zero(right.gpsr_spi_ncs_i);
tmp.gpsr_spi_mosi_i := f_x_to_zero(left.gpsr_spi_mosi_i) or f_x_to_zero(right.gpsr_spi_mosi_i);
tmp.gpsr_spi_miso_i := f_x_to_zero(left.gpsr_spi_miso_i) or f_x_to_zero(right.gpsr_spi_miso_i);
tmp.gpsr_fmc_sel_i := f_x_to_zero(left.gpsr_fmc_sel_i) or f_x_to_zero(right.gpsr_fmc_sel_i);
tmp.gpsr_fmc_lck_i := f_x_to_zero(left.gpsr_fmc_lck_i) or f_x_to_zero(right.gpsr_fmc_lck_i);
tmp.hwfr_memsize_i := f_x_to_zero(left.hwfr_memsize_i) or f_x_to_zero(right.hwfr_memsize_i);
tmp.tcr_tdiv_i := f_x_to_zero(left.tcr_tdiv_i) or f_x_to_zero(right.tcr_tdiv_i);
tmp.tvr_i := f_x_to_zero(left.tvr_i) or f_x_to_zero(right.tvr_i);
return tmp;
end function;
end package body;
