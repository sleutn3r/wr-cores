sim_tool="modelsim"
top_module="main"
action = "simulation"
fetchto = "../../../ip_cores"
target="xilinx"
vlog_opt = "+incdir+../../../sim"
syn_device="xc5vsx50t"

files = [ "main.sv" ]

modules = { "local" :  "../../top/virtex5_kit" }



