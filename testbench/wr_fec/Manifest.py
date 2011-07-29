#target = "xilinx"
target = "altera"
action = "simulation"
modules = {"local": "../../modules/wr_fec"}


#files = "wr_fec_engine.sv"
#files = "wr_generate_and_fec.sv"
#files = "wr_fec.sv"

files=["wr_fec.sv", "wr_generate_and_fec.sv", "wr_generate_and_fec_with_wrf.sv"]

vsim_opt = '-voptargs="+acc"'
vlog_opt = "+incdir+wbp"
