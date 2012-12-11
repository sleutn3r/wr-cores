`timescale 1ps/1ps
   
`include "tbi_utils.sv"

`include "simdrv_defs.svh"
`include "if_wb_master.svh"

module i2c_slave ( input scl, input sda );

   reg [7:0] rx_byte;
   int       bit_count = 0;
   
   always@(negedge sda) if(scl) 
     begin
        $display("i2c-start");
        bit_count = 0;
        rx_byte = 0;
     end

   always@(posedge scl)
     begin
        if(bit_count < 8)
          begin
             rx_byte[7-bit_count] <= sda;
             bit_count++;
             
          end else begin
            $display("RX : %x",rx_byte);
             bit_count = 0;
          end


        
     end
   
   
   always@(posedge sda) if(scl) $display("i2c-stop");

   
   
endmodule // i2c_slave

   

module main;

   wire scl_oen, sda_oen, scl, sda;
   
   reg [15:0] dac_val = 0;
   reg        dac_val_wr = 0;
   
   reg rst_n = 0;
   reg clk_sys = 0;
   

   parameter time g_sys_period = 16ns;
   
   always #(g_sys_period/2) clk_sys <= ~clk_sys;
   initial #100ns rst_n <= 1;
   
   
   IWishboneMaster U_WB (
      .clk_i(clk_sys),
      .rst_n_i(rst_n)); 

   
   si570_if DUT (
             .clk_sys_i(clk_sys),
             .rst_n_i(rst_n),
             .tm_dac_value_i(dac_val),
             .tm_dac_value_wr_i(dac_val_wr),

             .scl_pad_oen_o(scl_oen),
             .sda_pad_oen_o(sda_oen),
             .scl_pad_i(scl),
             .sda_pad_i(sda),
             .wb_adr_i      (U_WB.master.adr),
	     .wb_dat_i      (U_WB.master.dat_o),
	     .wb_dat_o      (U_WB.master.dat_i),
	     .wb_sel_i       (4'b1111),
	     .wb_we_i        (U_WB.master.we),
	     .wb_cyc_i       (U_WB.master.cyc),
	     .wb_stb_i       (U_WB.master.stb),
	     .wb_ack_o       (U_WB.master.ack),
             .wb_stall_o     (U_WB.master.stall)
      
             );

   i2c_slave Slave(scl, sda);
   
   
   assign scl = (!scl_oen ? 1'b0 : 1'bz);
   assign sda = (!sda_oen ? 1'b0 : 1'bz);
   pullup(scl);
   pullup(sda);
   
   initial begin
      CWishboneAccessor acc;
      uint64_t rv;
      
      @(posedge rst_n);
      repeat(3) @(posedge clk_sys);

      #1us;
      
      acc  = U_WB.get_accessor();
      acc.set_mode(PIPELINED);
//      acc.set_granularity(BYTE);


      @(posedge clk_sys);
      dac_val <= 'hcafe;
      dac_val_wr <= 1;
      @(posedge clk_sys);
      dac_val_wr <= 0;
      @(posedge clk_sys);
      
      
   end
   
   
endmodule // main

