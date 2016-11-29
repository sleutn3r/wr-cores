set_global_assignment -entity "arria5_ext_ref_pll_default" -library "lib_arria5_ext_ref_pll_default" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "arria5_ext_ref_pll_default" -library "lib_arria5_ext_ref_pll_default" -name IP_TOOL_VERSION "16.0"
set_global_assignment -entity "arria5_ext_ref_pll_default" -library "lib_arria5_ext_ref_pll_default" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_arria5_ext_ref_pll_default" -name SPD_FILE [file join $::quartus(sip_path) "arria5_ext_ref_pll_default.spd"]

set_global_assignment -library "lib_arria5_ext_ref_pll_default" -name MISC_FILE [file join $::quartus(sip_path) "arria5_ext_ref_pll_default_sim/arria5_ext_ref_pll_default.vho"]
