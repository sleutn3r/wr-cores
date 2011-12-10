/*
-------------------------------------------------------------------------------
-- Title      : WhiteRabbit PTP Core
-- Project    : WhiteRabbit
-------------------------------------------------------------------------------
-- File       : wr_core.vhd
-- Author     : Grzegorz Daniluk
-- Company    : Elproma
-- Created    : 2011-02-02
-- Last update: 2011-07-27
-- Platform   : FPGA-generics
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- WR PTP Core is a HDL module implementing a complete gigabit Ethernet 
-- interface (MAC + PCS + PHY) with integrated PTP slave ordinary clock 
-- compatible with White Rabbit protocol. It performs subnanosecond clock 
-- synchronization via WR protocol and also acts as an Ethernet "gateway", 
-- providing access to TX/RX interfaces of the built-in WR MAC.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 Grzegorz Daniluk
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2011-02-02  1.0      greg.d          Created
-- 2011-07-27  1.0      mlipink         adapted to test wr_core with FEC encoder
-------------------------------------------------------------------------------
-- TODO:
-- 
-- This is a testbench of entire wr_core with FEC encoder inside and:
-- * FEC encoder is in the entity: wr_fec_and_gen_with_wrf.vhd, this includes
--   -> frame dummy generator which sends dummmy frames to the FEC encoder
--   -> fec Encoder does its work and sends it to wbp-to-wrf converter
--   -> converter changes the streaming interface from Wishbone pipelined to 
--      Fabric Interface (obsolete, to be replaced with WBp)
-- * FEC is connected directly to endpoint (through WBP) instead of MINI-nic
-- * we control the dummy generator with Wisbone on the addresses stating with
--   0x70000, the registers are discribed in the file :
--   modules/wr_fec/wr_fec_dummy_pck_gen_if.html
-- * run by:  vsim work.main_with_fec -t 1ns -voptargs="+acc"


-------------------------------------------------------------------------------
*/



`timescale 1ns/1ps



`include "if_wishbone.sv"
`include "endpoint_regs.v"
`include "endpoint_mdio.v"
`include "tbi_utils.sv"

`timescale 1ps/1ps

`define EP_QMODE_ACCESS 0
`define EP_QMODE_TRUNK 1
`define EP_QMODE_UNQ 3

// Clock periods (in picoseconds)
const int c_RBCLK_PERIOD   = 8001;
const int c_REFCLK_PERIOD  = 8000;

`define ADDR_RST_GEN 'h62000

