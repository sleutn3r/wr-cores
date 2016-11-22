// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ns / 1 ps

import altera_xcvr_functions::*;  // for get_custom_reconfig_width functions

module altera_xcvr_det_latency #(
  
  parameter device_family = "Stratix V",
  parameter operation_mode = "Duplex",  //legal value: TX,RX,Duplex
  parameter lanes = 4,  //legal value: 1+
  parameter ser_base_factor = 8,  //legal value: 8,10
  parameter ser_words = 1,  //legal value 1,2,4
  parameter pcs_pma_width = 8,
  parameter data_rate = "1250 Mbps",  //remove this later
  parameter base_data_rate = "0 Mbps", // (PLL data rate)
  parameter en_cdrref_support = 0, //expose CDR ref-clk in this mode
  parameter pll_feedback_path= "no_compensation", //legal: no_compensation, tx_clkout
  parameter word_aligner_mode = "deterministic_latency", //legal value: deterministic_latency or manual
  parameter tx_bitslip_enable = "false",
  parameter run_length_violation_checking = 40, //legal value: 0,1+

  //PLL
  parameter pll_refclk_cnt    = 1,          // Number of reference clocks
  parameter pll_refclk_freq   = "125 MHz",  // Frequency of each reference clock
  parameter pll_refclk_select = "0",        // Selects the initial reference clock for each TX PLL
  parameter cdr_refclk_select = 0,          // Selects the initial reference clock for all RX CDR PLLs
  parameter plls              = 1,          // (1+)
  parameter pll_type          = "AUTO",     // PLL type for each PLL
  parameter pll_select        = 0,          // Selects the initial PLL
  parameter pll_reconfig      = 0,          // (0,1) 0-Disable PLL reconfig, 1-Enable PLL reconfig
  
  //Param siv_xcvr_custom_phy.mgmt_clk_in_mhz has default '50', but module-level default is '150'
  parameter mgmt_clk_in_mhz = 150,  //needed for reset controller timed delays
  parameter embedded_reset = 1,  // (0,1) 1-Enable embedded reset controller
  parameter channel_interface = 0, //legal value: (0,1) 1-Enable channel reconfiguration
  parameter starting_channel_number = 0,  //legal value: 0+em
  parameter rx_use_cruclk = "FALSE"

) (
  // initially found in sv_xcvr_custom_phy
  input  wire phy_mgmt_clk,
  input  tri0 phy_mgmt_clk_reset,
  input  tri0 phy_mgmt_read,
  input  tri0 phy_mgmt_write,
  input  wire [8:0] phy_mgmt_address,
  input  wire [31:0] phy_mgmt_writedata,
  output wire [31:0] phy_mgmt_readdata,
  output wire phy_mgmt_waitrequest,
  // Reset inputs
  input  wire [plls -1:0] pll_powerdown, 
  input  wire [lanes-1:0] tx_analogreset,
  input  wire [lanes-1:0] tx_digitalreset,
  input  wire [lanes-1:0] rx_analogreset,
  input  wire [lanes-1:0] rx_digitalreset,
  // Calibration busy signals
  output wire [lanes-1:0] tx_cal_busy,
  output wire [lanes-1:0] rx_cal_busy,
  //clk signal
  input  wire [pll_refclk_cnt-1:0] pll_ref_clk,
  input  wire                      cdr_ref_clk, // hidden feature 
  output wire [lanes-1:0] tx_clkout,
  output wire [lanes-1:0] rx_clkout,
  //data ports - Avalon ST interface
  input  wire [lanes-1:0] rx_serial_data,
  output wire [(channel_interface? 64: ser_base_factor*ser_words)*lanes-1:0] rx_parallel_data,
  input  wire [(channel_interface? 44: ser_base_factor*ser_words)*lanes-1:0] tx_parallel_data,
  output wire [lanes-1:0] tx_serial_data,
  //more optional data
  input  wire [lanes*ser_words-1:0] tx_datak,
  output wire [lanes*ser_words-1:0] rx_datak,
  input  wire [lanes*5-1:0] tx_bitslipboundaryselect,
  output wire [lanes*5-1:0] rx_bitslipboundaryselectout,
  output wire [lanes*ser_words-1:0] rx_disperr,
  output wire [lanes*ser_words-1:0] rx_errdetect,
  output wire [lanes*ser_words-1:0] rx_runningdisp,
  output wire [lanes*ser_words-1:0] rx_patterndetect,
  output wire [lanes-1:0] rx_rlv,

  //PMA block control and status
  output wire [plls-1:0] pll_locked,  // conduit or ST
  output wire [lanes-1:0] rx_is_lockedtoref,  //conduit or ST
  output wire [lanes-1:0] rx_is_lockedtodata, //conduit or ST
  output wire [lanes-1:0] rx_signaldetect,
  //word alignment
  output wire [lanes*ser_words-1:0] rx_syncstatus,  //conduit or ST
  //reset controller
  output wire tx_ready, //conduit
  output wire rx_ready, //conduit
  //reconfig
  input   wire  [get_custom_reconfig_to_width  (device_family,operation_mode,lanes,plls,1)-1:0] reconfig_to_xcvr,
  output  wire  [get_custom_reconfig_from_width(device_family,operation_mode,lanes,plls,1)-1:0] reconfig_from_xcvr 
);

  localparam is_a5 = has_a5_style_hssi(device_family);
  localparam is_c5 = has_c5_style_hssi(device_family);
  localparam is_s5 = has_s5_style_hssi(device_family);
  localparam [MAX_CHARS*8-1:0] cur_dev = current_device_family(device_family);

  //Arria V GZ
  localparam is_a5gz = has_s5_style_hssi(device_family);
  
  localparam USE_8B10B = (ser_base_factor==8)?"true":"false";

  // Conditional generation of sub-instances
  generate
  
  // S5 => sv_xcvr_custom_phy
  if ( is_s5 | is_a5gz) begin
    sv_xcvr_custom_nr #(
      .device_family(device_family),
      .protocol_hint("cpri"),
      .lanes(lanes),
      .ser_base_factor(ser_base_factor),
      .ser_words(ser_words),
      .mgmt_clk_in_mhz(mgmt_clk_in_mhz),
      .data_rate(data_rate),
      .base_data_rate(base_data_rate),
      .plls(plls),
      .pll_type(pll_type),
      .pll_select(pll_select),
      .pll_reconfig(pll_reconfig),
      .pll_refclk_cnt(pll_refclk_cnt),
      .pll_refclk_freq(pll_refclk_freq),
      .pll_refclk_select(pll_refclk_select),
      .cdr_refclk_select(cdr_refclk_select),
      .pll_feedback_path(pll_feedback_path),
      .operation_mode(operation_mode),
      .starting_channel_number(starting_channel_number),
      .bonded_group_size(1), //only support unbonded mode in deterministic latency phy
      .embedded_reset(embedded_reset),
	  .channel_interface(channel_interface),
      .pcs_pma_width(pcs_pma_width),
      .use_8b10b(USE_8B10B),
      .use_8b10b_manual_control("false"), //disparity control
      .tx_use_coreclk("false"),
      .rx_use_coreclk("false"),
      .en_synce_support (0),
      .tx_bitslip_enable(tx_bitslip_enable),
      .word_aligner_mode(word_aligner_mode),
      .run_length_violation_checking(run_length_violation_checking),
      .use_rate_match_fifo(0),
      .byte_order_mode("none"),
      .coreclk_0ppm_enable("false")
    ) S5 (
      .mgmt_clk_reset(phy_mgmt_clk_reset),
      .mgmt_clk(phy_mgmt_clk),
      .mgmt_read(phy_mgmt_read),
      .mgmt_write(phy_mgmt_write),
      .mgmt_address(phy_mgmt_address[7:0]),
      .mgmt_writedata(phy_mgmt_writedata),
      .mgmt_readdata(phy_mgmt_readdata),
      .mgmt_waitrequest(phy_mgmt_waitrequest),
      .pll_powerdown(pll_powerdown),
      .tx_analogreset(tx_analogreset),
      .tx_digitalreset(tx_digitalreset),
      .rx_analogreset(rx_analogreset),
      .rx_digitalreset(rx_digitalreset),
      .tx_cal_busy(tx_cal_busy),
      .rx_cal_busy(rx_cal_busy),
      .pll_ref_clk(pll_ref_clk),
      .cdr_ref_clk(cdr_ref_clk),
      .tx_coreclkin({lanes{1'b0}}),
      .rx_coreclkin({lanes{1'b0}}),
      .ext_pll_clk({(plls*lanes){1'b0}}),
      .tx_clkout(tx_clkout),
      .rx_clkout(rx_clkout),
      .rx_recovered_clk(/*unused*/),
      .rx_serial_data(rx_serial_data),
      .rx_parallel_data(rx_parallel_data),
      .tx_parallel_data(tx_parallel_data),
      .tx_serial_data(tx_serial_data),
      .tx_datak(tx_datak),
      .rx_datak(rx_datak),
      .tx_dispval({ser_words*lanes{1'b0}}),
      .tx_forcedisp({ser_words*lanes{1'b0}}),
      .rx_disperr(rx_disperr),
      .rx_a1a2sizeout(/*unused*/),
      .rx_errdetect(rx_errdetect),
      .rx_runningdisp(rx_runningdisp),
      .rx_patterndetect(rx_patterndetect),
      .tx_forceelecidle({lanes{1'b0}}),
      .tx_bitslipboundaryselect(tx_bitslipboundaryselect),
      .rx_bitslipboundaryselectout(rx_bitslipboundaryselectout),
      .rx_rmfifodatainserted(/*unused*/),
      .rx_rmfifodatadeleted(/*unused*/),
      .rx_rlv(rx_rlv),
      
      .rx_enabyteord({lanes{1'b0}}),
      .rx_bitslip({lanes{1'b0}}),
      .pll_locked(pll_locked),
      .rx_is_lockedtoref(rx_is_lockedtoref),
      .rx_is_lockedtodata(rx_is_lockedtodata),
      .rx_signaldetect(rx_signaldetect),
      .rx_syncstatus(rx_syncstatus),
      .rx_byteordflag(/*unused*/),
      .tx_ready(tx_ready),
      .rx_ready(rx_ready),
      .reconfig_to_xcvr(reconfig_to_xcvr),
      .reconfig_from_xcvr(reconfig_from_xcvr)
    );
  end

  //A5 => av_xcvr_custom_phy
  else if ( is_a5 | is_c5 ) begin
    av_xcvr_custom_nr #(
      .device_family(device_family),
      .protocol_hint("cpri"),
      .lanes(lanes),
      .ser_base_factor(ser_base_factor),
      .ser_words(ser_words),
      .mgmt_clk_in_mhz(mgmt_clk_in_mhz),
      .data_rate(data_rate),
      .base_data_rate(base_data_rate),
      .plls(plls),
      .pll_type(pll_type),
      .pll_select(pll_select),
      .pll_reconfig(pll_reconfig),
      .pll_refclk_cnt(pll_refclk_cnt),
      .pll_refclk_freq(pll_refclk_freq),
      .pll_refclk_select(pll_refclk_select),
      .cdr_refclk_select(cdr_refclk_select),
      .pll_feedback_path(pll_feedback_path),
      .operation_mode(operation_mode),
      .starting_channel_number(starting_channel_number),
      .bonded_group_size(1), //only support unbonded mode in deterministic latency phy
      .embedded_reset(embedded_reset),
      .channel_interface(channel_interface),
      .pcs_pma_width(pcs_pma_width),
      .use_8b10b(USE_8B10B),
      .use_8b10b_manual_control("false"), //disparity control
      .tx_use_coreclk("false"),
      .rx_use_coreclk("false"),
      .en_synce_support (0),
      .tx_bitslip_enable(tx_bitslip_enable),
      .word_aligner_mode(word_aligner_mode),
      .run_length_violation_checking(run_length_violation_checking),
      .use_rate_match_fifo(0),
      .byte_order_mode("none"),
      .coreclk_0ppm_enable("false")
    ) A5 (
      .mgmt_clk_reset(phy_mgmt_clk_reset),
      .mgmt_clk(phy_mgmt_clk),
      .mgmt_read(phy_mgmt_read),
      .mgmt_write(phy_mgmt_write),
      .mgmt_address(phy_mgmt_address[7:0]),
      .mgmt_writedata(phy_mgmt_writedata),
      .mgmt_readdata(phy_mgmt_readdata),
      .mgmt_waitrequest(phy_mgmt_waitrequest),
      .pll_powerdown(pll_powerdown),
      .tx_analogreset(tx_analogreset),
      .tx_digitalreset(tx_digitalreset),
      .rx_analogreset(rx_analogreset),
      .rx_digitalreset(rx_digitalreset),
      .tx_cal_busy(tx_cal_busy),
      .rx_cal_busy(rx_cal_busy),
      .pll_ref_clk(pll_ref_clk),
      .cdr_ref_clk(cdr_ref_clk),
      .tx_coreclkin({lanes{1'b0}}),
      .rx_coreclkin({lanes{1'b0}}),
      .ext_pll_clk({(plls*lanes){1'b0}}),
      .tx_clkout(tx_clkout),
      .rx_clkout(rx_clkout),
      .rx_recovered_clk(/*unused*/),
      .rx_serial_data(rx_serial_data),
      .rx_parallel_data(rx_parallel_data),
      .tx_parallel_data(tx_parallel_data),
      .tx_serial_data(tx_serial_data),
      .tx_datak(tx_datak),
      .rx_datak(rx_datak),
      .tx_dispval({ser_words*lanes{1'b0}}),
      .tx_forcedisp({ser_words*lanes{1'b0}}),
      .rx_disperr(rx_disperr),
      .rx_a1a2sizeout(/*unused*/),
      .rx_errdetect(rx_errdetect),
      .rx_runningdisp(rx_runningdisp),
      .rx_patterndetect(rx_patterndetect),
      .tx_forceelecidle({lanes{1'b0}}),
      .tx_bitslipboundaryselect(tx_bitslipboundaryselect),
      .rx_bitslipboundaryselectout(rx_bitslipboundaryselectout),
      .rx_rmfifodatainserted(/*unused*/),
      .rx_rmfifodatadeleted(/*unused*/),
      .rx_rlv(rx_rlv),

      .rx_enabyteord({lanes{1'b0}}),
      .rx_bitslip({lanes{1'b0}}),
      .pll_locked(pll_locked),
      .rx_is_lockedtoref(rx_is_lockedtoref),
      .rx_is_lockedtodata(rx_is_lockedtodata),
      .rx_signaldetect(rx_signaldetect),
      .rx_syncstatus(rx_syncstatus),
      .rx_byteordflag(/*unused*/),
      .tx_ready(tx_ready),
      .rx_ready(rx_ready),
      .reconfig_to_xcvr(reconfig_to_xcvr),
      .reconfig_from_xcvr(reconfig_from_xcvr)
    );
  end
   
  // default case when family did not match known strings
  else begin
    initial begin
      $display("Critical Warning: device_family value, '%s', is not supported", current_device_family(device_family));
    end
  end

  endgenerate

//  initial begin
//    $display("altera_xcvr_custom_phy: cur_dev is '%s'", cur_dev);
//    $display("altera_xcvr_custom_phy: is_s5 is '%d'", is_s5);
//    $display("altera_xcvr_custom_phy: is_a5 is '%d'", is_a5);
//    $display("altera_xcvr_custom_phy: is_c5 is '%d'", is_c5);
//  end
endmodule
