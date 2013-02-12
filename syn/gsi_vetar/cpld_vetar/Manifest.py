target = "xilinx"
action = "synthesis"

fetchto = "../../../ip_cores"

syn_device = "xc2c512"
syn_grade = "-7"
syn_package = "ft256"
syn_top = "prog_1"
syn_project = "vetar1.xise"

modules = { "local" : 
						[ "../../../top/gsi_vetar/cpld_vetar", 
							"../../../platform" ] 
					}
