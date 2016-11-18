-------------------------------------------------------------------------------
-- Title      : Deterministic Altera PHY wrapper - Arria 5
-- Project    : White Rabbit Switch
-------------------------------------------------------------------------------
-- File       : wr_arria5_phy.vhd
-- Authors    : Wesley W. Terpstra
--              Dimitrios lampridis
-- Company    : GSI
-- Created    : 2013-05-14
-- Last update: 2016-08-09
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Single channel wrapper for deterministic PHY
-------------------------------------------------------------------------------
--
-- Copyright (c) 2013 GSI / Wesley W. Terpstra
-- Copyright (c) 2016 CERN
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
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author    Description
-- 2013-03-12  1.0      terpstra  Rewrote using deterministic mode
-- 2013-08-22  1.1      terpstra  Now runs on arria5 hardware
-- 2016-08-09  2.0      dlamprid  Use Altera-provided 8b10b blocks and
--                                get rid unnecessary clock controllers
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gencores_pkg.all;

entity wr_arria5_phy is
  port (
    clk_reconf_i : in  std_logic; -- 100 MHz
    clk_phy_i    : in  std_logic; -- feeds transmitter CMU and CRU
    locked_o     : out std_logic; -- Is the rx_rbclk valid?
    loopen_i     : in  std_logic;  -- local loopback enable (Tx->Rx), active hi
    drop_link_i  : in  std_logic; -- Kill the link?

    tx_clk_o       : out  std_logic;  -- clock used for TX data;
    tx_data_i      : in  std_logic_vector(7 downto 0);   -- data input (8 bits, not 8b10b-encoded)
    tx_k_i         : in  std_logic;  -- 1 when tx_data_i contains a control code, 0 when it's a data byte
    tx_disparity_o : out std_logic;  -- disparity of the currently transmitted 8b10b code (1 = plus, 0 = minus).
    tx_enc_err_o   : out std_logic;  -- error encoding

    rx_rbclk_o    : out std_logic;  -- RX recovered clock
    rx_data_o     : out std_logic_vector(7 downto 0);  -- 8b10b-decoded data output. 
    rx_k_o        : out std_logic;   -- 1 when the byte on rx_data_o is a control code
    rx_enc_err_o  : out std_logic;   -- encoding error indication
    rx_bitslide_o : out std_logic_vector(3 downto 0); -- RX bitslide indication, indicating the delay of the RX path of the transceiver (in UIs). Must be valid when rx_data_o is valid.

    pad_txp_o : out std_logic;
    pad_rxp_i : in std_logic := '0');

end wr_arria5_phy;

architecture rtl of wr_arria5_phy is

  component arria5_phy_reconf
    port(
      reconfig_busy             : out std_logic;
      mgmt_clk_clk              : in  std_logic;
      mgmt_rst_reset            : in  std_logic;
      reconfig_mgmt_address     : in  std_logic_vector(6 downto 0);
      reconfig_mgmt_read        : in  std_logic;
      reconfig_mgmt_readdata    : out std_logic_vector(31 downto 0);
      reconfig_mgmt_waitrequest : out std_logic;
      reconfig_mgmt_write       : in  std_logic;
      reconfig_mgmt_writedata   : in  std_logic_vector(31 downto 0);
      reconfig_to_xcvr          : out std_logic_vector(139 downto 0);
      reconfig_from_xcvr        : in  std_logic_vector(91 downto 0));
  end component;

  component arria5_phy is
    port (
      phy_mgmt_clk                : in  std_logic                      := '0';
      phy_mgmt_clk_reset          : in  std_logic                      := '0';
      phy_mgmt_address            : in  std_logic_vector(8 downto 0)   := (others => '0');
      phy_mgmt_read               : in  std_logic                      := '0';
      phy_mgmt_readdata           : out std_logic_vector(31 downto 0);
      phy_mgmt_waitrequest        : out std_logic;
      phy_mgmt_write              : in  std_logic                      := '0';
      phy_mgmt_writedata          : in  std_logic_vector(31 downto 0)  := (others => '0');
      tx_ready                    : out std_logic;
      rx_ready                    : out std_logic;
      pll_ref_clk                 : in  std_logic_vector(0 downto 0)   := (others => '0');
      tx_serial_data              : out std_logic_vector(0 downto 0);
      tx_bitslipboundaryselect    : in  std_logic_vector(4 downto 0)   := (others => '0');
      pll_locked                  : out std_logic_vector(0 downto 0);
      rx_serial_data              : in  std_logic_vector(0 downto 0)   := (others => '0');
      rx_runningdisp              : out std_logic_vector(0 downto 0);
      rx_disperr                  : out std_logic_vector(0 downto 0);
      rx_errdetect                : out std_logic_vector(0 downto 0);
      rx_bitslipboundaryselectout : out std_logic_vector(4 downto 0);
      tx_clkout                   : out std_logic_vector(0 downto 0);
      rx_clkout                   : out std_logic_vector(0 downto 0);
      tx_parallel_data            : in  std_logic_vector(7 downto 0)   := (others => '0');
      tx_datak                    : in  std_logic_vector(0 downto 0)   := (others => '0');
      rx_parallel_data            : out std_logic_vector(7 downto 0);
      rx_datak                    : out std_logic_vector(0 downto 0);
      reconfig_from_xcvr          : out std_logic_vector(91 downto 0);
      reconfig_to_xcvr            : in  std_logic_vector(139 downto 0) := (others => '0'));
  end component arria5_phy;
  
  signal clk_rx_gxb    : std_logic; -- external fabric
  signal pll_locked    : std_logic;
  signal rx_ready      : std_logic;
  signal tx_ready      : std_logic;
  signal reconfig_busy : std_logic;
  
  signal xcvr_to_reconfig : std_logic_vector(91 downto 0);
  signal reconfig_to_xcvr : std_logic_vector(139 downto 0);
  
  signal rx_bitslipboundaryselectout : std_logic_vector (4 downto 0);
  
