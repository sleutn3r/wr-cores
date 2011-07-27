/*
------------------------------------------------------------------------
-- Title      : Forward Error Correction
-- Project    : WhiteRabbit Node
-------------------------------------------------------------------------------
-- File       : wr_generate_and_fec_with_wrf.sv
-- Author     : Maciej Lipinski
-- Company    : CERN BE-Co-HT
-- Created    : 2011-04-12
-- Last update: 2011-04-12
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: this is a System Verilog testbench which tests FEC encoder with
-- dummy generator and with outputs interface in wrf format (fabric interface 
-- which is the current format which is to be changed to Wishbone pipelined). 
--
-- It uses Tomek's simulation of Wishbone pipelined interface (in ./wbp) 
-- and Tomek's (debugged by me) wbp to wrf converter  
-------------------------------------------------------------------------------
--
-- Copyright (c) 2011 Maciej Lipinski / CERN
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
-- Date        Version  Author   Description
-- 2011-??-?? 1.0      twostow   Created
-- 2011-07-24 1.1      mlipinsk  modified for FEC
-------------------------------------------------------------------------------
*/

`timescale 1ns/1ps


`define WB_USE_EXTERNAL_CLOCK // tell the wishbone test master to use provided clock & reset instead of generating its own signals

`include "if_wishbone.sv"
`include "wbp/fabric_emu.sv"
`include "wbp/endpoint_regs.v"
`include "wbp/endpoint_mdio.v"
`include "tbi_utils.sv"

`include "wbp/if_wb_classic_master.sv"
`include "wbp/if_wb_slave.sv"
`include "wbp/if_wb_master.sv"
`include "wbp/if_wb_link.sv"

`timescale 1ps/1ps

`define EP_QMODE_ACCESS 0
`define EP_QMODE_TRUNK 1
`define EP_QMODE_UNQ 3

// Clock periods (in picoseconds)
const int c_RBCLK_PERIOD   = 8010;
const int c_REFCLK_PERIOD  = 8000;


typedef struct {
   bit [7:0] match_class;
   bit has_smac;
   bit rx_error;
   bit is_hp;
} wrf_status_reg_t;

const bit[1:0] c_WRF_STATUS = 2'b11;
const bit[1:0] c_WRF_DATA = 2'b00;
const bit[1:0] c_WRF_OOB = 2'b01;
const bit[1:0] c_WRF_FEC = 2'b10;

class CWRFFrameGenerator;
   
   protected CWishboneAccessor acc;
   
   function new(CWishboneAccessor master);
      this.acc 	= CWishboneAccessor'(master);
   endfunction // new

   //////////////// ML ///////////////////////////
   //protected CIWBMasterAccessor acc;
   //
   //function new(CIWBMasterAccessor master);
   //   this.acc 	= master;
   //endfunction // new
   ///////////////////////////////////////////////
     
   task send(ether_frame_t fra, bit fec, bit status, int err_addr, output wb_cycle_result_t result);
      begin
	 wb_cycle_t cyc;

	 int i;
	 int tot_len;
	 int odd_len;
	 int single_idx;
	 int error;
	 
	 int start = 0;
   
   if(fec)
   begin
     cyc.data[i].a 	       = c_WRF_FEC;
     cyc.data[i].size 	    = 16;
     cyc.data[i].sel 	     = 2'b11;
     start++;
   end  //if
   
   if(status)
   begin
     cyc.data[start].d         = 'hbabe;
     cyc.data[start].a 	       = c_WRF_STATUS;
     cyc.data[start].size 	    = 16;
     cyc.data[start].sel 	     = 2'b11;
     start++;
   end  //if

   
	 for(i=0;i<(7+2*fra.hdr.is_802_1q);i++)
	   begin
	      cyc.data[start+i].a 	   = c_WRF_DATA;
	      cyc.data[start+i].size  = 16;
	      cyc.data[start+i].sel 	 = 2'b11;
	      
	   end
	 
	 cyc.data[start+0].d 		       = fra.hdr.dst[47:32];
	 cyc.data[start+1].d 		       = fra.hdr.dst[31:16];
	 cyc.data[start+2].d 		       = fra.hdr.dst[15:0];
	 cyc.data[start+3].d 		       = fra.hdr.src[47:32];
	 cyc.data[start+4].d 		       = fra.hdr.src[31:16];
	 cyc.data[start+5].d 		       = fra.hdr.src[15:0];
	 if(fra.hdr.is_802_1q  == 1) 
	   begin
     cyc.data[start+6].d 		     = 'h8100;
     cyc.data[start+7].d 		     = fra.hdr.oob_fid;
     cyc.data[start+8].d 		     = fra.hdr.ethertype;
     tot_len 		                 = start+9;
     end
   else
     begin
	   cyc.data[start+6].d 		     = fra.hdr.ethertype;
	   tot_len 		                 = start+7;
	   end



	 for(int i = 0; i<(fra.size+1) / 2; i++)
	   begin
	      cyc.data[i+tot_len].d    = (fra.payload[i*2] << 8) | fra.payload[i*2+1];
	      cyc.data[i+tot_len].a    = c_WRF_DATA;
	      cyc.data[i+tot_len].sel  = 2'b11;
	   end

	 tot_len 		       = tot_len + (fra.size+1) / 2;

	 if(fra.size & 1)
	   cyc.data[tot_len - 1].sel   = 2'b10;

   if(fec)
     cyc.data[0].d 		= fra.size;

	 if(fra.hdr.oob_type == `OOB_TYPE_TXTS)
   	 for(int i = 0; i<3; i++)
	   begin
	     cyc.data[tot_len].a        = c_WRF_OOB;
	     cyc.data[tot_len].d        = fra.hdr.oob_fid + i;
	     cyc.data[tot_len].sel      =2'b11;
	     tot_len++;
     end

   if(err_addr > 0)
     begin 
     // introduce error
     
     cyc.data[err_addr/2].a        = c_WRF_STATUS;
     cyc.data[err_addr/2].d        = 1;
     cyc.data[err_addr/2].sel      = 2'b11;  
     end
	 
	 acc.put(cyc);

   $display("[tx] wait");
	 while(!acc.idle()) #1;
   $display("[tx] done");

	 acc.get(cyc);
	 
      end
   endtask // send

