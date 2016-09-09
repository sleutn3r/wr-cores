---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for PCN Wishbone Slave
---------------------------------------------------------------------------------------
-- File           : pcn_wbgen2_pkg.vhd
-- Author         : auto-generated by wbgen2 from pcn_wb_slave.wb
-- Created        : Tue Sep  6 09:18:28 2016
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE pcn_wb_slave.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wbgen2_pkg.all;

package pcn_wbgen2_pkg is
  
  
  -- Input registers (user design -> WB slave)
  
  type t_pcn_in_registers is record
    sr_dnl_done_i                            : std_logic_vector(1 downto 0);
    sr_lut_done_i                            : std_logic_vector(1 downto 0);
    tsdf_wr_req_i                            : std_logic;
    tsdf_val_i                               : std_logic_vector(17 downto 0);
    end record;
  
  constant c_pcn_in_registers_init_value: t_pcn_in_registers := (
    sr_dnl_done_i => (others => '0'),
    sr_lut_done_i => (others => '0'),
    tsdf_wr_req_i => '0',
    tsdf_val_i => (others => '0')
    );
    
    -- Output registers (WB slave -> user design)
    
    type t_pcn_out_registers is record
      cr_rst_o                                 : std_logic;
      cr_cal_sel_o                             : std_logic_vector(1 downto 0);
      cr_lut_build_o                           : std_logic;
      cr_en_o                                  : std_logic_vector(1 downto 0);
      cr_output_select_o                       : std_logic_vector(1 downto 0);
      tsdf_wr_full_o                           : std_logic;
      tsdf_wr_empty_o                          : std_logic;
      tsdf_wr_usedw_o                          : std_logic_vector(6 downto 0);
      end record;
    
    constant c_pcn_out_registers_init_value: t_pcn_out_registers := (
      cr_rst_o => '0',
      cr_cal_sel_o => (others => '0'),
      cr_lut_build_o => '0',
      cr_en_o => (others => '0'),
      cr_output_select_o => (others => '0'),
      tsdf_wr_full_o => '0',
      tsdf_wr_empty_o => '0',
      tsdf_wr_usedw_o => (others => '0')
      );
    function "or" (left, right: t_pcn_in_registers) return t_pcn_in_registers;
    function f_x_to_zero (x:std_logic) return std_logic;
    function f_x_to_zero (x:std_logic_vector) return std_logic_vector;
end package;

package body pcn_wbgen2_pkg is
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
function "or" (left, right: t_pcn_in_registers) return t_pcn_in_registers is
variable tmp: t_pcn_in_registers;
begin
tmp.sr_dnl_done_i := f_x_to_zero(left.sr_dnl_done_i) or f_x_to_zero(right.sr_dnl_done_i);
tmp.sr_lut_done_i := f_x_to_zero(left.sr_lut_done_i) or f_x_to_zero(right.sr_lut_done_i);
tmp.tsdf_wr_req_i := f_x_to_zero(left.tsdf_wr_req_i) or f_x_to_zero(right.tsdf_wr_req_i);
tmp.tsdf_val_i := f_x_to_zero(left.tsdf_val_i) or f_x_to_zero(right.tsdf_val_i);
return tmp;
end function;
end package body;