module main_with_fec;

   wire clk_ref;
   wire clk_sys;
   wire rst_n;

   IWishbone WB 
     (
      .clk_i(clk_sys),
      .rst_n_i(rst_n)
      );
   
   tbi_clock_rst_gen
     #(
       .g_rbclk_period(8002))
     clkgen(
	    .clk_ref_o(clk_ref),
	    .clk_sys_o(clk_sys),
	    .phy_rbclk_o(phy_rbclk),
	    .rst_n_o(rst_n)
	    );

   wire clk_sys_dly;

   assign  #10 clk_sys_dly  = clk_sys;
    wire   [7:0]phy_tx_data      ;
   wire   phy_tx_k         ;
   wire   phy_tx_disparity ;
   wire   phy_tx_enc_err   ;
   wire   [7:0]phy_rx_data      ;
   wire   phy_rx_rbclk     ;
   wire   phy_rx_k         ;
   wire   phy_rx_enc_err   ;
   wire   [3:0]phy_rx_bitslide  ;
   wire   phy_rst          ;
   wire   phy_loopen;

   wr_core_with_fec #(
    .g_simulation             (1),
    .g_virtual_uart(1),
    .g_ep_rxbuf_size_log2     (12),
    .g_dpram_initf            ("/home/slayer/wrpc-sw/hello.ram"),
    .g_dpram_size             (16384),
    .g_num_gpio               (8)
    )
   DUT (
	.clk_sys_i      (clk_sys),
	.clk_dmtd_i     (clk_ref),
	.clk_ref_i      (clk_ref),
	.rst_n_i         (rst_n),

	.pps_p_o        (),

	.dac_hpll_load_p1_o (),
	.dac_hpll_data_o (),

	.dac_dpll_load_p1_o (),
	.dac_dpll_data_o (),

	.gpio_o          (),
    
	.uart_rxd_i       (1'b0),
	.uart_txd_o       (),

	.wb_addr_i      (WB.adr[17:0]),
	.wb_data_i      (WB.dat_o),
	.wb_data_o      (WB.dat_i),
	.wb_sel_i       (4'b1111),
	.wb_we_i        (WB.we),
	.wb_cyc_i       (WB.cyc),
	.wb_stb_i       (WB.stb),
	.wb_ack_o       (WB.ack),

        .phy_ref_clk_i(clk_ref),
        .phy_tx_data_o(phy_tx_data),
        .phy_tx_k_o(phy_tx_k),
        .phy_tx_disparity_i(phy_tx_disparity),
        .phy_tx_enc_err_i(phy_tx_enc_err),
        .phy_rx_data_i(phy_rx_data),
        .phy_rx_rbclk_i(clk_ref),
        .phy_rx_k_i(phy_rx_k),
        .phy_rx_enc_err_i(phy_rx_enc_err),
        .phy_rx_bitslide_i(phy_rx_bitslide),
        .phy_rst_o(phy_rst),
        .phy_loopen_o(phy_lo),

	.genrest_n        ()
	);
	
	wire [9:0] phy_loop;


  wr_tbi_phy
  PHY (
  
   .serdes_rst_i    (phy_rst),
   .serdes_loopen_i (1'b0),
   .serdes_prbsen_i (1'b0),
   .serdes_enable_i (1'b0),
   .serdes_syncen_i (1'b0),

        .serdes_tx_data_i(phy_tx_data),
        .serdes_tx_k_i(phy_tx_k),
        .serdes_tx_disparity_o(phy_tx_disparity),
        .serdes_tx_enc_err_o(phy_tx_enc_err),
        .serdes_rx_data_o(phy_rx_data),
        .serdes_rx_k_o(phy_rx_k),
        .serdes_rx_enc_err_o(phy_rx_enc_err),
        .serdes_rx_bitslide_o(phy_rx_bitslide),

    .tbi_refclk_i (clk_ref),
    .tbi_rbclk_i  (clk_ref),
    .tbi_td_o     (phy_loop),
    .tbi_rd_i     (phy_loop)
  );
  

   
      task mdio_write(int addr, int data);
        reg[31:0] rval;
      
        WB.write32('h20010 + `ADDR_EP_MDIO_CR, (addr >> 2) | `EP_MDIO_CR_RW);
        while(1)begin
           WB.read32('h20010 + `ADDR_EP_MDIO_SR, rval);
        if(rval & `EP_MDIO_SR_READY) break;
        end
     endtask // mdio_write   
   
     task initialize_EP_regs();
      //WB.verbose(0);
      //WB.monitor_bus(0);

      $display("Initializing EP registers...");
      
      WB.write32('h20000 + `ADDR_EP_ECR, `EP_ECR_RX_EN_FRA | `EP_ECR_TX_EN_FRA);
      WB.write32('h20000 + `ADDR_EP_RFCR, 3 << `EP_RFCR_QMODE_OFFSET); // QMODE = UNQUALIFIED
      WB.write32('h20000 + `ADDR_EP_MACH, 'haabb);  // assign a dummy MAC address
      WB.write32('h20000 + `ADDR_EP_MACL, 'hccddeeff);
      WB.write32('h20000 + `ADDR_EP_TSCR, `EP_TSCR_EN_RXTS);
      //mdio_write('h20010 + `ADDR_MDIO_MCR, `MDIO_MCR_RESET);
      
      
   endtask // initialize_EP_regs
   

   initial begin
        
      @(posedge rst_n);
      repeat(3) @(posedge clk_sys);

      initialize_EP_regs();
      
      
      
      WB.write32('h40000, 1);
      WB.write32('h40010, 'hdead);

  repeat(100) @(posedge clk_sys);

      WB.write32('h70000, 500); // set pck len
      WB.write32('h70008, 10); // set pck number
      //WB.write32('h7000C, 1); // start genration
    WB.write32('h7000C, 'h5); // start genration

      forever begin
	 reg[31:0] rval;
	 
	 repeat(100) @(posedge clk_sys);

	 WB.read32('h40000, rval);

	 if(rval[3]) begin
	     WB.read32('h40004, rval);
	    $display("Got TAG: %d", rval);
	 end
	 
	 
      end
      
       
	
      
      
      
   end
   
   
endmodule // main

