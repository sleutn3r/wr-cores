action = "simulation"
##### fec ######
target = "altera"
##################
fetchto = "../../../ip_cores"
vlog_opt = "+incdir+../../../sim"

files = [ "main.sv", "main_with_fec.sv", "wb_gpio_port_notristates.vhd" ]

modules = { "local" : "../../.." };
					

					
