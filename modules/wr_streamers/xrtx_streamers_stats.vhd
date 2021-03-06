-------------------------------------------------------------------------------
-- Title      : WR Streamers statistics
-- Project    : White Rabbit Streamers
-------------------------------------------------------------------------------
-- File       : xrtx_streamers_stats.vhd
-- Author     : Maciej Lipinski
-- Company    : CERN
-- Created    : 2016-06-08
-- Last update: 2016-06-12
-- Platform   : FPGA-generics
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- 
-------------------------------------------------------------------------------
--
-- Copyright (c) 2016 CERN/BE-CO-HT
--
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-06-08  1.0      mlipinsk        created
-- 2016-06-12  1.1      mlipinsk        added generic word arrays for SNMP
---------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.wishbone_pkg.all;  -- needed for t_wishbone_slave_in, etc
use work.streamers_pkg.all; -- needed for streamers
use work.wr_fabric_pkg.all; -- neede for :t_wrf_source_in, etc
use work.wrcore_pkg.all;    -- needed for t_generic_word_array
-- use work.wr_transmission_wbgen2_pkg.all;

entity xrtx_streamers_stats is
  
  generic (
    -- Width of frame counters
    g_cnt_width            : integer := 32; -- minimum 15 bits, max 32
    g_acc_width            : integer := 64  -- max value 64
    );
  port (
    clk_i                  : in std_logic;
    rst_n_i                : in std_logic;

    -- input signals from streamers
    sent_frame_i           : in std_logic;
    rcvd_frame_i           : in std_logic;
    lost_block_i           : in std_logic;
    lost_frame_i           : in std_logic;
    lost_frames_cnt_i      : in std_logic_vector(14 downto 0);
    rcvd_latency_i         : in  std_logic_vector(27 downto 0);
    rcvd_latency_valid_i   : in  std_logic;

    clk_ref_i              : in std_logic;
    tm_time_valid_i        : in std_logic := '0';
    tm_tai_i               : in std_logic_vector(39 downto 0) := x"0000000000";
    tm_cycles_i            : in std_logic_vector(27 downto 0) := x"0000000";

    -- statistic control
    reset_stats_i          : in std_logic;
    snapshot_ena_i         : in std_logic := '0';
    ----------------------- statistics ----------------------------------------
    -- output statistics: time of last reset of statistics
    reset_time_tai_o       : out std_logic_vector(39 downto 0) := x"0000000000";
    reset_time_cycles_o    : out std_logic_vector(27 downto 0) := x"0000000";
    -- output statistics: tx/rx counters
    sent_frame_cnt_o       : out std_logic_vector(g_cnt_width-1 downto 0);
    rcvd_frame_cnt_o       : out std_logic_vector(g_cnt_width-1 downto 0);
    lost_frame_cnt_o       : out std_logic_vector(g_cnt_width-1 downto 0);
    lost_block_cnt_o       : out std_logic_vector(g_cnt_width-1 downto 0);
    -- output statistics: latency
    latency_cnt_o          : out std_logic_vector(g_cnt_width-1 downto 0);
    latency_acc_overflow_o : out std_logic;
    latency_acc_o          : out std_logic_vector(g_acc_width-1  downto 0);
    latency_max_o          : out std_logic_vector(27  downto 0);
    latency_min_o          : out std_logic_vector(27  downto 0);

    snmp_array_o           : out t_generic_word_array(c_STREAMERS_ARR_SIZE_OUT-1 downto 0);
    snmp_array_i           : in  t_generic_word_array(c_STREAMERS_ARR_SIZE_IN -1 downto 0)
    );

end xrtx_streamers_stats;
  
