`ifndef SIMDRV_DEFS_SV
`define SIMDRV_DEFS_SV 1

virtual class CBusAccessor;
   pure virtual task write32(int addr, bit[31:0] data); 
   pure virtual task read32(int addr, output bit[31:0] rdata);
endclass // CBusAccessor

`endif