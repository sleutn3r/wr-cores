-------------------------------------------------------------------------------
-- Title      : Altera-specific components required by WR PTP Core
-- Project    : WR PTP Core
-- URL        : http://www.ohwr.org/projects/wr-cores/wiki/Wrpc_core
-------------------------------------------------------------------------------
-- File       : xwrc_platform_altera.vhd
-- Author(s)  : Dimitrios Lampridis  <dimitrios.lampridis@cern.ch>
-- Company    : CERN (BE-CO-HT)
-- Created    : 2016-11-21
-- Last update: 2016-11-29
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module instantiates platform-specific modules that are
-- needed by the WR PTP Core (WRPC) to interface hardware on Altera FPGA.
-- In particular it contains the Altera transceiver PHY and PLLs.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 CERN
-------------------------------------------------------------------------------
-- GNU LESSER GENERAL PUBLIC LICENSE
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

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.endpoint_pkg.all;
use work.gencores_pkg.all;
use work.wr_altera_pkg.all;

entity xwrc_platform_altera is
  generic
    (
      -- Define the family/model of Altera FPGA
      -- (supported: for now only arria5)
      g_fpga_family               : string  := "arria5";
      -- Select whether to include external ref clock input
      g_with_external_clock_input : boolean := FALSE;
      -- Set to FALSE if you want to instantiate your own PLLs
      g_use_default_plls          : boolean := TRUE;
      -- Set to TRUE to use 16bit PCS (currently unsupported)
      g_pcs_16bit                 : boolean := FALSE
      );
  port (
    ---------------------------------------------------------------------------
    -- Asynchronous reset (active low)
    ---------------------------------------------------------------------------
    areset_n_i           : in  std_logic := '1';
    ---------------------------------------------------------------------------
    -- 10MHz ext ref clock input (g_with_external_clock_input = TRUE)
    ---------------------------------------------------------------------------
    clk_10m_ext_i        : in  std_logic := '0';
    ---------------------------------------------------------------------------
    -- Clock inputs for default PLLs (g_use_default_plls = TRUE)
    ---------------------------------------------------------------------------
    -- 20MHz  controlled by DAC1
    clk_20m_i            : in  std_logic := '0';
    -- 125MHz controlled by DAC2
    clk_125m_i           : in  std_logic := '0';
    ---------------------------------------------------------------------------
    -- Clock inputs from custom PLLs (g_use_default_plls = FALSE)
    ---------------------------------------------------------------------------
    -- 62.5MHz DMTD offset clock controlled by DAC1
    clk_62m5_dmtd_i      : in  std_logic := '0';
    -- 62.5MHz Main system clock controlled by DAC2
    clk_62m5_sys_i       : in  std_logic := '0';
    -- 125MHz  Reference clock controlled by DAC2
    clk_125m_ref_i       : in  std_logic := '0';
    -- 125MHz derived from 10MHz external reference
    -- (when g_with_external_clock_input = TRUE)
    clk_125m_ext_mul_i   : in  std_logic := '0';
    ---------------------------------------------------------------------------
    -- Transceiver serial data I/O
    ---------------------------------------------------------------------------
    pad_tx_o             : out std_logic;
    pad_rx_i             : in  std_logic;
    ---------------------------------------------------------------------------
    --Interface to WR PTP Core (WRPC)
    ---------------------------------------------------------------------------
    -- PLL outputs
    clk_62m5_sys_o       : out std_logic;
    clk_125m_ref_o       : out std_logic;
    clk_62m5_dmtd_o      : out std_logic;
    pll_locked_o         : out std_logic;
    -- PHY
    phy_ready_o          : out std_logic;
    phy_loopen_i         : in  std_logic;
    phy_rst_i            : in  std_logic;
    phy_tx_clk_o         : out std_logic;
    phy_tx_data_i        : in  std_logic_vector(f_pcs_data_width(g_pcs_16bit)-1 downto 0);
    phy_tx_k_i           : in  std_logic_vector(f_pcs_k_width(g_pcs_16bit)-1 downto 0);
    phy_tx_disparity_o   : out std_logic;
    phy_tx_enc_err_o     : out std_logic;
    phy_rx_rbclk_o       : out std_logic;
    phy_rx_data_o        : out std_logic_vector(f_pcs_data_width(g_pcs_16bit)-1 downto 0);
    phy_rx_k_o           : out std_logic_vector(f_pcs_k_width(g_pcs_16bit)-1 downto 0);
    phy_rx_enc_err_o     : out std_logic;
    phy_rx_bitslide_o    : out std_logic_vector(f_pcs_bts_width(g_pcs_16bit)-1 downto 0);
    -- External reference
    ext_ref_mul_o        : out std_logic;
    ext_ref_mul_locked_o : out std_logic;
    ext_ref_rst_i        : in  std_logic := '0'
    );

end entity xwrc_platform_altera;

architecture hybrid of xwrc_platform_altera is

  -----------------------------------------------------------------------------
  -- Signals
  -----------------------------------------------------------------------------

  -- PLLs
  signal phy_clk         : std_logic;
  signal clk_pll_62m5    : std_logic;
  signal clk_pll_125m    : std_logic;
  signal clk_pll_dmtd    : std_logic;
  signal clk_ext_125m    : std_logic;
  signal pll_sys_locked  : std_logic;
  signal pll_dmtd_locked : std_logic;
  signal pll_ext_locked  : std_logic;
  signal pll_arst        : std_logic := '0';
  signal pll_ext_rst     : std_logic := '0';

