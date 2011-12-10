onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/clk_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/rst_n_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/src_data_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/src_ctrl_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/src_bytesel_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/src_dreq_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/src_valid_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/src_sof_p1_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/src_eof_p1_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/src_error_p1_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/src_abort_p1_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wb_clk_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wb_addr_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wb_data_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wb_data_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wb_cyc_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wb_sel_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wb_stb_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wb_we_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wb_ack_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm_dat
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm_adr
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm_sel
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm_cyc
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm_stb
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm_we
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm_err
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm_stall
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm_ack
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm2wrf_dat
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm2wrf_adr
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm2wrf_sel
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm2wrf_cyc
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm2wrf_stb
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm2wrf_we
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm2wrf_err
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm2wrf_stall
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm2wrf_ack
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/clk_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rst_n_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_data_in
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_byte_sel_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_data_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_byte_sel_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_msg_size_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_fec_id_ena_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_fec_id_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_in_ctrl_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_in_settngs_ena_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_in_ethertype_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_in_ctrl_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_busy_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_out_ctrl_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_out_frame_cyc_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_out_start_frame_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_out_end_of_frame_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_out_end_of_fec_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_out_ctrl_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_out_msg_num_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_data_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/input_buffer
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/out_buffer
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/fec_header_buffer
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/fec_header_ethertype_valid
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/divfecin_msg_size
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/break_msg_at_size
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rsin_msg_size
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/eth_header_size
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/inc_fragmentid
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/out_msg_num
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/out_orig_data_msg_num
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/hamming_in_data
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/hamming_parity_tmp
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/current_hamming_buf_num
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/p_addr_rd_first_divmsg
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/p_addr_rd_next_divmsg
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/ram_addr_divmsg_size
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/ram_addr_origmsg_size
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/receive_state
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/hamming_state
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_state
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/sending_state
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_indices
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_load_indices
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_enable_in
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_stream_in
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_setting_finished
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_encoding_done
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_out_result
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/zeros
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/fecsettingsready
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/fecsettingsused
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/in_msg_received
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/all_ham_parity_bits_sent_b1
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/all_ham_parity_bits_sent_b2
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/ham_parity_bits_ready_b1
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/ham_parity_bits_ready_b2
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/header_ram_we
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/header_ram_rd_address
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/header_ram_wr_address
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/header_ram_input
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/header_ram_output
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/op_ram_we
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/op_ram_wr_address
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/op_ram_input
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/op_1_ram_rd_address
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/op_1_ram_output
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/op_2_ram_rd_address
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/op_2_ram_output
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_ram_we
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_ram_rd_address
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_ram_wr_address
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_ram_output
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_ram_input
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/p_rs_ram_wr_first_msg_add
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/p_rs_ram_wr_next_msg_add
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/result_symbol
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/input_payload_word_cnt
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/input_payload_size_cnt
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/odd_write
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/write_input
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/help_input_buffer
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/in_second_msg
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/mem_all_ham_parity_bits_sent_b1
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/mem_all_ham_parity_bits_sent_b2
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/output_words_cnt_mod9
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/output_words_cnt
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/finished_encoding
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/rs_finished
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/end_of_outmsg
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_out_frame_cyc
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/out_helper_buffer
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/out_helper_ctrl_d
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {90376 ns} 0}
configure wave -namecolwidth 226
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
WaveRestoreZoom {87532 ns} {100657 ns}
