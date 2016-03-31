target = "xilinx"
action = "synthesis"

fetchto = "../../../ip_cores"

#top_module = "spec_top"
syn_device = "xc6slx45t"
syn_grade = "-3"
syn_package = "csg324"
syn_top = "cutewr_dp"
syn_project = "cutewr_dp.xise"
syn_tool = "ise"

modules = { "local" : 
						[ "../../../top/cute_dp/cutewr_dp", 
						  "../../../platform" ],
	    "git" : 
						[ "git://ohwr.org/hdl-core-lib/general-cores.git",
						  "git://ohwr.org/hdl-core-lib/gn4124-core.git",
						  "git://ohwr.org/hdl-core-lib/etherbone-core.git" ] };
