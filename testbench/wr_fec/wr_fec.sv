/*
------------------------------------------------------------------------
-- Title      : Forward Error Correction
-- Project    : WhiteRabbit Node
-------------------------------------------------------------------------------
-- File       : wr_fec.sv
-- Author     : Maciej Lipinski
-- Company    : CERN BE-Co-HT
-- Created    : 2011-04-12
-- Last update: 2011-04-12
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: thsi is a System Verilog testbench which tests FEC encoder
-- 
-- It uses Tomek's simulation of Wishbone pipelined interface (in ./wbp)
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



//module main;
module wr_fec_only;

   wire clk_ref;
   wire clk_sys;
   wire rst_n;

  // WRF links
   
   `WRF_FULL_WIRES(toEP)
   `WRF_FULL_WIRES(fromEP)
  
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



  assign wrf_sink.we = 1'b1;

  wr_fec_en
    DUT(
      .clk_i(clk_sys),
      .rst_n_i(rst_n),

      .wbs_adr_i(wrf_source_a.adr),
      .wbs_dat_i(wrf_source_a.dat_o),
      .wbs_sel_i(wrf_source_a.sel),
      .wbs_cyc_i(wrf_source_a.cyc),
      .wbs_stb_i(wrf_source_a.stb),
      .wbs_we_i(wrf_source_a.we),
//      .wbs_rty_o(wrf_source_a.rty),
      .wbs_err_o(wrf_source_a.err),
      .wbs_stall_o(wrf_source_a.stall),
      .wbs_ack_o(wrf_source_a.ack),
      
      .wbm_adr_o(wrf_sink.adr),
      .wbm_dat_o(wrf_sink.dat_i),
      .wbm_sel_o(wrf_sink.sel),
      .wbm_cyc_o(wrf_sink.cyc),
      .wbm_stb_o(wrf_sink.stb),
      .wbm_we_o(wrf_sink.we),
      .wbm_err_i(wrf_sink.err),
//      .wbm_rty_i(wrf_sink.rty),
      .wbm_stall_i(wrf_sink.stall),
      .wbm_ack_i(wrf_sink.ack)
      
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
      //CIWBMasterAccessor acc; //ML

        repeat(100)@(posedge clk_sys);
    
          #100;
    
      //acc = CWishboneAccessor'(wrf_source_a.get_accessor());
      acc = wrf_source_a.get_accessor();//ML
      
      gen_a = new(acc);

      // configure some EP registers
      initialize_EP_regs();
 
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

      for(i=0;i<20;i++)
	begin
     $display("[send] ~~~~~~~ sending frame nr=%d of size=%d~~~~~~~ ",i,(i+100));	  
	   fra.size 	= i*50+100;
	   
	   gen_a.send(fra,1 // 1: with FEC, 0: without FEC 
	                 ,1 // 1: with OOB, 0: without OOB
	                 ,0 // indicates the word address on which STATUS error occurs, 0: no errors
	                 , result);
	    $display("[send] ^^^^^^ finished sending frame %d^^^^^^^",i);
	end
     

   end
   

endmodule // main
