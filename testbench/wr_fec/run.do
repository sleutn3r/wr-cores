vlib work
vcom ../../../platform/genrams/altera/genram_pkg.vhd
vcom ../../../platform/genrams/altera/generic_async_fifo.vhd
vcom ../../../platform/genrams/altera/generic_dpram.vhd
vcom ../../../platform/genrams/altera/generic_spram.vhd
vcom ../../../platform/genrams/altera/generic_sync_fifo.vhd



vcom ../../../platform/genrams/genram_pkg.vhd

vcom ../../../modules/wr_fec/gf256-pkg.vhd
vcom ../../../modules/wr_fec/parameters.vhd
vcom ../../../modules/wr_fec/RS_erasure.vhd
vcom ../../../modules/wr_fec/hamm_package_64bit.vhd
#vcom ../../../modules/wr_fec/hamming10parity_pkg.vhd
vcom ../../../modules/wr_fec/wr_fec_pkg.vhd
vcom ../../../modules/wr_fec/wr_hamming_pkg.vhd
vcom ../../../modules/wr_fec/wr_fec_engine.vhd
vcom ../../../modules/wr_fec/wr_fec_interface.vhd
#vcom ../../../modules/wr_fec/wr_fec.vhd

vlog -sv wr_fec_engine.sv
#vlog -sv wr_fec.sv

vsim work.main -voptargs="+acc"
radix -hexadecimal
do wave.do

run 3us
wave zoomfull