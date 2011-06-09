`timescale 10fs/10fs

module tunable_clock_gen
  (
   input real vtune_i,
   input enable_i,
   output clk_o);

 
   parameter g_tunable 	       = 0;
   parameter g_tuning_range    = 20e-6; // 20 ppm
   parameter g_tuning_voltage  = 1.0;
   parameter real g_period     = 8ns;
   parameter real g_jitter     = 10ps;

   reg clk 		       = 1'b1;

   real cur_offset 	       = 0;
   real prev_err 	       = 0;
   real next_offset;
   real cur_err;
   real cur_period;
   int seed  = 1;

   real max_range;

   
   initial begin
      cur_offset   = 0;
      prev_err 	   = 0;
   end
   
   
   initial forever 
     if(enable_i) 
       begin
	  seed 	   = $urandom(seed);

	  
	  cur_err  = (real'($urandom_range(0, 1000)) -500.0)/ 1000.0 * g_jitter;


//	  $display("%.15f %.15f", cur_err, g_jitter);
	  
	  
	  if(g_tunable)
	    begin
	       realtime period_tune;



	       period_tune   = realtime'(real'(g_period/2) * (vtune_i-(real'(g_tuning_voltage/2)))/(real'(g_tuning_voltage/2)) * real'(g_tuning_range));
	       
		  
		 cur_period  = g_period/2 + period_tune ;
	       
	    end else
	      cur_period     = g_period/2;
	  
	  
	  next_offset 	     = -prev_err + cur_period + cur_err;
	  
	  prev_err 	     = cur_err;

//	  $display("NextOffs: %.15f", next_offset);
	  
	  #(integer'(next_offset)) clk = ~clk;
	  
	  end else begin // if (enable)
	     cur_offset  = 0;
	     cur_period  = 0;
	     clk 	 = 1;
	     #1;
	  end // else: !if(enable)

   assign clk_o 	 = clk;
endmodule // tunable_clock_gen