architecture rtl of xrtx_streamers_stats is

  component pulse_stamper
    port (
      clk_ref_i       : in  std_logic;
      clk_sys_i       : in  std_logic;
      rst_n_i         : in  std_logic;
      pulse_a_i       : in  std_logic;
      tm_time_valid_i : in  std_logic;
      tm_tai_i        : in  std_logic_vector(39 downto 0);
      tm_cycles_i     : in  std_logic_vector(27 downto 0);
      tag_tai_o       : out std_logic_vector(39 downto 0);
      tag_cycles_o    : out std_logic_vector(27 downto 0);
      tag_valid_o     : out std_logic);
  end component;

  signal reset_time_tai    : std_logic_vector(39 downto 0);
  signal reset_time_cycles : std_logic_vector(27 downto 0);

  signal sent_frame_cnt    : unsigned(g_cnt_width-1  downto 0);
  signal rcvd_frame_cnt    : unsigned(g_cnt_width-1  downto 0);
  signal lost_frame_cnt    : unsigned(g_cnt_width-1  downto 0);
  signal lost_block_cnt    : unsigned(g_cnt_width-1  downto 0);
  signal latency_cnt       : unsigned(g_cnt_width-1  downto 0);

  signal latency_max       : std_logic_vector(27  downto 0);
  signal latency_min       : std_logic_vector(27  downto 0);
  signal latency_acc       : unsigned(g_acc_width-1+1  downto 0);
  signal latency_acc_overflow: std_logic;

  -- snaphsot
  signal sent_frame_cnt_d1    : unsigned(g_cnt_width-1  downto 0);
  signal rcvd_frame_cnt_d1    : unsigned(g_cnt_width-1  downto 0);
  signal lost_frame_cnt_d1    : unsigned(g_cnt_width-1  downto 0);
  signal lost_block_cnt_d1    : unsigned(g_cnt_width-1  downto 0);
  signal latency_cnt_d1       : unsigned(g_cnt_width-1  downto 0);

  signal latency_max_d1       : std_logic_vector(27  downto 0);
  signal latency_min_d1       : std_logic_vector(27  downto 0);
  signal latency_acc_d1       : unsigned(g_acc_width-1+1  downto 0);
  signal latency_acc_overflow_d1: std_logic;

  signal sent_frame_cnt_out       : std_logic_vector(g_cnt_width-1 downto 0);
  signal rcvd_frame_cnt_out       : std_logic_vector(g_cnt_width-1 downto 0);
  signal lost_frame_cnt_out       : std_logic_vector(g_cnt_width-1 downto 0);
  signal lost_block_cnt_out       : std_logic_vector(g_cnt_width-1 downto 0);
  signal latency_cnt_out          : std_logic_vector(g_cnt_width-1 downto 0);
  signal latency_acc_overflow_out : std_logic;
  signal latency_acc_out          : std_logic_vector(g_acc_width-1  downto 0);
  signal latency_max_out          : std_logic_vector(27  downto 0);
  signal latency_min_out          : std_logic_vector(27  downto 0);

  --- statistics resets:
  signal reset_stats_remote: std_logic;
  signal reset_stats       : std_logic;
  signal reset_stats_d1    : std_logic;
  signal reset_stats_p     : std_logic;
  signal snapshot_remote_ena  : std_logic;
  signal snapshot_ena      : std_logic;
  signal snapshot_ena_d1   : std_logic;
  
  -- for code cleanness
  constant cw              : integer := g_cnt_width;
  constant aw              : integer := g_acc_width;
