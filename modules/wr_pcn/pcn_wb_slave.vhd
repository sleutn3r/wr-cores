---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for PCN Wishbone Slave
---------------------------------------------------------------------------------------
-- File           : pcn_wb_slave.vhd
-- Author         : auto-generated by wbgen2 from pcn_wb_slave.wb
-- Created        : Thu Sep  1 16:22:57 2016
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE pcn_wb_slave.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wbgen2_pkg.all;

use work.pcn_wbgen2_pkg.all;


entity pcn_wb_slave is
  port (
    rst_n_i                                  : in     std_logic;
    clk_sys_i                                : in     std_logic;
    wb_adr_i                                 : in     std_logic_vector(1 downto 0);
    wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    wb_stall_o                               : out    std_logic;
    refclk_i                                 : in     std_logic;
    regs_i                                   : in     t_pcn_in_registers;
    regs_o                                   : out    t_pcn_out_registers
  );
end pcn_wb_slave;

architecture syn of pcn_wb_slave is

signal pcn_cr_rst_dly0                          : std_logic      ;
signal pcn_cr_rst_int                           : std_logic      ;
signal pcn_cr_cal_sel_int                       : std_logic_vector(1 downto 0);
signal pcn_cr_lut_build_dly0                    : std_logic      ;
signal pcn_cr_lut_build_int                     : std_logic      ;
signal pcn_cr_en_int                            : std_logic_vector(1 downto 0);
signal pcn_sr_dnl_done_int                      : std_logic_vector(1 downto 0);
signal pcn_sr_dnl_done_lwb                      : std_logic      ;
signal pcn_sr_dnl_done_lwb_delay                : std_logic      ;
signal pcn_sr_dnl_done_lwb_in_progress          : std_logic      ;
signal pcn_sr_dnl_done_lwb_s0                   : std_logic      ;
signal pcn_sr_dnl_done_lwb_s1                   : std_logic      ;
signal pcn_sr_dnl_done_lwb_s2                   : std_logic      ;
signal pcn_sr_lut_done_int                      : std_logic_vector(1 downto 0);
signal pcn_sr_lut_done_lwb                      : std_logic      ;
signal pcn_sr_lut_done_lwb_delay                : std_logic      ;
signal pcn_sr_lut_done_lwb_in_progress          : std_logic      ;
signal pcn_sr_lut_done_lwb_s0                   : std_logic      ;
signal pcn_sr_lut_done_lwb_s1                   : std_logic      ;
signal pcn_sr_lut_done_lwb_s2                   : std_logic      ;
signal pcn_tsdf_rst_n                           : std_logic      ;
signal pcn_tsdf_in_int                          : std_logic_vector(17 downto 0);
signal pcn_tsdf_out_int                         : std_logic_vector(17 downto 0);
signal pcn_tsdf_rdreq_int                       : std_logic      ;
signal pcn_tsdf_rdreq_int_d0                    : std_logic      ;
signal pcn_tsdf_full_int                        : std_logic      ;
signal pcn_tsdf_empty_int                       : std_logic      ;
signal pcn_tsdf_usedw_int                       : std_logic_vector(6 downto 0);
signal ack_sreg                                 : std_logic_vector(9 downto 0);
signal rddata_reg                               : std_logic_vector(31 downto 0);
signal wrdata_reg                               : std_logic_vector(31 downto 0);
signal bwsel_reg                                : std_logic_vector(3 downto 0);
signal rwaddr_reg                               : std_logic_vector(1 downto 0);
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
      pcn_cr_rst_int <= '0';
      pcn_cr_cal_sel_int <= "00";
      pcn_cr_lut_build_int <= '0';
      pcn_cr_en_int <= "00";
      pcn_sr_dnl_done_lwb <= '0';
      pcn_sr_dnl_done_lwb_delay <= '0';
      pcn_sr_dnl_done_lwb_in_progress <= '0';
      pcn_sr_lut_done_lwb <= '0';
      pcn_sr_lut_done_lwb_delay <= '0';
      pcn_sr_lut_done_lwb_in_progress <= '0';
      pcn_tsdf_rdreq_int <= '0';
    elsif rising_edge(clk_sys_i) then
