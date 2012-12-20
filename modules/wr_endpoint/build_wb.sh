#!/bin/bash

mkdir -p doc
wbgen2 -D ./doc/wrsw_endpoint.html ep_wishbone_controller.wb
~/Development/repos/wishbone-gen-git/wbgen2 -C endpoint_regs.h -p ep_registers_pkg.vhd -H record -V ep_wishbone_controller.vhd  --cstyle struct --lang vhdl -K ../../sim/endpoint_regs.v ep_wishbone_controller.wb
wbgen2 -D ./doc/wrsw_endpoint_mdio.html pcs_regs.wb
~/Development/repos/wishbone-gen-git/wbgen2 -V ep_pcs_tbi_mdio_wb.vhd --cstyle defines --lang vhdl -K ../../sim/endpoint_mdio.v pcs_regs.wb
