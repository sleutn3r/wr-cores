#!/bin/bash

mkdir -p doc
wbgen2 -D ./doc/wrdp_syscon.html -p wrdp_syscon_pkg.vhd -H record -V wrdp_syscon_wb.vhd -C wrdp_syscon_regs.h --cstyle defines --lang vhdl -K ../../sim/wrdp_syscon_regs.vh wrdp_syscon_wb.wb
