create_clock -period 100Mhz -name pcie_refclk_i [get_ports {pcie_refclk_i}]
create_clock -period 125Mhz -name clk125_i [get_ports {clk125_i}]
derive_pll_clocks
derive_clock_uncertainty


set_false_path -from {*|gc_wfifo:*|r_idx_gray*} -to {*|gc_wfifo:*|r_idx_shift_w*}
set_false_path -from {*|gc_wfifo:*|r_idx_gray*} -to {*|gc_wfifo:*|r_idx_shift_a*}
set_false_path -from {*|gc_wfifo:*|w_idx_gray*} -to {*|gc_wfifo:*|w_idx_shift_r*}

set_false_path -from [get_clocks {sys_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {BuTis_clock_generator1|PLL125MHz200MHz1|altpll_component|auto_generated|pll1|clk[0]}]

#set_max_delay -from {*|PPS_history_s*} -to {*|PPS_history_sync_s*} 1
#set_max_delay -from [get_clocks {sys_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -through [get_nets {BuTis_clock_generator1|PPS_history_s[0] BuTis_clock_generator1|PPS_history_s[1] BuTis_clock_generator1|PPS_history_s[2] BuTis_clock_generator1|PPS_history_s[3] BuTis_clock_generator1|PPS_history_s[4]}] -to [get_clocks {BuTis_clock_generator1|PLL125MHz200MHz1|altpll_component|auto_generated|pll1|clk[0]}] 1

set_false_path -from [get_clocks {sys_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {BuTis_clock_generator1|PLL200MHzPhaseAdjust1|altpll_component|auto_generated|pll1|clk[0]}]

set_false_path -from [get_clocks {BuTis_clock_generator1|PLL200MHzPhaseAdjust1|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {sys_pll_inst|altpll_component|auto_generated|pll1|clk[0]}];
set_false_path -from [get_clocks {BuTis_clock_generator1|PLL125MHz200MHz1|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {sys_pll_inst|altpll_component|auto_generated|pll1|clk[0]}];

set_max_delay -from [get_registers {wr_PPSpulse_s}] -to [get_clocks {BuTis_clock_generator1|PLL125MHz200MHz1|altpll_component|auto_generated|pll1|clk[0]}] 5
set_max_delay -from [get_registers {wr_PPSpulse_s}] -to [get_clocks {BuTis_clock_generator1|PLL200MHzPhaseAdjust1|altpll_component|auto_generated|pll1|clk[0]}] 5


set_false_path -from [get_clocks {PCIe|pcie_phy|pcie|wrapper|altpcie_hip_pipen1b_inst|arria_ii.arriaii_hssi_pcie_hip|coreclkout}] -to [get_clocks {sys_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]


set_false_path -from [get_clocks {sys_pll_inst|altpll_component|auto_generated|pll1|clk[2]}] -to [get_clocks {sys_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]