begin

  -- reset statistics when receiving signal from SNMP or Wishbone
  reset_stats <= reset_stats_remote or reset_stats_i;
  -------------------------------------------------------------------------------------------
  -- produce pulse of reset input signal, this pulse produces timesstamp to be timestamped
  -------------------------------------------------------------------------------------------
  -- pulse is on falling and rising edge of the reset signal (reset when signal HIGH)
  -- in this way, one can 
  -- 1. read the timestamp of the start of statistics acquisition
  -- 2. reset HIGH
  -- 3. read the timestamp of the end of statistics acquisition
  -- 4. start acqusition
  -------------------------------------------------------------------------------------------
  -- when exiting the reset, produce pulse for the timestamper
  p_stats_reset: process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (rst_n_i = '0') then
         reset_stats_p  <= '0';
         reset_stats_d1 <= '0';
      else
        if(reset_stats = '0' and reset_stats_d1 = '1') then
          reset_stats_p <='1';
        elsif(reset_stats = '1' and reset_stats_d1 = '0') then
          reset_stats_p <='1';
        else
          reset_stats_p <='0';
        end if;
        reset_stats_d1 <= reset_stats;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------------------------
  -- Timestamp of reset
  -------------------------------------------------------------------------------------------
  -- process that timestamps the reset so that we can make statistics over time
  U_Reset_Timestamper : pulse_stamper
    port map (
      clk_ref_i       => clk_ref_i,
      clk_sys_i       => clk_i,
      rst_n_i         => rst_n_i,
      pulse_a_i       => reset_stats_p,
      tm_time_valid_i => tm_time_valid_i,
      tm_tai_i        => tm_tai_i,
      tm_cycles_i     => tm_cycles_i,
      tag_tai_o       => reset_time_tai,
      tag_cycles_o    => reset_time_cycles);

  reset_time_tai_o    <= reset_time_tai;
  reset_time_cycles_o <= reset_time_cycles;

  -------------------------------------------------------------------------------------------
  -- frame/block statistics, i.e. lost, sent, received
  -------------------------------------------------------------------------------------------
  -- process that counts stuff: receved/send/lost frames
  p_cnts: process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (rst_n_i = '0' or reset_stats = '1') then
        sent_frame_cnt        <= (others => '0');
        rcvd_frame_cnt        <= (others => '0');
        lost_frame_cnt        <= (others => '0');
        lost_block_cnt        <= (others => '0');
      else
        -- count sent frames
        if(sent_frame_i = '1') then
          sent_frame_cnt <= sent_frame_cnt + 1;
        end if;
        -- count received frames
        if(rcvd_frame_i = '1') then
          rcvd_frame_cnt <= rcvd_frame_cnt + 1;
        end if;
        -- count lost frames
        if(lost_frame_i = '1') then
          lost_frame_cnt <= lost_frame_cnt + resize(unsigned(lost_frames_cnt_i),lost_frame_cnt'length);
        end if;
        -- count lost blocks
        if(lost_block_i = '1') then
          lost_block_cnt <= lost_block_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------------------------
  -- latency statistics
  -------------------------------------------------------------------------------------------
  p_latency_stats: process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (rst_n_i = '0' or reset_stats = '1') then
        latency_max            <= (others => '0');
        latency_min            <= (others => '1');
        latency_acc            <= (others => '0');
        latency_cnt            <= (others => '0');
        latency_acc_overflow   <= '0';
      else
        if(rcvd_latency_valid_i = '1' and tm_time_valid_i = '1') then
          if(latency_max < rcvd_latency_i) then
            latency_max <= rcvd_latency_i;
          end if;
          if(latency_min > rcvd_latency_i) then
            latency_min <= rcvd_latency_i;
          end if;
          if(latency_acc(g_acc_width) ='1') then
            latency_acc_overflow   <= '1';
          end if;
          latency_cnt <= latency_cnt + 1;
          latency_acc <= latency_acc + resize(unsigned(rcvd_latency_i),latency_acc'length);
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------------------------
  -- snapshot 
  -------------------------------------------------------------------------------------------
  -- snapshot is used to expose to user coherent value, so that the count for accumulated
  -- latency is coherent with the accumulated latency and the average can be accurately 
  -- calculated
  -------------------------------------------------------------------------------------------
  snapshot_ena <= snapshot_ena_i or snapshot_remote_ena;
  -- snapshot
  p_stats_snapshot: process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (rst_n_i = '0') then
         snapshot_ena_d1         <= '0';
         sent_frame_cnt_d1       <= (others=>'0');
         rcvd_frame_cnt_d1       <= (others=>'0');
         lost_frame_cnt_d1       <= (others=>'0');
         lost_block_cnt_d1       <= (others=>'0');
         latency_cnt_d1          <= (others=>'0');

         latency_max_d1          <= (others=>'0');
         latency_min_d1          <= (others=>'0');
         latency_acc_d1          <= (others=>'0');
         latency_acc_overflow_d1 <= '0';
      else
        if(snapshot_ena = '1' and snapshot_ena_d1 = '0') then
         sent_frame_cnt_d1       <= sent_frame_cnt;
         rcvd_frame_cnt_d1       <= rcvd_frame_cnt;
         lost_frame_cnt_d1       <= lost_frame_cnt;
         lost_block_cnt_d1       <= lost_block_cnt;
         latency_cnt_d1          <= latency_cnt;

         latency_max_d1          <= latency_max;
         latency_min_d1          <= latency_min;
         latency_acc_d1          <= latency_acc;
         latency_acc_overflow_d1 <= latency_acc_overflow;
        end if;
        snapshot_ena_d1 <= snapshot_ena;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------------------------
  -- snapshot or current value
  -------------------------------------------------------------------------------------------
  sent_frame_cnt_out       <= std_logic_vector(sent_frame_cnt_d1) when (snapshot_ena_d1 = '1') else
                              std_logic_vector(sent_frame_cnt);
  rcvd_frame_cnt_out       <= std_logic_vector(rcvd_frame_cnt_d1) when (snapshot_ena_d1 = '1') else
                              std_logic_vector(rcvd_frame_cnt);
  lost_frame_cnt_out       <= std_logic_vector(lost_frame_cnt_d1) when (snapshot_ena_d1 = '1') else
                              std_logic_vector(lost_frame_cnt);
  lost_block_cnt_out       <= std_logic_vector(lost_block_cnt_d1) when (snapshot_ena_d1 = '1') else
                              std_logic_vector(lost_block_cnt);
  latency_max_out          <= latency_max_d1 when (snapshot_ena_d1 = '1') else
                              latency_max;
  latency_min_out          <= latency_min_d1 when (snapshot_ena_d1 = '1') else
                              latency_min;
  latency_acc_out          <= std_logic_vector(latency_acc_d1(g_acc_width-1 downto 0)) when (snapshot_ena_d1 = '1') else
                              std_logic_vector(latency_acc(g_acc_width-1 downto 0));
  latency_cnt_out          <= std_logic_vector(latency_cnt_d1) when (snapshot_ena_d1 = '1') else
                              std_logic_vector(latency_cnt);
  latency_acc_overflow_out <= latency_acc_overflow_d1  when (snapshot_ena_d1 = '1') else
                              latency_acc_overflow;

  -------------------------------------------------------------------------------------------
  -- wishbone local output
  -------------------------------------------------------------------------------------------
  sent_frame_cnt_o         <= sent_frame_cnt_out;
  rcvd_frame_cnt_o         <= rcvd_frame_cnt_out;
  lost_frame_cnt_o         <= lost_frame_cnt_out;
  lost_block_cnt_o         <= lost_block_cnt_out;
  latency_max_o            <= latency_max_out;
  latency_min_o            <= latency_min_out;
  latency_acc_o            <= latency_acc_out;
  latency_cnt_o            <= latency_cnt_out;
  latency_acc_overflow_o   <= latency_acc_overflow_out;

  -------------------------------------------------------------------------------------------
  -- SNMP remote output
  -------------------------------------------------------------------------------------------

  -- Generic communication with WRPC that allows SNMP access via generic array of 32-bits 
  -- std_logic_vectors
  assert (cw <= 32) 
    report "g_cnt_width value not suppported by f_pack_streamers_statistics" severity error;
  assert (aw <= 64) 
    report "g_cnt_width value not suppported by f_pack_streamers_statistics" severity error;

  reset_stats_remote                <= snmp_array_i(0)(0);
  snapshot_remote_ena               <= snmp_array_i(0)(1);

  snmp_array_o(0)(             0)   <= reset_stats;                   -- loop back for diagnostics
  snmp_array_o(0)(             1)   <= latency_acc_overflow_out;
  snmp_array_o(1)(   31 downto 0)   <= x"0" & reset_time_cycles( 27 downto 0);
  snmp_array_o(2)(   31 downto 0)   <= reset_time_tai(    31 downto 0);
  snmp_array_o(3)(   31 downto 0)   <= x"000000" & reset_time_tai(    39 downto 32);

  -- output to the 
  snmp_array_o(4 )(cw-1 downto 0)   <= sent_frame_cnt_out;
  snmp_array_o(5 )(cw-1 downto 0)   <= rcvd_frame_cnt_out;
  snmp_array_o(6 )(cw-1 downto 0)   <= lost_frame_cnt_out;
  snmp_array_o(7 )(cw-1 downto 0)   <= lost_block_cnt_out;
  snmp_array_o(8 )(cw-1 downto 0)   <= latency_cnt_out;
  snmp_array_o(9 )(31   downto 0)   <= x"0" & latency_max_out(27 downto 0);
  snmp_array_o(10)(31   downto 0)   <= x"0" & latency_min_out(27 downto 0); 

  snmp_array_o(0) (31   downto 2)   <= (others => '0');
  snmp_array_o(4 )(31   downto cw)  <= (others => '0');
  snmp_array_o(5 )(31   downto cw)  <= (others => '0');
  snmp_array_o(6 )(31   downto cw)  <= (others => '0');
  snmp_array_o(7 )(31   downto cw)  <= (others => '0');
  snmp_array_o(8 )(31   downto cw)  <= (others => '0');

  CNT_SINGLE_WORD_gen: if(aw < 33) generate
    snmp_array_o(11)(aw-1    downto  0) <= latency_acc_out;
    snmp_array_o(11)(31      downto aw) <= (others => '0');
  end generate;
  CNT_TWO_WORDs_gen:   if(aw > 32) generate
    snmp_array_o(11)(31      downto 0)     <= latency_acc_out(31    downto 0);
    snmp_array_o(12)(aw-32-1 downto 0)     <= latency_acc_out(aw-1 downto 32) ;
    snmp_array_o(12)(31      downto aw-32) <= (others => '0'); 
  end generate;

  -- tmp debug
   snmp_array_o(13)(31 downto 0) <= snmp_array_i(0)(31 downto 0);

end rtl;