`timescale 1ns/1ps


module main;

  reg clk_ref = 0;
   wire clk_sys;
   wire rst_n;
   wire loop2_n, loop2_p, loop1_n, loop1_p;

   reg clk_vcxo = 0;

   always #4ns clk_ref <= ~clk_ref;
    
   
 v5_top 
#(.g_simulation(1))
DUT
   (
    .clk_125m_pllref_p_i (clk_ref),
    .clk_125m_pllref_n_i (~clk_ref),
    .gtp_clk_p_i (clk_ref),
    .gtp_clk_n_i (~clk_ref),
    .button1_n_i(1'b0),  
    .sfp_txp_o(loop1_p),
    .sfp_txn_o(loop1_n),
    .sfp_rxp_i(loop2_p),
    .sfp_rxn_i(loop2_n)
  
    );

 v5_top
#(.g_simulation(1))
 DUT2
   (
    .clk_125m_pllref_p_i (clk_ref),
    .clk_125m_pllref_n_i (~clk_ref),
    .gtp_clk_p_i (clk_ref),
    .gtp_clk_n_i (~clk_ref),
    .button1_n_i(1'b0),
    .sfp_txp_o(loop2_p),
    .sfp_txn_o(loop2_n),
    .sfp_rxp_i(loop1_p),
    .sfp_rxn_i(loop1_n)

    );
   
endmodule // main

