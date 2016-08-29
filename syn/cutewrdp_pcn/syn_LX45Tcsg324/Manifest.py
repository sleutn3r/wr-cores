target = "xilinx"
action = "synthesis"

fetchto = "../../../ip_cores"

#top_module = "spec_top"
syn_device = "xc6slx45t"
syn_grade = "-3"
syn_package = "csg324"
syn_top = "cutewrdp_pcn"
syn_project = "cutewrdp_pcn.xise"
syn_tool = "ise"

modules = { "local" : 
						[ "../../../top/cutewrdp/cutewrdp_pcn", 
						  "../../../platform" ],
	    "git" : 
						[ "git://ohwr.org/hdl-core-lib/general-cores.git",
						  "git://ohwr.org/hdl-core-lib/gn4124-core.git",
						  "git://ohwr.org/hdl-core-lib/etherbone-core.git" ] };