begin

  rx_rbclk_o <= clk_rx_gxb;
  
  -- Altera PHY calibration block
  U_Reconf : arria5_phy_reconf
    port map (
      reconfig_busy             => reconfig_busy,
      mgmt_clk_clk              => clk_reconf_i,
      mgmt_rst_reset            => drop_link_i,
      reconfig_mgmt_address     => (others => '0'),
      reconfig_mgmt_read        => '0',
      reconfig_mgmt_readdata    => open,
      reconfig_mgmt_waitrequest => open,
      reconfig_mgmt_write       => '0',
      reconfig_mgmt_writedata   => (others => '0'),
      reconfig_to_xcvr          => reconfig_to_xcvr,
      reconfig_from_xcvr        => xcvr_to_reconfig);

  U_The_PHY : arria5_phy
    port map (
      phy_mgmt_clk                => clk_reconf_i,
      phy_mgmt_clk_reset          => drop_link_i,
      phy_mgmt_address            => "010000101", -- 0x085
      phy_mgmt_read               => '0',
      phy_mgmt_readdata           => open,
      phy_mgmt_waitrequest        => open,
      phy_mgmt_write              => '1',
      phy_mgmt_writedata          => (0 => '1', others => '0'),
      tx_ready                    => tx_ready,
      rx_ready                    => rx_ready,
      pll_ref_clk(0)              => clk_phy_i,
      tx_serial_data(0)           => pad_txp_o,
      tx_bitslipboundaryselect    => (others => '0'),
      pll_locked(0)               => pll_locked,
      rx_serial_data(0)           => pad_rxp_i,
      rx_runningdisp              => open,
      rx_disperr                  => open,
      rx_errdetect(0)             => rx_enc_err_o,
      rx_bitslipboundaryselectout => rx_bitslipboundaryselectout,
      tx_clkout(0)                => tx_clk_o,
      rx_clkout(0)                => clk_rx_gxb,
      tx_parallel_data            => tx_data_i,
      tx_datak(0)                 => tx_k_i,
      rx_parallel_data            => rx_data_o,
      rx_datak(0)                 => rx_k_o,
      reconfig_from_xcvr          => xcvr_to_reconfig,
      reconfig_to_xcvr            => reconfig_to_xcvr);

  -- [TODO] DL: not sure how to get these yet
  tx_disparity_o <= '0';
  tx_enc_err_o <= '0';
  
  locked_o <= pll_locked and tx_ready and not reconfig_busy;
    
  -- Slow registered signals out of the GXB
  p_rx_regs : process(clk_rx_gxb) is
  begin
    if rising_edge(clk_rx_gxb) then
      rx_bitslide_o <= rx_bitslipboundaryselectout(3 downto 0);
    end if;
  end process;
  
end rtl;
