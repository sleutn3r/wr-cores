// Fabric emulator example, showing 2 fabric emulators connected together and exchanging packets.

`define c_clock_period              8

`timescale 1ns / 1ps

`include "wr_fec_defs.sv"

//wisbone input
`define  wishbone_address_width_in	 32
`define  wishbone_data_width_in		   32

// wishbone output
`define  wishbone_address_width_out	16
`define  wishbone_data_width_out		  16

`define array_copy(a, ah, al, b, bl) \
   for (k=al; k<=ah; k=k+1) a[k] <= b[bl+k-al];


module main;

   
   reg clk 		       = 0;
   reg rst_n 		     = 0;

   reg [`wishbone_data_width_in-1 : 0]        wbs_dat_i;	
   reg [`wishbone_address_width_in-1: 0]      wbs_adr_i;
   reg [(`wishbone_address_width_in/8)-1 : 0] wbs_sel_i;
   reg wbs_cyc_i	   ;
   reg wbs_stb_i	   ;
   reg wbs_we_i	    ;
   reg wbs_stall_o	 ;
   reg wbs_ack_o	   ;
  
   reg [`wishbone_data_width_out-1 : 0]        wbs_dat_o;
   reg [`wishbone_address_width_out-1 : 0]     wbs_adr_o;
   reg [(`wishbone_address_width_out/8)-1 : 0] wbs_sel_o;
   reg wbs_cyc_o	  ;
   reg wbs_stb_o	  ;
   reg wbs_we_o	   ;
   reg wbs_stall_i ;
   reg wbs_ack_i	  ; 
   
   
   // generate clock and reset signals
   always #(`c_clock_period/2) clk <= ~clk;
   
   initial begin 
      repeat(3) @(posedge clk);
      rst_n  = 1;
   end
  
  
  wr_fec
    DTU( 
    .wbs_dat_i  (wbs_dat_i),   
    .wbs_adr_i  (wbs_adr_i),
    .wbs_sel_i  (wbs_sel_i),
    .wbs_cyc_i  (wbs_cyc_i),
    .wbs_stb_i  (wbs_stb_i),
    .wbs_we_i	  (wbs_we_i),
    .wbs_stall_o(wbs_stall_o),
    .wbs_ack_o	 (wbs_ack_o),
   
    .wbs_dat_o  (wbs_dat_o),
    .wbs_adr_o	 (wbs_adr_o),
    .wbs_sel_o	 (wbs_sel_o),
    .wbs_cyc_o	 (wbs_cyc_o),
    .wbs_stb_o	 (wbs_stb_o),
    .wbs_we_o	  (wbs_we_o),
    .wbs_stall_i(wbs_stall_i),
    .wbs_ack_i	 (wbs_ack_i)
  );
  
    task automatic wait_cycles;
       input [31:0] ncycles;
       begin : wait_body
    integer i;
 
    for(i=0;i<ncycles;i=i+1) @(posedge clk);
 
       end
    endtask // wait_cycles

    
    task automatic input_header;
       input ether_header_t hdr; 
       input int length;
    begin : input_header_body
      
       reg [15:0] data_vec[0:2000];
       int tot_len; 
       int i;
       integer k; // for the macro array_copy()
 
       for(i=0;i<2000;i++) data_vec[i]=0; 
       data_vec [0] = hdr.dst[47:32];
       data_vec [1] = hdr.dst[31:16];
       data_vec [2] = hdr.dst[15:0];
 
 
       if(!hdr.no_mac) begin
         data_vec [3] = hdr.src[47:32];
         data_vec [4] = hdr.src[31:16];
         data_vec [5] = hdr.src[15:0];
       end else begin
         data_vec [3] = 0;
         data_vec [4] = 0;
         data_vec [5] = 0;
       end
       
       if(hdr.is_802_1q) begin
         data_vec [6] = 'h8100;
         data_vec [7] = hdr.ethertype;
         data_vec [8] = hdr.vid | (hdr.prio << 13);
         tot_len 		   = 9;
       end else begin
         data_vec [6] = hdr.ethertype;
         tot_len 		   = 7;
       end
        
         wbs_stb_i <=1;
         for(int i = 0; i<(tot_len+1)/2; i++)
         begin
           
           wbs_dat_i 	<= (data_vec[i*2] << 16 ) |  data_vec[i*2+1];
           wait_cycles(1);           
           $display("copying:  %x",((data_vec[i*2] << 16 ) |  data_vec[i*2+1]));     
                         
         end; //for
         wbs_stb_i <=0;       
     end//body
    endtask // send
            
   task automatic input_payload;
      input int                       payload[]; 
      input int                       length;
      begin : input_payload_body            
        
        reg [`wishbone_data_width_in-1:0] data_vec[0:2000];
        int i;
        integer k; //for the array_copy macro
        
        wbs_stb_i <=1;
        for(int i = 0; i<(length+3)/4; i++)
        begin

            wbs_dat_i 	<= (payload[i*4+3] << 24) | (payload[i*4+2] << 16) |
                          (payload[i*4+1] << 8 ) |  payload[i*4+0];
            wait_cycles(1);
        end; //for
        wbs_stb_i <=0;
        

          
      end//body
   endtask  
  
//////////////////////////////////////////////////////////              

   initial begin
      
     
     ether_header_t hdr;
     int buffer[1500];
     int i;
     
     wbs_dat_i  <=0;
     wbs_adr_i  <=0;
     wbs_sel_i  <=0;
     wbs_cyc_i  <=0;
     wbs_stb_i  <=0;
     wbs_we_i	  <=0;
    
     wbs_stall_i<=0;
     wbs_ack_i	 <=0;
     
     ////////////initialize with data
     //header
     hdr.src 	       = 'h123456789abcdef;
     hdr.dst 	       = 'hcafeb1badeadbef;
     hdr.ethertype    = 1234;
     hdr.is_802_1q    = 0;
     
     //payload 
     for(i=0;i<1500;i++)
       buffer[i]      = i; 
     
     
     wait_cycles(10);
     $display("=======loading data to FEC engine======");
     
     wbs_cyc_i <= 1;
     wbs_stb_i  <=1;
     wbs_adr_i <= 1;
     wbs_dat_i <= 99;
     wait_cycles(1);  
     wbs_adr_i <= 0;
     
     input_header(hdr, 99);
     input_payload(buffer, 99);
     wbs_cyc_i <= 1;
          
   end
   
        
//////////////////////////////////////////////////////////


   always @(posedge clk) 
     begin

        
     end
   
	      
        
endmodule // main