begin  -- architecture hybrid

  -----------------------------------------------------------------------------
  -- Check for unsupported features and/or misconfiguration
  -----------------------------------------------------------------------------
  gen_unknown_fpga : if (g_fpga_family /= "arria5") generate
    assert FALSE
      report "Altera FPGA family [" & g_fpga_family & "] is not supported"
      severity ERROR;
  end generate gen_unknown_fpga;

  gen_unsupported_pcs : if (g_pcs_16bit = TRUE) generate
    assert FALSE
      report "16bit PCS not yet supported"
      severity ERROR;
  end generate gen_unsupported_pcs;

  -----------------------------------------------------------------------------
  -- Clock PLLs
  -----------------------------------------------------------------------------

  -- active high async reset for PLLs
  pll_arst <= not areset_n_i;

  gen_default_plls : if (g_use_default_plls = TRUE) generate

    -- Default PLL setup for Arria V consists of two PLLs.
    -- One takes a 125MHz clock signal (controlled by DAC1) as input
    -- and produces:
    -- a) 62.5MHz WR PTP core main system clock
    -- b) 125MHz WR PTP core reference clock
    -- The other PLL takes a 20MHz clock signal (controlled by DAC2) as input
    -- and produces the 62.5MHz DMTD clock.
    --
    -- A third PLL is instantiated if also g_with_external_clock_input = TRUE.
    -- In that case, a 10MHz external reference is multiplied to generated a
    -- 125MHz reference clock
    gen_arria5_default_plls : if (g_fpga_family = "arria5") generate

      cmp_sys_clk_pll : arria5_sys_pll_default
        port map (
          refclk   => clk_125m_i,
          rst      => pll_arst,
          outclk_0 => clk_pll_62m5,
          outclk_1 => clk_pll_125m,
          locked   => pll_sys_locked);

      cmp_dmtd_clk_pll : arria5_dmtd_pll_default
        port map (
          refclk   => clk_20m_i,
          rst      => pll_arst,
          outclk_0 => clk_pll_dmtd,
          locked   => pll_dmtd_locked);

      gen_arria5_ext_ref_pll : if (g_with_external_clock_input = TRUE) generate

        cmp_arria5_ext_ref_pll_default : arria5_ext_ref_pll_default
          port map (
            refclk   => clk_10m_ext_i,
            rst      => pll_ext_rst,
            outclk_0 => clk_ext_125m,
            locked   => pll_ext_locked);

        cmp_extend_ext_reset : gc_extend_pulse
          generic map (
            g_width => 1000)
          port map (
            clk_i      => clk_pll_62m5,
            rst_n_i    => pll_sys_locked,
            pulse_i    => ext_ref_rst_i,
            extended_o => pll_ext_rst);

      end generate gen_arria5_ext_ref_pll;

      gen_arria5_no_ext_ref_pll : if (g_with_external_clock_input = FALSE) generate
        clk_ext_125m   <= '0';
        pll_ext_locked <= '1';
      end generate gen_arria5_no_ext_ref_pll;

    end generate gen_arria5_default_plls;

  end generate gen_default_plls;

  -- If external PLLs are used, just copy clock inputs to outputs
  gen_custom_plls : if (g_use_default_plls = FALSE) generate

    clk_pll_62m5 <= clk_62m5_sys_i;
    clk_pll_dmtd <= clk_62m5_dmtd_i;
    clk_pll_125m <= clk_125m_ref_i;
    clk_ext_125m <= clk_125m_ext_mul_i;

    -- dummy locked signals
    pll_sys_locked  <= '1';
    pll_dmtd_locked <= '1';
    pll_ext_locked  <= '1';

  end generate gen_custom_plls;

  -- Assign signals to clock outputs
  clk_62m5_sys_o       <= clk_pll_62m5;
  clk_62m5_dmtd_o      <= clk_pll_dmtd;
  clk_125m_ref_o       <= clk_pll_125m;
  pll_locked_o         <= pll_sys_locked and pll_dmtd_locked;
  ext_ref_mul_o        <= clk_ext_125m;
  ext_ref_mul_locked_o <= pll_ext_locked;

  -----------------------------------------------------------------------------
  -- Transceiver PHY
  -----------------------------------------------------------------------------

  with g_pcs_16bit select
    phy_clk <=
    clk_pll_125m when FALSE,
    clk_pll_62m5 when TRUE;

  gen_arria5_phy : if (g_fpga_family = "arria5") generate
    cmp_phy : wr_arria5_phy
      generic map (
        g_pcs_16bit => g_pcs_16bit)
      port map (
        clk_reconf_i   => clk_pll_125m,
        clk_phy_i      => phy_clk,
        ready_o        => phy_ready_o,
        loopen_i       => phy_loopen_i,
        drop_link_i    => phy_rst_i,
        tx_clk_o       => phy_tx_clk_o,
        tx_data_i      => phy_tx_data_i,
        tx_k_i         => phy_tx_k_i,
        tx_disparity_o => phy_tx_disparity_o,
        tx_enc_err_o   => phy_tx_enc_err_o,
        rx_rbclk_o     => phy_rx_rbclk_o,
        rx_data_o      => phy_rx_data_o,
        rx_k_o         => phy_rx_k_o,
        rx_enc_err_o   => phy_rx_enc_err_o,
        rx_bitslide_o  => phy_rx_bitslide_o,
        pad_txp_o      => pad_tx_o,
        pad_rxp_i      => pad_rx_i);
  end generate gen_arria5_phy;

end architecture hybrid;
