onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /main_with_fec/DUT/fec/clk_i
add wave -noupdate /main_with_fec/DUT/fec/rst_n_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/src_data_o
add wave -noupdate /main_with_fec/DUT/fec/src_ctrl_o
add wave -noupdate /main_with_fec/DUT/fec/src_bytesel_o
add wave -noupdate /main_with_fec/DUT/fec/src_dreq_i
add wave -noupdate /main_with_fec/DUT/fec/src_valid_o
add wave -noupdate /main_with_fec/DUT/fec/src_sof_p1_o
add wave -noupdate /main_with_fec/DUT/fec/src_eof_p1_o
add wave -noupdate /main_with_fec/DUT/fec/src_error_p1_i
add wave -noupdate /main_with_fec/DUT/fec/src_abort_p1_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/wbm2wrf_dat
add wave -noupdate /main_with_fec/DUT/fec/wbm2wrf_adr
add wave -noupdate /main_with_fec/DUT/fec/wbm2wrf_sel
add wave -noupdate /main_with_fec/DUT/fec/wbm2wrf_cyc
add wave -noupdate /main_with_fec/DUT/fec/wbm2wrf_stb
add wave -noupdate /main_with_fec/DUT/fec/wbm2wrf_we
add wave -noupdate /main_with_fec/DUT/fec/wbm2wrf_err
add wave -noupdate /main_with_fec/DUT/fec/wbm2wrf_stall
add wave -noupdate /main_with_fec/DUT/fec/wbm2wrf_ack
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/clk_i
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/rst_n_i
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/if_out_ctrl_o
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/if_out_frame_cyc_o
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/if_out_start_frame_o
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/if_out_end_of_frame_o
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/if_out_end_of_fec_o
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/if_out_ctrl_i
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/if_out_msg_num_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/if_data_i
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/input_buffer
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/out_buffer
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/receive_state
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/hamming_state
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/rs_state
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/sending_state
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/zeros
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/fecsettingsready
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/fecsettingsused
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/in_msg_received
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/all_ham_parity_bits_sent_b1
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/all_ham_parity_bits_sent_b2
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/ham_parity_bits_ready_b1
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/ham_parity_bits_ready_b2
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/header_ram_we
add wave -noupdate -radix unsigned /main_with_fec/DUT/fec/fec/fec_engine/header_ram_rd_address
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/header_ram_wr_address
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/header_ram_input
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/header_ram_output
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/odd_write
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/if_out_frame_cyc
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_engine/out_helper_buffer
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_engine/out_helper_ctrl_d
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_if/tx_state
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_if/dummy
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/fec/fec/fec_if/first_word_out
add wave -noupdate /main_with_fec/DUT/fec/fec/fec_if/first_bsel_out
add wave -noupdate /main_with_fec/DUT/fec/conf/state
add wave -noupdate /main_with_fec/DUT/s_ep_rx_data_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_ctrl_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_bytesel_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_sof_p1_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_eof_p1_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_dreq_i
add wave -noupdate /main_with_fec/DUT/s_ep_rx_valid_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_rerror_p1_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/s_ep_tx_data_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_ctrl_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_bytesel_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_sof_p1_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_eof_p1_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_dreq_o
add wave -noupdate /main_with_fec/DUT/s_ep_tx_valid_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_terror_p1_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/phy_tx_data_o
add wave -noupdate /main_with_fec/DUT/phy_tx_k_o
add wave -noupdate /main_with_fec/DUT/phy_tx_disparity_i
add wave -noupdate /main_with_fec/DUT/phy_tx_enc_err_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/clk_sys_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/rst_n_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/pcs_data_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/pcs_bytesel_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/pcs_sof_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/pcs_eof_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/pcs_abort_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/pcs_error_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/pcs_busy_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/pcs_fifo_write_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/pcs_fifo_almostfull_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_data_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_ctrl_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_bytesel_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_sof_p1_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_eof_p1_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_dreq_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_valid_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_rerror_p1_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_tabort_p1_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_terror_p1_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_pause_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_pause_delay_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_pause_ack_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_flow_enable_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/oob_fid_value_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/oob_fid_stb_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/ep_tcr_en_fra_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/ep_rfcr_qmode_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/ep_macl_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/ep_mach_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/state
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/counter
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_ready_t
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/crc_gen_reset
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/crc_gen_force_reset
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/crc_gen_enable
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/crc_gen_enable_mask
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/crc_value
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_data_t2f_bytesel
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_data_t2f_valid
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_data_t2f_write_mask
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_data_t2f
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_data_t2f_odd_length
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_sof_t2f
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_eof_t2f
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_abort_t2f
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_pause_mode
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_tx_fra/tx_pause_delay
add wave -noupdate /main_with_fec/DUT/g_simulation
add wave -noupdate /main_with_fec/DUT/g_virtual_uart
add wave -noupdate /main_with_fec/DUT/g_ep_rxbuf_size_log2
add wave -noupdate /main_with_fec/DUT/g_dpram_initf
add wave -noupdate /main_with_fec/DUT/g_dpram_size
add wave -noupdate /main_with_fec/DUT/g_num_gpio
add wave -noupdate /main_with_fec/DUT/clk_sys_i
add wave -noupdate /main_with_fec/DUT/clk_dmtd_i
add wave -noupdate /main_with_fec/DUT/clk_ref_i
add wave -noupdate /main_with_fec/DUT/rst_n_i
add wave -noupdate /main_with_fec/DUT/pps_p_o
add wave -noupdate /main_with_fec/DUT/dac_hpll_load_p1_o
add wave -noupdate /main_with_fec/DUT/dac_hpll_data_o
add wave -noupdate /main_with_fec/DUT/dac_dpll_load_p1_o
add wave -noupdate /main_with_fec/DUT/dac_dpll_data_o
add wave -noupdate /main_with_fec/DUT/phy_ref_clk_i
add wave -noupdate /main_with_fec/DUT/phy_tx_data_o
add wave -noupdate /main_with_fec/DUT/phy_tx_k_o
add wave -noupdate /main_with_fec/DUT/phy_tx_disparity_i
add wave -noupdate /main_with_fec/DUT/phy_tx_enc_err_i
add wave -noupdate /main_with_fec/DUT/phy_rx_data_i
add wave -noupdate /main_with_fec/DUT/phy_rx_rbclk_i
add wave -noupdate /main_with_fec/DUT/phy_rx_k_i
add wave -noupdate /main_with_fec/DUT/phy_rx_enc_err_i
add wave -noupdate /main_with_fec/DUT/phy_rx_bitslide_i
add wave -noupdate /main_with_fec/DUT/phy_rst_o
add wave -noupdate /main_with_fec/DUT/phy_loopen_o
add wave -noupdate /main_with_fec/DUT/gpio_o
add wave -noupdate /main_with_fec/DUT/gpio_i
add wave -noupdate /main_with_fec/DUT/gpio_dir_o
add wave -noupdate /main_with_fec/DUT/uart_rxd_i
add wave -noupdate /main_with_fec/DUT/uart_txd_o
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/wb_addr_i
add wave -noupdate -radix hexadecimal /main_with_fec/DUT/wb_data_i
add wave -noupdate /main_with_fec/DUT/wb_data_o
add wave -noupdate /main_with_fec/DUT/wb_sel_i
add wave -noupdate /main_with_fec/DUT/wb_we_i
add wave -noupdate /main_with_fec/DUT/wb_cyc_i
add wave -noupdate /main_with_fec/DUT/wb_stb_i
add wave -noupdate /main_with_fec/DUT/wb_ack_o
add wave -noupdate /main_with_fec/DUT/genrest_n
add wave -noupdate /main_with_fec/DUT/dio_o
add wave -noupdate /main_with_fec/DUT/s_rst
add wave -noupdate /main_with_fec/DUT/s_rst_n
add wave -noupdate /main_with_fec/DUT/s_pps_csync
add wave -noupdate /main_with_fec/DUT/ppsg_wb_i
add wave -noupdate /main_with_fec/DUT/ppsg_wb_o
add wave -noupdate /main_with_fec/DUT/hpll_wb_i
add wave -noupdate /main_with_fec/DUT/hpll_wb_o
add wave -noupdate /main_with_fec/DUT/dpll_wb_i
add wave -noupdate /main_with_fec/DUT/dpll_wb_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_data_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_ctrl_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_bytesel_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_sof_p1_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_eof_p1_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_dreq_i
add wave -noupdate /main_with_fec/DUT/s_ep_rx_valid_o
add wave -noupdate /main_with_fec/DUT/s_ep_rx_rerror_p1_o
add wave -noupdate /main_with_fec/DUT/s_ep_tx_data_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_ctrl_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_bytesel_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_sof_p1_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_eof_p1_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_dreq_o
add wave -noupdate /main_with_fec/DUT/s_ep_tx_valid_i
add wave -noupdate /main_with_fec/DUT/s_ep_tx_terror_p1_o
add wave -noupdate /main_with_fec/DUT/txtsu_port_id_o
add wave -noupdate /main_with_fec/DUT/txtsu_frame_id_o
add wave -noupdate /main_with_fec/DUT/txtsu_tsval_o
add wave -noupdate /main_with_fec/DUT/txtsu_valid_o
add wave -noupdate /main_with_fec/DUT/txtsu_ack_i
add wave -noupdate -expand /main_with_fec/DUT/ep_wb_i
add wave -noupdate -expand /main_with_fec/DUT/ep_wb_o
add wave -noupdate /main_with_fec/DUT/s_gtp_tx_data_i
add wave -noupdate /main_with_fec/DUT/s_gtp_tx_k_i
add wave -noupdate /main_with_fec/DUT/s_gtp_tx_disparity_o
add wave -noupdate /main_with_fec/DUT/s_gtp_tx_enc_err_o
add wave -noupdate /main_with_fec/DUT/s_gtp_rx_data_o
add wave -noupdate /main_with_fec/DUT/s_gtp_rx_rbclk_o
add wave -noupdate /main_with_fec/DUT/s_gtp_rx_k_o
add wave -noupdate /main_with_fec/DUT/s_gtp_rx_enc_err_o
add wave -noupdate /main_with_fec/DUT/s_gtp_rx_bitslide_o
add wave -noupdate /main_with_fec/DUT/s_gtp_rst_i
add wave -noupdate /main_with_fec/DUT/s_gtp_loopen_i
add wave -noupdate /main_with_fec/DUT/s_mnic_mem_data_o
add wave -noupdate /main_with_fec/DUT/s_mnic_mem_addr_o
add wave -noupdate /main_with_fec/DUT/s_mnic_mem_data_i
add wave -noupdate /main_with_fec/DUT/s_mnic_mem_wr_o
add wave -noupdate /main_with_fec/DUT/mnic_wb_i
add wave -noupdate /main_with_fec/DUT/mnic_wb_o
add wave -noupdate /main_with_fec/DUT/mnic_wb_irq_o
add wave -noupdate /main_with_fec/DUT/zpu_wb_i
add wave -noupdate /main_with_fec/DUT/zpu_wb_o
add wave -noupdate /main_with_fec/DUT/lm32_iwb_i
add wave -noupdate /main_with_fec/DUT/lm32_iwb_o
add wave -noupdate /main_with_fec/DUT/lm32_dwb_i
add wave -noupdate /main_with_fec/DUT/lm32_dwb_o
add wave -noupdate /main_with_fec/DUT/dpram_wb_i
add wave -noupdate /main_with_fec/DUT/dpram_wb_o
add wave -noupdate /main_with_fec/DUT/periph_wb_i
add wave -noupdate /main_with_fec/DUT/periph_wb_o
add wave -noupdate /main_with_fec/DUT/wbm_unused_i
add wave -noupdate /main_with_fec/DUT/wbs_unused_i
add wave -noupdate /main_with_fec/DUT/cnx_master_i
add wave -noupdate /main_with_fec/DUT/cnx_master_o
add wave -noupdate /main_with_fec/DUT/cnx_slave_i
add wave -noupdate /main_with_fec/DUT/cnx_slave_o
add wave -noupdate /main_with_fec/DUT/ext_wb_i
add wave -noupdate /main_with_fec/DUT/ext_wb_o
add wave -noupdate /main_with_fec/DUT/rst_wb_addr_o
add wave -noupdate /main_with_fec/DUT/rst_wb_data_i
add wave -noupdate /main_with_fec/DUT/rst_wb_data_o
add wave -noupdate /main_with_fec/DUT/rst_wb_sel_o
add wave -noupdate /main_with_fec/DUT/rst_wb_we_o
add wave -noupdate /main_with_fec/DUT/rst_wb_cyc_o
add wave -noupdate /main_with_fec/DUT/rst_wb_stb_o
add wave -noupdate /main_with_fec/DUT/rst_wb_ack_i
add wave -noupdate /main_with_fec/DUT/genrst_n
add wave -noupdate /main_with_fec/DUT/rst_wb_i
add wave -noupdate /main_with_fec/DUT/rst_wb_o
add wave -noupdate /main_with_fec/DUT/hpll_auxout
add wave -noupdate /main_with_fec/DUT/dmpll_auxout
add wave -noupdate /main_with_fec/DUT/clk_ref_slv
add wave -noupdate /main_with_fec/DUT/clk_rx_slv
add wave -noupdate /main_with_fec/DUT/s_dummy_addr
add wave -noupdate /main_with_fec/DUT/rst_n_inv
add wave -noupdate /main_with_fec/DUT/softpll_irq
add wave -noupdate /main_with_fec/DUT/lm32_irq_slv
add wave -noupdate /main_with_fec/DUT/fec_wb_i
add wave -noupdate /main_with_fec/DUT/fec_wb_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/g_simulation
add wave -noupdate /main_with_fec/DUT/wr_endpoint/g_phy_mode
add wave -noupdate /main_with_fec/DUT/wr_endpoint/g_rx_buffer_size_log2
add wave -noupdate /main_with_fec/DUT/wr_endpoint/clk_ref_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/clk_sys_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/clk_dmtd_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rst_n_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/pps_csync_p1_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tbi_td_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tbi_enable_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tbi_syncen_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tbi_loopen_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tbi_prbsen_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tbi_rbclk_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tbi_rd_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tbi_sync_pass_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_tx_clk_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_tx_data_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_tx_k_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_tx_disparity_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_tx_enc_err_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_rx_data_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_rx_clk_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_rx_k_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_rx_enc_err_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_rx_bitslide_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_rst_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/gtp_loopen_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_data_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_ctrl_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_bytesel_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_sof_p1_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_eof_p1_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_dreq_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_valid_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_rabort_p1_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_idle_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_rerror_p1_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tx_data_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tx_ctrl_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tx_bytesel_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tx_sof_p1_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tx_eof_p1_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tx_dreq_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tx_valid_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tx_rerror_p1_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tx_tabort_p1_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tx_terror_p1_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txtsu_port_id_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txtsu_frame_id_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txtsu_tsval_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txtsu_valid_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txtsu_ack_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rtu_full_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rtu_almost_full_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rtu_rq_strobe_p1_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rtu_rq_smac_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rtu_rq_dmac_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rtu_rq_vid_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rtu_rq_has_vid_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rtu_rq_prio_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rtu_rq_has_prio_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/wb_cyc_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/wb_stb_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/wb_we_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/wb_sel_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/wb_addr_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/wb_data_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/wb_data_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/wb_ack_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/sv_zero
add wave -noupdate /main_with_fec/DUT/wr_endpoint/sv_one
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tx_clk
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_clk
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txpcs_data
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txpcs_bytesel
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txpcs_sof
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txpcs_eof
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txpcs_abort
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txpcs_error_p
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txpcs_busy
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txpcs_valid
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txpcs_fifo_almostfull
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txoob_fid_value
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txoob_fid_stb
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxoob_data
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxoob_valid
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxoob_ack
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txpcs_timestamp_stb_p
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxpcs_timestamp_stb_p
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txts_timestamp_value
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxts_timestamp_value
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxts_done_p
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txts_done_p
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_mdio_strobe
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_mdio_cr_data
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_mdio_cr_addr
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_mdio_cr_rw
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_mdio_sr_rdata
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_mdio_sr_ready
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxpcs_busy
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxpcs_data
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxpcs_bytesel
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxpcs_sof
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxpcs_eof
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxpcs_error
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxpcs_dreq
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxpcs_valid
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rbuf_data
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rbuf_ctrl
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rbuf_sof_p
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rbuf_eof_p
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rbuf_error_p
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rbuf_valid
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rbuf_drop
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rbuf_bytesel
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rx_buffer_used
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_ecr_portid
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_ecr_pcs_lbk
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_ecr_fra_lbk
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_tscr_en_txts
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_tscr_en_rxts
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_tscr_cs_start
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_tscr_cs_done
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rfcr_a_runt
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rfcr_a_giant
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rfcr_a_hp
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rfcr_a_frag
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rfcr_qmode
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rfcr_fix_prio
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rfcr_prio_val
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rfcr_vid_val
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_mach
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_macl
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_fcr_rxpause
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_fcr_txpause
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_fcr_tx_thr
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_fcr_tx_quanta
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_dmcr_en
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_dmcr_n_avg
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_dmsr_ps_val
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_dmsr_ps_rdy_out
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_dmsr_ps_rdy_in
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_dmsr_ps_rdy_load
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_dsr_lact_out
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_dsr_lact_in
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_dsr_lact_load
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tbi_tx_data
add wave -noupdate /main_with_fec/DUT/wr_endpoint/tbi_rx_data
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txfra_flow_enable
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxfra_pause_p
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxfra_pause_delay
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxbuf_threshold_hit
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txfra_pause
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txfra_pause_ack
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txfra_pause_delay
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_ecr_rst_cnt
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_ecr_rx_en_fra
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_ecr_tx_en_fra
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rmon_ram_addr
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rmon_ram_data_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rmon_ram_rd
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rmon_ram_data_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/ep_rmon_ram_wr
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rmon_counters
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rofifo_write
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rofifo_full
add wave -noupdate /main_with_fec/DUT/wr_endpoint/oob_valid_d0
add wave -noupdate /main_with_fec/DUT/wr_endpoint/phase_meas
add wave -noupdate /main_with_fec/DUT/wr_endpoint/phase_meas_p
add wave -noupdate /main_with_fec/DUT/wr_endpoint/validity_cntr
add wave -noupdate /main_with_fec/DUT/wr_endpoint/link_ok
add wave -noupdate /main_with_fec/DUT/wr_endpoint/txfra_enable
add wave -noupdate /main_with_fec/DUT/wr_endpoint/rxfra_enable
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/g_simulation
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/g_phy_mode
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/clk_sys_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rst_n_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/pcs_busy_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/pcs_data_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/pcs_bytesel_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/pcs_sof_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/pcs_eof_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/pcs_error_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/pcs_dreq_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/pcs_valid_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/timestamp_stb_p_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/tbi_rbclk_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/tbi_rxdata_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/gtp_rx_clk_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/gtp_rx_data_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/gtp_rx_k_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/gtp_rx_enc_err_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/mdio_mcr_pdown_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/mdio_wr_spec_cal_crst_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/mdio_wr_spec_rx_cal_stat_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/synced_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/sync_lost_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/an_rx_en_i
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/an_rx_val_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/an_rx_valid_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/an_idle_match_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rmon_syncloss_p_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rmon_invalid_code_p_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rmon_rx_overrun_p_o
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/reset_synced_rxclk
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rx_state
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/preamble_cntr
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rx_busy
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rx_enable_synced
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rx_rdreq
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_wrreq
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/dec_err_code
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/dec_err_rdisp
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_is_k
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_err
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_is_comma
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_is_epd
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_is_spd
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_is_extend
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_is_idle
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_is_lcr
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_is_sfd_char
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_is_preamble_char
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_data
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_is_even
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/d_is_cal
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/dec_out
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/dec_err
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/dec_is_k
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_wr_toggle
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_in
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_out
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_rx_data
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_mask_write
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_bytesel
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_sof
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_eof
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_error
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_almostfull
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_empty
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/fifo_clear_n
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rx_synced
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rx_even
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rx_sync_lost_p
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rx_sync_status
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rx_sync_enable
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/an_rx_en_synced
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/lcr_ready
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/lcr_prev_val
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/lcr_cur_val
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/lcr_validity_cntr
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/an_idle_cntr
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/an_idle_match_int
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rmon_rx_overrun_p_int
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rmon_syncloss_p_int
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rmon_invalid_code_p_int
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/cal_pattern_cntr
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/mdio_mcr_pdown_synced
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/rx_clk
add wave -noupdate /main_with_fec/DUT/wr_endpoint/u_pcs_1000basex/u_rx_pcs/pcs_valid_int
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {98612 ns} 0}
configure wave -namecolwidth 426
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
configure wave -timelineunits ns
update
WaveRestoreZoom {96308 ns} {100916 ns}
