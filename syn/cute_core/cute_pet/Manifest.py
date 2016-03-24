target = "xilinx"
action = "synthesis"

fetchto = "../../../ip_cores"

#top_module = "spec_top"
syn_device = "xc6slx45t"
syn_grade = "-3"
syn_package = "fgg484"
syn_top = "cute_pet"
syn_project = "cute_pet_wrc.xise"
syn_tool = "ise"

modules = { "local" : 
						[ "../../../top/cute_core/cute_pet", 
						  "../../../platform" ],
	    "git" : 
						[ "git://ohwr.org/hdl-core-lib/general-cores.git",
						  "git://ohwr.org/hdl-core-lib/gn4124-core.git",
						  "git://ohwr.org/hdl-core-lib/etherbone-core.git" ] };