endclass // CWRFFrameGenerator



class CWRFFrameSink;
   
  protected CWishboneAccessor acc;
  
   
   protected function wrf_status_reg_t unmarshall_status(bit [15:0] d);
      wrf_status_reg_t stat;
      stat.match_class 	= d[15:8];
      stat.rx_error 	= d[1];
      stat.has_smac 	= d[2];
      stat.is_hp 	= d[0];
      return stat;
   endfunction // unmarshall_status

   
   function new(CWishboneAccessor slave);
      this.acc 	= slave;
   endfunction // new

   protected task unqueue_data(ref bit[7:0] d[$], wb_xfer_t xf);
      case(xf.size)
	16:
	  begin
	     if(xf.sel[1])
	       d.push_back((xf.d >> 8) & 'hff);
	     if(xf.sel[0])
	       d.push_back(xf.d & 'hff);
	  end
	  endcase // case (xf.size)
   endtask // unqueue_data
   
   
   task automatic rx_frame(output ether_frame_t fra);
      int i;
      int oob_index;
      wrf_status_reg_t stat;

      bit[7:0] data_buf[$];
      bit[7:0] oob_buf[$];

      wb_cycle_t xfer;
      acc.get(xfer);
      $display("[rx] got Ethernet Frame");


      fra.error 	 = 0;
      fra.hdr.is_802_1q  = 0;
      for(i=0;i<xfer.data.size(); i++)
	begin
     wb_xfer_t xf  = xfer.data[i];
	   stat 	 = unmarshall_status(xf.d);
    //$display("rx_frame");
    //$display(xfer.data.size());

	   case (xf.a)
	     c_WRF_STATUS:
	       begin
		  if(stat.rx_error)
		    fra.error  = 1;
	       end
	     c_WRF_DATA:
	       unqueue_data(data_buf, xf);
	     c_WRF_OOB:
	       unqueue_data(oob_buf, xf);
	   endcase // case (xf.a)
	end

      $display("[rx] data bytes %d oob bytes %d", data_buf.size(), oob_buf.size());
   endtask // rx_frame

endclass



//module generate_and_fec_with_wrf;
module main;

   wire clk_ref;
   wire clk_sys;
   wire rst_n;


  
   wire [9:0] phy_td, phy_rd;
   wire phy_rbclk;

   wire txtsu_valid, txtsu_ack;
   wire [4:0] txtsu_pid;
   wire [15:0] txtsu_fid;
   wire [31:0] txtsu_timestamp;

   wire[7:0] gtp_tx_data;
   wire gtp_tx_k;
   wire gtp_tx_disparity;
   wire gtp_tx_enc_error;
   wire [7:0] gtp_rx_data;
   wire gtp_rx_clk;
   wire gtp_rx_k;
   wire gtp_rx_enc_error;
   wire [3:0] gtp_rx_bitslide;
   
   tbi_clock_rst_gen
     #(
       .g_rbclk_period(8100))
     clkgen(
	    .clk_ref_o(clk_ref),
	    .clk_sys_o(clk_sys),
	    .phy_rbclk_o(phy_rbclk),
	    .rst_n_o(rst_n)
	    );
   
/* -----\/----- EXCLUDED -----\/-----
   fabric_emu EMU
      (
       .clk_i(clk_sys),
       .rst_n_i(rst_n),
    
       `WRF_FULL_CONNECT_SOURCE(rx, toEP)

       ); 
 -----/\----- EXCLUDED -----/\----- */

   parameter g_phy_mode  = "TBI";

IWishbone 
//  #(
//  .g_addr_width(3),
//  .g_data_width(32)
//  ) 
WBconfig 
  (
   .clk_i(clk_sys),
   .rst_n_i(rst_n)
   );


   IWishboneSlave
     #(
       .g_addr_width(2),
       .g_data_width(16)
       )
     wrf_sink
       (
	.clk_i(clk_sys),
	.rst_n_i(rst_n)
	);

   IWishboneMaster
     #(
       .g_addr_width(2),
       .g_data_width(16)
       )
     wrf_source_a
       (
	.clk_i(clk_sys),
	.rst_n_i(rst_n)
	);

  


   IWishboneClassicMaster WB
     (.clk_i(clk_sys),
      .rst_n_i(rst_n)
      );

  //pipelined WB for streaming data from generator
  wire [15:0] wbm_dat;
  wire [ 1:0] wbm_adr;
  wire [ 1:0] wbm_sel;
  wire        wbm_cyc;
  wire        wbm_stb;
  wire        wbm_we;
  wire        wbm_err;
  wire        wbm_stall;
  wire        wbm_ack;

  //WB for controling generator
  /*
  reg  [31:0] wb_dat_i;
  reg  [31:0] wb_dat_o;
  reg  [ 2:0] wb_adr;
  reg  [ 3:0] wb_sel;
  reg         wb_cyc;
  reg         wb_stb;
  reg         wb_we;
  reg         wb_stall;
  reg         wb_ack;
  */
  reg [15:0] payload_size;
  reg [ 8:0] increment_size;
  reg [15:0] gen_frame_number;
  reg [ 8:0] ctrl_reg;
  reg [ 8:0] stat_reg;
  
  wire [15:0] wrf_data;
  wire [3 :0] wrf_ctrl;

  wire        wrf_bytesel;
  wire        wrf_dreq;
  wire       wrf_valid;
  wire       wrf_sof_p1;
  wire       wrf_eof_p1;
  wire       wrf_error_p1;
  wire       wrf_abort_p1; 
  
  reg dummy_reg;
  assign dummy_reg = 1'b0;
  
  reg [4:0]  txtsu_port_id_i;
  reg [15:0] txtsu_fid_i;
  reg [31:0] txtsu_tsval_i;
  reg        txtsu_valid_i;
  wire       txtsu_ack_o;
  
  // WRF links
   `WRF_FULL_WIRES(dummy)
   `WRF_FULL_WIRES(fec)
  
  assign wrf_sink.we = 1'b1;