-- advance the ACK generator shift register
      ack_sreg(8 downto 0) <= ack_sreg(9 downto 1);
      ack_sreg(9) <= '0';
      if (ack_in_progress = '1') then
        if (ack_sreg(0) = '1') then
          pcn_cr_rst_int <= '0';
          pcn_cr_lut_build_int <= '0';
          ack_in_progress <= '0';
        else
          pcn_sr_dnl_done_lwb <= pcn_sr_dnl_done_lwb_delay;
          pcn_sr_dnl_done_lwb_delay <= '0';
          if ((ack_sreg(1) = '1') and (pcn_sr_dnl_done_lwb_in_progress = '1')) then
            rddata_reg(1 downto 0) <= pcn_sr_dnl_done_int;
            pcn_sr_dnl_done_lwb_in_progress <= '0';
          end if;
          pcn_sr_lut_done_lwb <= pcn_sr_lut_done_lwb_delay;
          pcn_sr_lut_done_lwb_delay <= '0';
          if ((ack_sreg(1) = '1') and (pcn_sr_lut_done_lwb_in_progress = '1')) then
            rddata_reg(3 downto 2) <= pcn_sr_lut_done_int;
            pcn_sr_lut_done_lwb_in_progress <= '0';
          end if;
        end if;
      else
        if ((wb_cyc_i = '1') and (wb_stb_i = '1')) then
          case rwaddr_reg(1 downto 0) is
          when "00" => 
            if (wb_we_i = '1') then
              pcn_cr_rst_int <= wrdata_reg(0);
              pcn_cr_cal_sel_int <= wrdata_reg(2 downto 1);
              pcn_cr_lut_build_int <= wrdata_reg(3);
              pcn_cr_en_int <= wrdata_reg(5 downto 4);
            end if;
            rddata_reg(0) <= '0';
            rddata_reg(2 downto 1) <= pcn_cr_cal_sel_int;
            rddata_reg(3) <= '0';
            rddata_reg(5 downto 4) <= pcn_cr_en_int;
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
          when "01" => 
            if (wb_we_i = '1') then
            end if;
            if (wb_we_i = '0') then
              pcn_sr_dnl_done_lwb <= '1';
              pcn_sr_dnl_done_lwb_delay <= '1';
              pcn_sr_dnl_done_lwb_in_progress <= '1';
            end if;
            if (wb_we_i = '0') then
              pcn_sr_lut_done_lwb <= '1';
              pcn_sr_lut_done_lwb_delay <= '1';
              pcn_sr_lut_done_lwb_in_progress <= '1';
            end if;
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
            ack_sreg(5) <= '1';
            ack_in_progress <= '1';
          when "10" => 
            if (wb_we_i = '1') then
            end if;
            if (pcn_tsdf_rdreq_int_d0 = '0') then
              pcn_tsdf_rdreq_int <= not pcn_tsdf_rdreq_int;
            else
              rddata_reg(17 downto 0) <= pcn_tsdf_out_int(17 downto 0);
              ack_in_progress <= '1';
              ack_sreg(0) <= '1';
            end if;
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
          when "11" => 
            if (wb_we_i = '1') then
            end if;
            rddata_reg(16) <= pcn_tsdf_full_int;
            rddata_reg(17) <= pcn_tsdf_empty_int;
            rddata_reg(6 downto 0) <= pcn_tsdf_usedw_int;
            rddata_reg(7) <= 'X';
            rddata_reg(8) <= 'X';
            rddata_reg(9) <= 'X';
            rddata_reg(10) <= 'X';
            rddata_reg(11) <= 'X';
            rddata_reg(12) <= 'X';
            rddata_reg(13) <= 'X';
            rddata_reg(14) <= 'X';
            rddata_reg(15) <= 'X';
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
-- Reset PCN module
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      pcn_cr_rst_dly0 <= '0';
      regs_o.cr_rst_o <= '0';
    elsif rising_edge(clk_sys_i) then
      pcn_cr_rst_dly0 <= pcn_cr_rst_int;
      regs_o.cr_rst_o <= pcn_cr_rst_int and (not pcn_cr_rst_dly0);
    end if;
  end process;
  
  
-- PCN calibration select
  regs_o.cr_cal_sel_o <= pcn_cr_cal_sel_int;
