target = "xilinx"
action = "synthesis"

fetchto = "../../../ip_cores"

syn_device = "xc6slx45t"
syn_grade = "-3"
syn_package = "fgg484"
syn_top = "cute_top"
syn_project = "cute_top_wrc.xise"

modules = { "local" :
						[ "../../../top/cute_wr/wr_core_demo",
							"../../../platform",
                                                        "../../../ip_cores/general-cores",
                                                        "../../../ip_cores/etherbone-core"]
					}