wr_fec_and_gen_with_wrf
  FEC_DUT(
    .clk_i(clk_sys),
    .rst_n_i(rst_n),
    
    .src_data_o(wrf_data),     
    .src_ctrl_o(wrf_ctrl),     
    .src_bytesel_o(wrf_bytesel),  
    .src_dreq_i(wrf_dreq),     
    .src_valid_o(wrf_valid),    
    .src_sof_p1_o(wrf_sof_p1),   
    .src_eof_p1_o(wrf_eof_p1),   
    .src_error_p1_i(dummy_reg), 
    .src_abort_p1_o(wrf_abort_p1),
    

    .wb_clk_i (clk_sys),                                 
    .wb_addr_i(WBconfig.adr[2:0]),                                
    .wb_data_i(WBconfig.dat_o),                                
    .wb_data_o(WBconfig.dat_i),                                
    .wb_cyc_i (WBconfig.cyc),                                 
    .wb_sel_i (WBconfig.sel),                                 
    .wb_stb_i (WBconfig.stb),                                 
    .wb_we_i  (WBconfig.we),                                  
    .wb_ack_o (WBconfig.ack)
    
                                 
  );
   
   fabric_emu test_input_block_0
     (
      .clk_i(clk_sys),
      .rst_n_i(rst_n),
      `WRF_FULL_CONNECT_SOURCE(rx,dummy),

      `WRF_FULL_CONNECT_SINK(tx, wrf),
      
      .txtsu_port_id_i (txtsu_port_id_i),
      .txtsu_fid_i     (txtsu_fid_i),
      .txtsu_tsval_i   (txtsu_tsval_i),
      .txtsu_valid_i   (txtsu_valid_i),
      .txtsu_ack_o     (txtsu_ack_o) 

      );   


   IWishboneLink  
     #(
       .g_addr_width(2),
       .g_data_width(16)
       ) e2f ();
   
   

   tbi_loopback_fifo
     lb_fifo(
	     .tx_clk_i(clk_ref),
	     .rx_clk_i(phy_rbclk),
	     .tx_data_i(phy_td),
	     .rx_data_o(phy_rd)
	     );

   task automatic initialize_EP_regs();
      int i;      
      $display("Initializing EP registers...");
      
      WB.write32(`ADDR_EP_ECR, `EP_ECR_RX_EN_FRA | `EP_ECR_TX_EN_FRA);
      WB.write32(`ADDR_EP_RFCR, 3 << `EP_RFCR_QMODE_OFFSET); // QMODE = UNQUALIFIED
      WB.write32(`ADDR_EP_MACH, 'haabb);  // assign a dummy MAC address
      WB.write32(`ADDR_EP_MACL, 'hccddeeff);
      WB.write32(`ADDR_EP_TSCR, `EP_TSCR_EN_RXTS);
   endtask // initialize_EP_regs


   // sets the Q-mode of the endpoint
   task ep_set_qmode(int qmode);
      reg[31:0] rfcr;
      string s;
      
      case (qmode)
	`EP_QMODE_ACCESS: s="ACCESS"; 
	`EP_QMODE_TRUNK: s="TRUNK";
	`EP_QMODE_UNQ: s="UNQUALIFIED";
      endcase // case (qmode)    
      $display("Setting qmode to: %s", s);
      
      WB.read32(`ADDR_EP_RFCR, rfcr);
      rfcr  = rfcr & (~`EP_RFCR_QMODE);
      rfcr  = rfcr | ( qmode << `EP_RFCR_QMODE_OFFSET);
      WB.write32(`ADDR_EP_RFCR, rfcr);

     endtask // ep_set_qmode
   

  // sets the VLAN ID/Priority for ACCESS port
   task ep_set_vlan(input [11:0] vid, input [2:0] prio);
      reg[31:0] rfcr;
      WB.read32(`ADDR_EP_RFCR, rfcr);
      rfcr  = rfcr & ~(`EP_RFCR_VID_VAL | `EP_RFCR_PRIO_VAL);
      rfcr  = rfcr | ( vid << `EP_RFCR_VID_VAL_OFFSET ) | ( prio << `EP_RFCR_PRIO_VAL_OFFSET);
      WB.write32(`ADDR_EP_RFCR, rfcr);
   endtask // ep_set_vlan
  
   task ep_size_check(int runts, int giants);
      reg[31:0] rfcr;

      WB.read32(`ADDR_EP_RFCR, rfcr);
      rfcr 	       = rfcr & ~(`EP_RFCR_A_RUNT | `EP_RFCR_A_GIANT);
      if(!runts) rfcr  = rfcr | `EP_RFCR_A_RUNT;
      if(!giants) rfcr  = rfcr | `EP_RFCR_A_GIANT;
      WB.write32(`ADDR_EP_RFCR, rfcr);
   endtask // ep_frame_check
   
   


   initial begin
      CWRFFrameSink snk;
      ether_frame_t fra;
      
      snk  = new(wrf_sink.get_accessor());
      
      forever
	snk.rx_frame(fra);
	
	// new
	$display("[received] ^^^^^^ status register %x^^^^^^^",stat_reg);
	////////
   end
   

   initial begin
      automatic  int k;
      automatic int data[1600];
      automatic int i;
      ether_header_t hdr;
      ether_frame_t fra;
      wb_cycle_result_t result;

      reg [31:0] reg_lacr;
      
  const bit[7:0] payload[] = '{
			       'h00, 'h01, 'h08, 'h00, 'h06, 'h04, 'h00, 'h01, 'h00, 'h50, 
			       'hfc, 'h96, 'h9b, 'h0e, 'hc0, 'ha8, 'h01, 'h01, 'h00, 'h00, 'h00, 'h00, 'h00, 'h00, 'hc0, 'ha8,
'h01, 'h02, 
'h00, 'h00, 
'h00, 'h00, 
'h00, 'h00, 
'h00, 'h00, 
'h00, 'h00, 
'h00, 'h00, 
'h00, 'h00, 
'h00, 'h00, 
'h00, 'h00,
 'h01};
            CWRFFrameGenerator gen_a;
      
      CWishboneAccessor acc;

      repeat(100) @(posedge clk_sys);
      //CIWBMasterAccessor acc; //ML
    
          #100;
    
      //acc = CWishboneAccessor'(wrf_source_a.get_accessor());
      acc = wrf_source_a.get_accessor();//ML
      
      gen_a = new(acc);

      // configure some EP registers
      initialize_EP_regs();
     
//      hdr.dst 	     = 'hffffffffffff;
//      hdr.src 	     = 'h0050fc969b0e;
      
//      hdr.is_802_1q  = 0;
//      hdr.ethertype  = 'h0806;
//      hdr.oob_type   = `OOB_TYPE_TXTS;
//      hdr.oob_fid    = 'hcaca;
      
//      for(i=0;i<47;i++) data[i] = payload[i];
 
      hdr.dst 	     = 'hda0203040506;
      hdr.src 	     = 'h5a0203040506;
      
      hdr.is_802_1q  = 0;
      hdr.ethertype  = 'h0003;
      hdr.oob_type   = `OOB_TYPE_TXTS;
      hdr.oob_fid    = 'hbabe;

      fra.hdr 	     = hdr;
      
      for(k=0;k<1518;k++)
	fra.payload[k] = (k + 1) & 'hff;

      $display("-------- StartTX-------------");

     ///////// new
     
     for(k=0;k<3;k++) 
     begin
       $display("[send] ~~~~~~~ START generation of a frame~~~~~~~ ");	 

       WBconfig.write32('h0,       100); // payload size
       WBconfig.write32('h4,         0); // payload icrement
       WBconfig.write32('h8,        5); // number of frames to be genereated
       
     WBconfig.write32('hc,'b00000001); //  non-vlan | single | non-fec | 0 | start
     //WBconfig.write32('hc,'b00000101); //  non-vlan | single |     fec | 0 | start
     //WBconfig.write32('hc,'b00010101); //      vlan | single |     fec | 0 | start
     //WBconfig.write32('hc,'b00011001); //      vlan | contin | non-fec | 0 | start
       
       
       WBconfig.read32 ('h10,   stat_reg);
    

       while(!stat_reg[1]) 
       begin
         #1;
         WBconfig.read32 ('h10,   stat_reg);
       end;
       
       //ctrl_reg <=2; // stop
       WBconfig.write32('hc,'b00000010);
       WBconfig.read32 ('h10,  stat_reg);
       
       while(stat_reg[1]) 
       begin
         #1;
         WBconfig.read32 ('h10,   stat_reg);
       end;
       
       $display("[send] ~~~~~~~ generated frame with payload: %d bytes~~~~~~~ ",payload_size);	 
     end
     
     
     
/*     
     for(k=0;k<3;k++) 
     begin
       $display("[send] ~~~~~~~ START generation of a frame~~~~~~~ ");	 
       payload_size <= 100;
       increment_size <=50;
       gen_frame_number <=10;
       ctrl_reg <=1; // start
       
       while(!stat_reg[1]) #1;
       
       ctrl_reg <=2; // stop
        
       while(stat_reg[1]) #1;
       
       $display("[send] ~~~~~~~ generated frame with payload: %d bytes~~~~~~~ ",payload_size);	 
     end
*/     
     for(k=0;k<3;k++) #1;
     $display("finished");	






   end //initial
   

endmodule // main
