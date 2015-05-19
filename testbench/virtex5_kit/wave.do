onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/gtp_clk_i
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/rst_n_i
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/pcs_synced_i
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/pcs_los_i
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/pcs_link_ok_o
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/an_idle_match_i
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/an_rx_en_o
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/an_rx_val_i
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/an_rx_valid_i
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/an_tx_en_o
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/an_tx_val_o
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/mdio_mcr_anrestart_i
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/mdio_mcr_anenable_i
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/mdio_msr_anegcomplete_o
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/mdio_advertise_pause_i
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/mdio_advertise_rfault_i
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/mdio_lpa_full_o
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/mdio_lpa_half_o
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/mdio_lpa_pause_o
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/mdio_lpa_rfault_o
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/mdio_lpa_lpack_o
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/mdio_lpa_npage_o
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg -height 16 /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/state
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/link_timer
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/link_timer_restart
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/link_timer_expired
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/an_enable_changed
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/an_enable_d0
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/toggle_tx
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/toggle_rx
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/rx_config_reg
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/acknowledge_match
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/ability_match
add wave -noupdate -expand -group PHYWrap -expand -group Autoneg /main/DUT/U_The_WR_Core/U_Endpoint/U_Wrapped_Endpoint/U_PCS_1000BASEX/U_AUTONEGOTIATION/consistency_match
add wave -noupdate -expand -group PHYWrap -expand -group AlignDet /main/DUT/U_GTP/gen_with_channel0/v5_gtp_align_detect_1/rst_i
add wave -noupdate -expand -group PHYWrap -expand -group AlignDet /main/DUT/U_GTP/gen_with_channel0/v5_gtp_align_detect_1/data_i
add wave -noupdate -expand -group PHYWrap -expand -group AlignDet /main/DUT/U_GTP/gen_with_channel0/v5_gtp_align_detect_1/k_i
add wave -noupdate -expand -group PHYWrap -expand -group AlignDet /main/DUT/U_GTP/gen_with_channel0/v5_gtp_align_detect_1/aligned_o
add wave -noupdate -expand -group PHYWrap -expand -group AlignDet -height 16 /main/DUT/U_GTP/gen_with_channel0/v5_gtp_align_detect_1/state
add wave -noupdate -expand -group PHYWrap -expand -group AlignDet /main/DUT/U_GTP/gen_with_channel0/v5_gtp_align_detect_1/valid_commas
add wave -noupdate -expand -group PHYWrap -expand -group AlignDet /main/DUT/U_GTP/gen_with_channel0/v5_gtp_align_detect_1/comma_timeout
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch01_ref_clk_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_tx_data_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_tx_k_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_tx_disparity_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_tx_enc_err_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_rbclk_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_data_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_k_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_enc_err_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_bitslide_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rst_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_loopen_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_tx_data_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_tx_k_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_tx_disparity_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_tx_enc_err_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_data_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_rbclk_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_k_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_enc_err_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_bitslide_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rst_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_loopen_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/pad_txn0_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/pad_txp0_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/pad_rxn0_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/pad_rxp0_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/pad_txn1_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/pad_txp1_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/pad_rxn1_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/pad_rxp1_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_align_done_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_synced_o
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_gtp_reset
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_gtp_loopback
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_gtp_reset_done
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_data_int
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_k_int
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_disperr
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_invcode
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_byte_is_aligned
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_comma_det
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_cdr_rst
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_rec_clk_pad
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_rec_clk
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_divclk
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_slide
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_synced
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_enable_output
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_enable_output_synced
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_gtp_reset
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_gtp_loopback
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_gtp_reset_done
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_data_int
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_k_int
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_disperr
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_invcode
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_byte_is_aligned
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_comma_det
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_cdr_rst
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_rec_clk_pad
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_rec_clk
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_divclk
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_slide
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_synced
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_enable_output
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_enable_output_synced
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rst_synced
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rst_d0
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_reset_counter
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rst_synced
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rst_d0
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_reset_counter
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rx_bitslide_int
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rx_bitslide_int
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_disparity_set
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_disparity_set
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_tx_chardispmode
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_tx_chardispmode
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_tx_chardispval
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_tx_chardispval
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch01_gtp_locked
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch01_align_done
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch01_gtp_clkout_int
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch01_tx_pma_set_phase
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch01_tx_en_pma_phase_align
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch01_gtp_reset
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch01_gtp_pll_lockdet
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch01_ref_clk_in
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_rst_n
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_rst_n
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_cur_disp
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch0_disp_pipe
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_cur_disp
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/ch1_disp_pipe
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/LOOPBACK0_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/LOOPBACK1_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXCHARISK0_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXCHARISK1_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXDISPERR0_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXDISPERR1_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXNOTINTABLE0_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXNOTINTABLE1_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXBYTEISALIGNED0_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXBYTEISALIGNED1_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXCOMMADET0_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXCOMMADET1_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXSLIDE0_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXSLIDE1_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXDATA0_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXDATA1_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXRECCLK0_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXRECCLK1_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXUSRCLK0_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXUSRCLK1_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXUSRCLK20_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXUSRCLK21_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXCDRRESET0_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXCDRRESET1_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXN0_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXN1_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXP0_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXP1_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXLOSSOFSYNC0_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RXLOSSOFSYNC1_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/CLKIN_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/GTPRESET_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/PLLLKDET_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/REFCLKOUT_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RESETDONE0_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/RESETDONE1_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXENPMAPHASEALIGN_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXPMASETPHASE_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXCHARDISPVAL0_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXCHARDISPVAL1_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXCHARISK0_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXCHARISK1_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXDATA0_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXDATA1_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXUSRCLK0_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXUSRCLK1_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXUSRCLK20_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXUSRCLK21_IN
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXN0_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXN1_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXP0_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/TXP1_OUT
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/tied_to_ground_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/tied_to_ground_vec_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/tied_to_vcc_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/tied_to_vcc_vec_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxdata0_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxchariscomma0_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxcharisk0_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxdisperr0_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxnotintable0_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxrundisp0_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/txdata0_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/txkerr0_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/txrundisp0_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/loopback0_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxelecidle0_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/resetdone0_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxelecidlereset0_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/serialloopback0_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxdata1_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxchariscomma1_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxcharisk1_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxdisperr1_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxnotintable1_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxrundisp1_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/txdata1_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/txkerr1_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/txrundisp1_float_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/loopback1_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxelecidle1_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/resetdone1_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxelecidlereset1_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/serialloopback1_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxenelecidleresetb_i
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/txelecidle_r
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/txelecidle0_r
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/txelecidle1_r
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/txpowerdown0_r
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxpowerdown0_r
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/txpowerdown1_r
add wave -noupdate -expand -group PHYWrap /main/DUT/U_GTP/U_GTP_TILE_INST/rxpowerdown1_r
add wave -noupdate /main/DUT/clk_125m_pllref_p_i
add wave -noupdate /main/DUT/clk_125m_pllref_n_i
add wave -noupdate /main/DUT/gtp_clk_p_i
add wave -noupdate /main/DUT/gtp_clk_n_i
add wave -noupdate /main/DUT/button1_n_i
add wave -noupdate /main/DUT/sfp_txp_o
add wave -noupdate /main/DUT/sfp_txn_o
add wave -noupdate /main/DUT/sfp_rxp_i
add wave -noupdate /main/DUT/sfp_rxn_i
add wave -noupdate /main/DUT/sfp_tx_disable_o
add wave -noupdate /main/DUT/uart_txd_o
add wave -noupdate /main/DUT/uart_rxd_i
add wave -noupdate /main/DUT/CONTROL
add wave -noupdate /main/DUT/TRIG0
add wave -noupdate /main/DUT/TRIG1
add wave -noupdate /main/DUT/clk_sys
add wave -noupdate /main/DUT/rst_n
add wave -noupdate /main/DUT/clk_ref
add wave -noupdate /main/DUT/clk_dmtd
add wave -noupdate /main/DUT/clk_gtp
add wave -noupdate /main/DUT/clk_20m_vcxo_buf
add wave -noupdate /main/DUT/pllout_clk_sys
add wave -noupdate /main/DUT/pllout_clk_fb_pllref
add wave -noupdate /main/DUT/pllout_clk_dmtd
add wave -noupdate /main/DUT/pllout_clk_fb_dmtd
add wave -noupdate /main/DUT/dac_hpll_load_p1
add wave -noupdate /main/DUT/dac_dpll_load_p1
add wave -noupdate /main/DUT/dac_hpll_data
add wave -noupdate /main/DUT/dac_dpll_data
add wave -noupdate /main/DUT/phy_tx_data
add wave -noupdate /main/DUT/phy_tx_k
add wave -noupdate /main/DUT/phy_tx_disparity
add wave -noupdate /main/DUT/phy_tx_enc_err
add wave -noupdate /main/DUT/phy_rx_data
add wave -noupdate /main/DUT/phy_rx_rbclk
add wave -noupdate /main/DUT/phy_rx_k
add wave -noupdate /main/DUT/phy_rx_enc_err
add wave -noupdate /main/DUT/phy_rx_bitslide
add wave -noupdate /main/DUT/phy_rst
add wave -noupdate /main/DUT/phy_loopen
add wave -noupdate /main/DUT/dio_in
add wave -noupdate /main/DUT/dio_out
add wave -noupdate /main/DUT/pps_p
add wave -noupdate /main/DUT/pps_long
add wave -noupdate /main/DUT/sfp_scl_out
add wave -noupdate /main/DUT/sfp_sda_out
add wave -noupdate /main/DUT/fmc_scl_out
add wave -noupdate /main/DUT/fmc_sda_out
add wave -noupdate /main/DUT/owr_enable
add wave -noupdate /main/DUT/owr_in
add wave -noupdate /main/DUT/uart_txd_int
add wave -noupdate /main/DUT/button1_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {244392104000 fs} 0}
configure wave -namecolwidth 279
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
WaveRestoreZoom {0 fs} {525 us}
