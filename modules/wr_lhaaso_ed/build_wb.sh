#!/bin/bash

mkdir -p doc
wbgen2 -D ./doc/lhaaso_ed.html -V lhaaso_ed_wb.vhd -C lhaaso_ed_regs.h --cstyle struct --lang vhdl -K ../../sim/lhaaso_ed_regs.v lhaaso_ed_wb.wb
