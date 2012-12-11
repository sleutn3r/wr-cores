onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /main/DUT/g_simulation
add wave -noupdate /main/DUT/clk_sys_i
add wave -noupdate /main/DUT/rst_n_i
add wave -noupdate /main/DUT/tm_dac_value_i
add wave -noupdate /main/DUT/tm_dac_value_wr_i
add wave -noupdate /main/DUT/scl_pad_oen_o
add wave -noupdate /main/DUT/sda_pad_oen_o
add wave -noupdate /main/DUT/scl_pad_i
add wave -noupdate /main/DUT/sda_pad_i
add wave -noupdate /main/DUT/wb_adr_i
add wave -noupdate /main/DUT/wb_dat_i
add wave -noupdate /main/DUT/wb_dat_o
add wave -noupdate /main/DUT/wb_sel_i
add wave -noupdate /main/DUT/wb_we_i
add wave -noupdate /main/DUT/wb_cyc_i
add wave -noupdate /main/DUT/wb_stb_i
add wave -noupdate /main/DUT/wb_ack_o
add wave -noupdate /main/DUT/wb_err_o
add wave -noupdate /main/DUT/wb_rty_o
add wave -noupdate /main/DUT/wb_stall_o
add wave -noupdate /main/DUT/regs_in
add wave -noupdate /main/DUT/regs_out
add wave -noupdate /main/DUT/new_rfreq
add wave -noupdate /main/DUT/rfreq_base
add wave -noupdate /main/DUT/rfreq_adj
add wave -noupdate /main/DUT/rfreq_current
add wave -noupdate /main/DUT/i2c_tick
add wave -noupdate /main/DUT/i2c_divider
add wave -noupdate /main/DUT/scl_int
add wave -noupdate /main/DUT/sda_int
add wave -noupdate /main/DUT/seq_count
add wave -noupdate /main/DUT/state
add wave -noupdate /main/DUT/scl_out_host
add wave -noupdate /main/DUT/scl_out_fsm
add wave -noupdate /main/DUT/sda_out_host
add wave -noupdate /main/DUT/sda_out_fsm
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {23255033560 fs} 0}
configure wave -namecolwidth 183
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 fs} {262500 ns}
