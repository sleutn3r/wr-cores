#!/bin/bash

mkdir -p doc
wbgen2 -D ./doc/tdc_cm.html -V tdc_cm_wb.vhd -C tdc_cm_regs.h --cstyle struct --lang vhdl -K ../../sim/tdc_cm_regs.v tdc_cm_wb.wb
