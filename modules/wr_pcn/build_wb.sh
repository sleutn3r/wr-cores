#!/bin/bash
mkdir -p doc
wbgen2 -D ./doc/pcn_wb_slave.html -C pcn_regs.h -s struct -l vhdl -V pcn_wb_slave.vhd -H record -p pcn_wbgen2_pkg.vhd pcn_wb_slave.wb 
