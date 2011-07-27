// Fabric emulator example, showing 2 fabric emulators connected together and exchanging packets.

`define c_clock_period              8
//////// two interdependant variable////////////////////////
`define c_in_engine_data_width      16//32//8
`define c_fec_engine_Byte_sel_num    2 // depends on 
//////////////////////////////////////////////////////////
`define c_fec_payload_size_MAX      (1500*8)
`define c_fec_header_size           (46*8)
`define c_ethernet_frame            (`c_fec_payload_size_MAX + `c_fec_header_size)
`define c_fec_out_MSG_num_MAX       8
`define c_fec_msg_size_Bytes_width        11 //13 //ceil(log2(5000 - 1))
`define c_fec_msg_size_bits_width       14// 16 //ceil(log2(5000*8 - 1))
`define c_fec_out_MSG_num_MAX_width 3 //CEIL(LOG2(8 - 1));
`define c_fec_FEC_header_FEC_ID_bits 32

`timescale 1ns / 1ps

`include "wr_fec_defs.sv"

`define array_copy(a, ah, al, b, bl) \
   for (k=al; k<=ah; k=k+1) a[k] <= b[bl+k-al];


module main;

   
   reg clk 		       = 0;
   reg rst_n 		     = 0;


   reg [`c_in_engine_data_width - 1:0]     if_data_i;
   reg [`c_in_engine_data_width - 1:0]     if_data_o;
   reg [`c_fec_engine_Byte_sel_num -1:0]   if_byte_sel_o;
   reg [`c_fec_msg_size_Bytes_width - 1:0] if_msg_size_i;
   reg                                     if_FEC_ID_ena_i;
   reg [`c_fec_FEC_header_FEC_ID_bits-1:0] if_FEC_ID_i;
   reg [2:0]                               if_in_ctrl_i;
   reg                                     if_in_settngs_ena_i;
   reg                                     if_busy_o;
   reg                                     if_in_ctrl_o;
   //reg [1:0]                               if_out_ctrl_o;
   reg                                     if_out_ctrl_o;
   reg                                     if_out_ctrl_i;
   reg [`c_fec_out_MSG_num_MAX_width-1:0]  if_out_MSG_num_i;
   

   
   
   // generate clock and reset signals
   always #(`c_clock_period/2) clk <= ~clk;
   
   initial begin 
      repeat(3) @(posedge clk);
      rst_n  = 1;
   end
  
  
  wr_fec_engine
    DTU( 
    
    .clk_i                 (clk),
    .rst_n_i               (rst_n),
        
     //input data to be encoded
     .if_data_i            (if_data_i),
     
     // encoded data
     .if_data_o            (if_data_o),
     
	
     //indicates which Bytes of the output data have valid data
     .if_byte_sel_o        (if_byte_sel_o),
     
     // size of the incoming message to be encoded (entire Control Message)
     .if_msg_size_i        (if_msg_size_i),
     
	
     // tells FEC whether use FEC_ID provided from outside word (HIGH)
     // or generate it internally (LOW)
     .if_FEC_ID_ena_i      (if_FEC_ID_ena_i),
     
     // ID of the message to be FECed, used only if if_FEC_ID_ena_i=HIGH
     .if_FEC_ID_i          (if_FEC_ID_i),
	
     // information what the engine is supposed to do:
     // 0 = do nothing
     // 1 = header is being transfered
     // 2 = payload to be encoded is being transfered
     // 3 = transfer pause
     // 4 = message end
     .if_in_ctrl_i          (if_in_ctrl_i),
     
     // strobe when settings (msg size and output msg number) available
     .if_in_settngs_ena_i    (if_in_settngs_ena_i),
     
     // kind-of-flow control:
     // 0 = ready for data
     // 1 = pause
     .if_in_ctrl_o          (if_in_ctrl_o),
     
     // indicates whether engine is ready to encode new Control Message
     // 0 = idle
     // 1 = busy
     .if_busy_o             (if_busy_o),
     // info about output data
     // 0 = no data ready
     // 1 = outputing header 
     // 2 = outputing payload
     // 3 = output pause 
     .if_out_ctrl_o         (if_out_ctrl_o),
     
     // indicates whether output interface is ready to take data
     // 0 = ready
     // 1 = busy     
     .if_out_ctrl_i         (if_out_ctrl_i),
     
     // info on desired number of output messages, should be available 
     // at the same time as
     .if_out_MSG_num_i      (if_out_MSG_num_i)

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
        
       if_data_i <=0;
       
       // set control 
       if_in_ctrl_i  <= 1;
       if_msg_size_i <= length; 
       //send header  
       
       ///////// width = 8 bits ///////////////
       if(`c_in_engine_data_width == 8) begin
         for(int i = 0; i<tot_len; i++)
         begin
           
           if( i == tot_len/2) if_in_settngs_ena_i <= 1;
             
           if_data_i <=   data_vec[i];
           wait_cycles(1);  
           $display("copying: %x <= %x",if_data_i,data_vec[i]);

           if_data_i <=  (data_vec[i]>>8);
           wait_cycles(1);  
           $display("copying: %x <= %x",if_data_i,data_vec[i]);
            
           if_in_settngs_ena_i <=0;    
          end; //for
       end;//if
       
       ///////// width = 16 bits ///////////////        
       if(`c_in_engine_data_width == 16) begin
         for(int i = 0; i< tot_len; i++)
         begin
           
           if( i == tot_len/2) if_in_settngs_ena_i <= 1;
             
           if_data_i 	<= data_vec[i];
           wait_cycles(1);
           $display("copying: %x <= %x",if_data_i,data_vec[i]);
           if_in_settngs_ena_i <=0;  
           
         end; //for
       end; //if
       
       ///////// width = 32 bits ///////////////        
       if(`c_in_engine_data_width == 32) begin
         for(int i = 0; i<(tot_len+1)/2; i++)
         begin
           
           if( i == tot_len/2) if_in_settngs_ena_i <= 1;

           if_data_i 	<= (data_vec[i*2] << 16 ) |  data_vec[i*2+1];
           wait_cycles(1);           
           $display("copying: %x <= %x",if_data_i,((data_vec[i*2] << 16 ) |  data_vec[i*2+1]));     
           if_in_settngs_ena_i <=0;  
                         
         end; //for
       end; //if
       
       if_in_settngs_ena_i <=0;
     end//body
    endtask // send
            
   task automatic input_payload;
      input int                       payload[]; 
      input int                       length;
      begin : input_payload_body            
        
        reg [`c_in_engine_data_width-1:0] data_vec[0:2000];
        int i;
        integer k; //for the array_copy macro
        
        if_in_ctrl_i        <= 2;

        // this is conversion from int to register
        // it accomodates different withs of input stream
        // of FEC engine
        
        ///////// width = 8 bits ///////////////
        if(`c_in_engine_data_width == 8) begin
          for(int i = 0; i<length; i++)
          begin
            if_data_i 	<= payload[i] ;
            wait_cycles(1);     
           end; //for
        end;//if
        
        ///////// width = 16 bits ///////////////        
        if(`c_in_engine_data_width == 16) begin
          for(int i = 0; i<(length+1) / 2; i++)
          begin
            if((i == (length-1) / 2) && (length%2!=0)) if_data_i 	<=     payload[i*2];
            else if_data_i 	<= (payload[i*2+1] << 8) | payload[i*2];
              
            wait_cycles(1);
          end; //for
        end; //if
        
        ///////// width = 32 bits ///////////////        
        if(`c_in_engine_data_width == 32) begin
          for(int i = 0; i<(length+3)/4; i++)
          begin

            if_data_i 	<= (payload[i*4+3] << 24) | (payload[i*4+2] << 16) |
                          (payload[i*4+1] << 8 ) |  payload[i*4+0];
            wait_cycles(1);
          end; //for
        end; //if
        
        if_in_ctrl_i        <= 4;
          
      end//body
   endtask  
  
//////////////////////////////////////////////////////////              

   initial begin
      
     
     ether_header_t hdr;
     int buffer[1500];
     int i;
     
     ////////////initialize with data
     //header
     hdr.src 	       = 'h123456789abcdef;
     hdr.dst 	       = 'hcafeb1badeadbef;
     hdr.ethertype    = 1234;
     hdr.is_802_1q    = 0;
     
     //payload 
     for(i=0;i<1500;i++)
       buffer[i]      = i; 
     
     if_msg_size_i       <= 0;
     if_in_ctrl_i        <= 0;
     if_out_ctrl_i       <= 0;
     if_out_MSG_num_i    <= 0;
     if_in_settngs_ena_i <= 0;
     if_FEC_ID_ena_i     <= 0;
     if_FEC_ID_i         <= 0;
     
     wait_cycles(10);
     $display("=======loading data to FEC engine======");
     
     while(if_busy_o==1) wait_cycles(1);  

       
     input_header(hdr, 99);
    
     input_payload(buffer, 99);
     
    
          
   end
   
        
//////////////////////////////////////////////////////////


   always @(posedge clk) 
     begin
       int i,j;
       int z;
       int word;
       int p;
       int bits;
       reg [144 - 1:0]  out_d;
       reg [15:0]data[9];
       //int data[8];
       reg [7:0] parity[2];
       reg [16-1:0] data_vec[8];
       
       z=0;
       word = 0;
       p = 0;
       out_d <= 0;
       if(if_out_ctrl_o == 1) begin
         if(i<7) $display("[%d] Ethernet header %x",i,if_data_o)  ;
         else if(i<11)$display("[%d] FEC header %x",i,if_data_o)  ;
         else  begin
           out_d <=  (if_data_o << bits) | out_d;
           $display("[%d] out_d = %x if_data_o = %x bits = %d",i,out_d,if_data_o,bits)  ;
           if(bits == 144) begin
             bits = 0;
             word = 0;
             for(j=0;j<144;j++) begin
               case (j)
               0:   parity[0][0]   <= out_d[j]; 
               1:   parity[0][1]   <= out_d[j]; 
               2:   parity[0][2]   <= out_d[j]; 
               4:   parity[0][3]   <= out_d[j]; 
               8:   parity[0][4]   <= out_d[j]; 
               16:  parity[0][5]   <= out_d[j]; 
               32:  parity[0][6]   <= out_d[j]; 
               64:  parity[0][7]   <= out_d[j];
               72:  parity[1][0]   <= out_d[j]; 
               73:  parity[1][1]   <= out_d[j]; 
               74:  parity[1][2]   <= out_d[j]; 
               76:  parity[1][3]   <= out_d[j]; 
               80:  parity[1][4]   <= out_d[j]; 
               88:  parity[1][5]   <= out_d[j]; 
               104: parity[1][6]   <= out_d[j]; 
               136: parity[1][7]   <= out_d[j]; 
               default : data[word][z++ % 16] <= out_d[j];
               endcase
               if((z-1)%16==0 && j > 16)word++;
               //wait_cycles(1);  
             end 
             
               for(j=0;j<4;j++) $display("data = %16x , parity = %x",data[j],parity[0]);
               for(j=5;j<9;j++) $display("data = %16x , parity = %x",data[j],parity[1]);
               
               out_d <=  (if_data_o << bits) ;
           end
           else bits = bits + 16;
         end
         i++;
       end 
        
     end
   
	      
        
endmodule // main