-- PCN lut build
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      pcn_cr_lut_build_dly0 <= '0';
      regs_o.cr_lut_build_o <= '0';
    elsif rising_edge(clk_sys_i) then
      pcn_cr_lut_build_dly0 <= pcn_cr_lut_build_int;
      regs_o.cr_lut_build_o <= pcn_cr_lut_build_int and (not pcn_cr_lut_build_dly0);
    end if;
  end process;
  
  
-- PCN module enable
  regs_o.cr_en_o <= pcn_cr_en_int;
-- DNL table is done.
-- asynchronous std_logic_vector register : DNL table is done. (type RO/WO, refclk_i <-> clk_sys_i)
  process (refclk_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      pcn_sr_dnl_done_lwb_s0 <= '0';
      pcn_sr_dnl_done_lwb_s1 <= '0';
      pcn_sr_dnl_done_lwb_s2 <= '0';
      pcn_sr_dnl_done_int <= "00";
    elsif rising_edge(refclk_i) then
      pcn_sr_dnl_done_lwb_s0 <= pcn_sr_dnl_done_lwb;
      pcn_sr_dnl_done_lwb_s1 <= pcn_sr_dnl_done_lwb_s0;
      pcn_sr_dnl_done_lwb_s2 <= pcn_sr_dnl_done_lwb_s1;
      if ((pcn_sr_dnl_done_lwb_s1 = '1') and (pcn_sr_dnl_done_lwb_s2 = '0')) then
        pcn_sr_dnl_done_int <= regs_i.sr_dnl_done_i;
      end if;
    end if;
  end process;
  
  
-- LUT table is done.
-- asynchronous std_logic_vector register : LUT table is done. (type RO/WO, refclk_i <-> clk_sys_i)
  process (refclk_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      pcn_sr_lut_done_lwb_s0 <= '0';
      pcn_sr_lut_done_lwb_s1 <= '0';
      pcn_sr_lut_done_lwb_s2 <= '0';
      pcn_sr_lut_done_int <= "00";
    elsif rising_edge(refclk_i) then
      pcn_sr_lut_done_lwb_s0 <= pcn_sr_lut_done_lwb;
      pcn_sr_lut_done_lwb_s1 <= pcn_sr_lut_done_lwb_s0;
      pcn_sr_lut_done_lwb_s2 <= pcn_sr_lut_done_lwb_s1;
      if ((pcn_sr_lut_done_lwb_s1 = '1') and (pcn_sr_lut_done_lwb_s2 = '0')) then
        pcn_sr_lut_done_int <= regs_i.sr_lut_done_i;
      end if;
    end if;
  end process;
  
  
-- extra code for reg/fifo/mem: Timestamp Differences FIFO
  pcn_tsdf_in_int(17 downto 0) <= regs_i.tsdf_val_i;
  pcn_tsdf_rst_n <= rst_n_i;
  pcn_tsdf_INST : wbgen2_fifo_sync
    generic map (
      g_size               => 128,
      g_width              => 18,
      g_usedw_size         => 7
    )
    port map (
      wr_req_i             => regs_i.tsdf_wr_req_i,
      wr_full_o            => regs_o.tsdf_wr_full_o,
      wr_empty_o           => regs_o.tsdf_wr_empty_o,
      wr_usedw_o           => regs_o.tsdf_wr_usedw_o,
      rd_full_o            => pcn_tsdf_full_int,
      rd_empty_o           => pcn_tsdf_empty_int,
      rd_usedw_o           => pcn_tsdf_usedw_int,
      rd_req_i             => pcn_tsdf_rdreq_int,
      rst_n_i              => pcn_tsdf_rst_n,
      clk_i                => clk_sys_i,
      wr_data_i            => pcn_tsdf_in_int,
      rd_data_o            => pcn_tsdf_out_int
    );
  
-- extra code for reg/fifo/mem: FIFO 'Timestamp Differences FIFO' data output register 0
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      pcn_tsdf_rdreq_int_d0 <= '0';
    elsif rising_edge(clk_sys_i) then
      pcn_tsdf_rdreq_int_d0 <= pcn_tsdf_rdreq_int;
    end if;
  end process;
  
  
  rwaddr_reg <= wb_adr_i;
  wb_stall_o <= (not ack_sreg(0)) and (wb_stb_i and wb_cyc_i);
-- ACK signal generation. Just pass the LSB of ACK counter.
  wb_ack_o <= ack_sreg(0);
end syn;
