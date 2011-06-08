files = [ "wr_core.vhd",
					"wrc_dpram.vhd",
					"wrcore_pkg.vhd",
					"wrc_periph.vhd",
					"wb_reset.vhd" ];

fetchto = "../../ip_cores"

modules = {"git" :  [
					            "git@ohwr.org:hdl-core-lib/wr-cores.git",
                      "git@ohwr.org:hdl-core-lib/general-cores.git" ] };
