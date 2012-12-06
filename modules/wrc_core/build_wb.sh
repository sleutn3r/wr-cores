#!/bin/bash

mkdir -p doc
wbgen2 -D ./doc/wrc_syscon.html -p wrc_syscon_pkg.vhd -H record -V wrc_syscon_wb.vhd -C wrc_syscon_regs.h --cstyle defines --lang vhdl -K ../../sim/wrc_syscon_regs.vh wrc_syscon_wb.wb
wbgen2  -p si570_if_wbgen2_pkg.vhd -H record -V si570_if_wb.vhd -C si570_if_wb.h --cstyle defines --lang vhdl -K ../../sim/si570_if_regs.vh si570_if_wb.wb
