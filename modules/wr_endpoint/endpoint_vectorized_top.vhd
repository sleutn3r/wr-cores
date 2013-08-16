library ieee;
use ieee.std_logic_1164.all;

use work.endpoint_pkg.all;
use work.wishbone_pkg.all;

entity endpoint_vectorized_top is
	generic (
		g_in_bits		:	integer;
		g_out_bits	:	integer
	);
	port (
		rst_n_i					:	in  std_logic;
		clk_i						:	in	std_logic;
		clk_dmtd_i			:	in  std_logic;
		clk_aux_i				:	in  std_logic;
		input_vector_i	:	in	std_logic_vector(g_in_bits-1 downto 0);
		output_vector_o	:	out	std_logic_vector(g_out_bits-1 downto 0)
	);
end endpoint_vectorized_top;

architecture rtl of endpoint_vectorized_top is

begin

	--generics configuration the same as in switch top
	U_ENDPOINT: wr_endpoint
		generic map (
      g_interface_mode        => PIPELINED,
      g_address_granularity   => BYTE,
      g_simulation            => false,
      g_tx_force_gap_length   => 0,
      g_pcs_16bit             => true,
      g_rx_buffer_size        => 1024,
      g_with_rx_buffer        => true,
      g_with_flow_control     => false,
      g_with_timestamper      => true,
      g_with_dpi_classifier   => true,
      g_with_vlans            => true,
      g_with_rtu              => true,
      g_with_leds             => true,
      g_with_dmtd             => false,
      g_with_packet_injection => true,
			g_use_new_crc						=> true)
		port map (
      clk_ref_i            => clk_i,
      clk_sys_i            => clk_i,
      clk_dmtd_i           => clk_dmtd_i,
      rst_n_i              => rst_n_i,

      pps_csync_p1_i       => input_vector_i(0),
      pps_valid_i          => input_vector_i(1),

      phy_rst_o            => output_vector_o(0),
      phy_loopen_o         => output_vector_o(1),
      phy_enable_o         => output_vector_o(2),
      phy_syncen_o         => output_vector_o(3),
      phy_ref_clk_i        => clk_aux_i,
      phy_tx_data_o        => output_vector_o(19 downto 4),
      phy_tx_k_o           => output_vector_o(21 downto 20),
      phy_tx_disparity_i   => input_vector_i(2),
      phy_tx_enc_err_i     => input_vector_i(3),
      phy_rx_data_i        => input_vector_i(19 downto 4),
      phy_rx_clk_i         => clk_aux_i,
      phy_rx_k_i           => input_vector_i(21 downto 20),
      phy_rx_enc_err_i     => input_vector_i(22),
      phy_rx_bitslide_i    => input_vector_i(27 downto 23),

      src_dat_o            => output_vector_o(37 downto 22),
      src_adr_o            => output_vector_o(39 downto 38),
      src_sel_o            => output_vector_o(41 downto 40),
      src_cyc_o            => output_vector_o(42),
      src_stb_o            => output_vector_o(43),
      src_we_o             => output_vector_o(44),
      src_stall_i          => input_vector_i(28),
      src_ack_i            => input_vector_i(29),
      src_err_i            => input_vector_i(30),

      snk_dat_i            => input_vector_i(46 downto 31),
      snk_adr_i            => input_vector_i(48 downto 47),
      snk_sel_i            => input_vector_i(50 downto 49),
      snk_cyc_i            => input_vector_i(51),
      snk_stb_i            => input_vector_i(52),
      snk_we_i             => input_vector_i(53),
      snk_stall_o          => output_vector_o(45),
      snk_ack_o            => output_vector_o(46),
      snk_err_o            => output_vector_o(47),
      snk_rty_o            => output_vector_o(48),

      txtsu_port_id_o      => output_vector_o(53 downto 49),
      txtsu_frame_id_o     => output_vector_o(69 downto 54),
      txtsu_ts_value_o     => output_vector_o(101 downto 70),
      txtsu_ts_incorrect_o => output_vector_o(102),
      txtsu_stb_o          => output_vector_o(103),
      txtsu_ack_i          => input_vector_i(54),

      rtu_full_i           => input_vector_i(55),
      rtu_almost_full_i    => input_vector_i(56),
      rtu_rq_strobe_p1_o   => output_vector_o(104),
      rtu_rq_smac_o        => output_vector_o(152 downto 105),
      rtu_rq_dmac_o        => output_vector_o(200 downto 153),
      rtu_rq_vid_o         => output_vector_o(212 downto 201),
      rtu_rq_has_vid_o     => output_vector_o(213),
      rtu_rq_prio_o        => output_vector_o(216 downto 214),
      rtu_rq_has_prio_o    => output_vector_o(217),

      wb_cyc_i             => input_vector_i(57),
      wb_stb_i             => input_vector_i(58),
      wb_we_i              => input_vector_i(59),
      wb_sel_i             => input_vector_i(63 downto 60),
      wb_adr_i             => input_vector_i(71 downto 64),
      wb_dat_i             => input_vector_i(103 downto 72),
      wb_dat_o             => output_vector_o(249 downto 218),
      wb_ack_o             => output_vector_o(250),
      wb_stall_o           => output_vector_o(251),

      pfilter_pclass_o     => output_vector_o(259 downto 252),
      pfilter_drop_o       => output_vector_o(260),
      pfilter_done_o       => output_vector_o(261),

      fc_tx_pause_req_i    			=> input_vector_i(104),
      fc_tx_pause_delay_i  			=> input_vector_i(120 downto 105),
      fc_tx_pause_ready_o  			=> output_vector_o(262),
      fc_rx_pause_start_p_o     => output_vector_o(263),
      fc_rx_pause_quanta_o      => output_vector_o(279 downto 264),
      fc_rx_pause_prio_mask_o   => output_vector_o(287 downto 280),

      inject_req_i         => input_vector_i(121),
      inject_ready_o       => output_vector_o(288),
      inject_packet_sel_i  => input_vector_i(124 downto 122),
      inject_user_value_i  => input_vector_i(140 downto 125),

      rmon_events_o        => output_vector_o(317 downto 289),
      led_link_o           => output_vector_o(318),
      led_act_o            => output_vector_o(319),
      link_kill_i          => input_vector_i(141),
      link_up_o            => output_vector_o(320)
		);

end rtl;
