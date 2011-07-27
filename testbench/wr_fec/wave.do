onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /main/FEC_DUT/clk_i
add wave -noupdate /main/FEC_DUT/rst_n_i
add wave -noupdate /main/FEC_DUT/src_data_o
add wave -noupdate /main/FEC_DUT/src_ctrl_o
add wave -noupdate /main/FEC_DUT/src_bytesel_o
add wave -noupdate /main/FEC_DUT/src_dreq_i
add wave -noupdate /main/FEC_DUT/src_valid_o
add wave -noupdate /main/FEC_DUT/src_sof_p1_o
add wave -noupdate /main/FEC_DUT/src_eof_p1_o
add wave -noupdate /main/FEC_DUT/src_error_p1_i
add wave -noupdate /main/FEC_DUT/src_abort_p1_o
add wave -noupdate /main/FEC_DUT/wb_clk_i
add wave -noupdate /main/FEC_DUT/wb_addr_i
add wave -noupdate /main/FEC_DUT/wb_data_i
add wave -noupdate /main/FEC_DUT/wb_data_o
add wave -noupdate /main/FEC_DUT/wb_cyc_i
add wave -noupdate /main/FEC_DUT/wb_sel_i
add wave -noupdate /main/FEC_DUT/wb_stb_i
add wave -noupdate /main/FEC_DUT/wb_we_i
add wave -noupdate /main/FEC_DUT/wb_ack_o
add wave -noupdate /main/FEC_DUT/wbm_dat
add wave -noupdate /main/FEC_DUT/wbm_adr
add wave -noupdate /main/FEC_DUT/wbm_sel
add wave -noupdate /main/FEC_DUT/wbm_cyc
add wave -noupdate /main/FEC_DUT/wbm_stb
add wave -noupdate /main/FEC_DUT/wbm_we
add wave -noupdate /main/FEC_DUT/wbm_err
add wave -noupdate /main/FEC_DUT/wbm_stall
add wave -noupdate /main/FEC_DUT/wbm_ack
add wave -noupdate /main/FEC_DUT/wbm2wrf_dat
add wave -noupdate /main/FEC_DUT/wbm2wrf_adr
add wave -noupdate /main/FEC_DUT/wbm2wrf_sel
add wave -noupdate /main/FEC_DUT/wbm2wrf_cyc
add wave -noupdate /main/FEC_DUT/wbm2wrf_stb
add wave -noupdate /main/FEC_DUT/wbm2wrf_we
add wave -noupdate /main/FEC_DUT/wbm2wrf_err
add wave -noupdate /main/FEC_DUT/wbm2wrf_stall
add wave -noupdate /main/FEC_DUT/wbm2wrf_ack
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1897 ps}
