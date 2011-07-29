#fec staff
modules = {"git":"git://ohwr.org/hdl-core-lib/general-cores.git","local": ["../wr_fec", "../../../../../wrdev_v3/hdl/platform/altera_nf"] }

###########################################

files = [ "wr_core_with_fec.vhd",
					"wrc_dpram.vhd",
					"wrcore_pkg.vhd",
					"wrc_periph.vhd",
					"wb_reset.vhd" ];


fetchto = "../../ip_cores"

