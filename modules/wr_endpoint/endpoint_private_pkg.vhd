library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ep_wbgen2_pkg.all;

package endpoint_private_pkg is
  
  constant c_endpoint_rx_buffer_size      : integer := 4096;
  constant c_endpoint_rx_buffer_size_log2 : integer := 12;

  -- special/control characters
  constant c_k28_5 : std_logic_vector(7 downto 0) := "10111100";  -- bc
  constant c_k23_7 : std_logic_vector(7 downto 0) := "11110111";  -- f7
  constant c_k27_7 : std_logic_vector(7 downto 0) := "11111011";  -- fb
  constant c_k29_7 : std_logic_vector(7 downto 0) := "11111101";  -- fd
  constant c_k30_7 : std_logic_vector(7 downto 0) := "11111110";  -- fe
  constant c_k28_7 : std_logic_vector(7 downto 0) := "11111100";  -- fc
  constant c_d21_5 : std_logic_vector(7 downto 0) := "10110101";  -- b5

  constant c_d2_2          : std_logic_vector(7 downto 0) := "01000010";  -- 42
  constant c_d5_6          : std_logic_vector(7 downto 0) := "11000101";  -- c5
  constant c_d16_2         : std_logic_vector(7 downto 0) := "01010000";  -- 50
  constant c_preamble_char : std_logic_vector(7 downto 0) := "01010101";
  constant c_preamble_sfd  : std_logic_vector(7 downto 0) := "11010101";

  constant c_QMODE_PORT_ACCESS : std_logic_vector(1 downto 0) := "00";
  constant c_QMODE_PORT_TRUNK  : std_logic_vector(1 downto 0) := "01";
  constant c_QMODE_PORT_NONE   : std_logic_vector(1 downto 0) := "11";

  -- fixme: remove these along with the non-WB version of the endpoint
  constant c_wrsw_ctrl_none      : std_logic_vector(4 - 1 downto 0) := x"0";
  constant c_wrsw_ctrl_dst_mac   : std_logic_vector(4 - 1 downto 0) := x"1";
  constant c_wrsw_ctrl_src_mac   : std_logic_vector(4 - 1 downto 0) := x"2";
  constant c_wrsw_ctrl_ethertype : std_logic_vector(4 - 1 downto 0) := x"3";
  constant c_wrsw_ctrl_vid_prio  : std_logic_vector(4 - 1 downto 0) := x"4";
  constant c_wrsw_ctrl_tx_oob    : std_logic_vector(4 - 1 downto 0) := x"5";
  constant c_wrsw_ctrl_rx_oob    : std_logic_vector(4 - 1 downto 0) := x"6";
  constant c_wrsw_ctrl_payload   : std_logic_vector(4 - 1 downto 0) := x"7";
  constant c_wrsw_ctrl_fcs       : std_logic_vector(4 - 1 downto 0) := x"8";

  type t_rmon_triggers is record
    rx_sync_lost      : std_logic;
    rx_invalid_code   : std_logic;
    rx_overrun        : std_logic;
    rx_crc_err        : std_logic;
    rx_ok             : std_logic;
    rx_runt           : std_logic;
    rx_giant          : std_logic;
    rx_pause          : std_logic;
    rx_pcs_err        : std_logic;
    rx_buffer_overrun : std_logic;
    rx_rtu_overrun    : std_logic;

    tx_pause    : std_logic;
    tx_underrun : std_logic;

  end record;

  component ep_1000basex_pcs
    generic (
      g_simulation : integer);
    port (
      rst_n_i                 : in    std_logic;
      clk_sys_i               : in    std_logic;
      rxpcs_busy_o            : out   std_logic;
      rxpcs_data_o            : out   std_logic_vector(17 downto 0);
      rxpcs_dreq_i            : in    std_logic;
      rxpcs_valid_o           : out   std_logic;
      rxpcs_timestamp_stb_p_o : out   std_logic;
      txpcs_data_i            : in    std_logic_vector(17 downto 0);
      txpcs_error_o           : out   std_logic;
      txpcs_busy_o            : out   std_logic;
      txpcs_valid_i           : in    std_logic;
      txpcs_dreq_o            : out   std_logic;
      txpcs_timestamp_stb_p_o : out   std_logic;
      link_ok_o               : out   std_logic;
      serdes_rst_o            : out   std_logic;
      serdes_syncen_o         : out   std_logic;
      serdes_loopen_o         : out   std_logic;
      serdes_prbsen_o         : out   std_logic;
      serdes_enable_o         : out   std_logic;
      serdes_tx_clk_i : in std_logic;
      serdes_tx_data_o        : out   std_logic_vector(7 downto 0);
      serdes_tx_k_o           : out   std_logic;
      serdes_tx_disparity_i   : in    std_logic;
      serdes_tx_enc_err_i     : in    std_logic;
      serdes_rx_data_i        : in    std_logic_vector(7 downto 0);
      serdes_rx_clk_i         : in    std_logic;
      serdes_rx_k_i           : in    std_logic;
      serdes_rx_enc_err_i     : in    std_logic;
      serdes_rx_bitslide_i    : in    std_logic_vector(3 downto 0);
      rmon_o                  : inout t_rmon_triggers;
      mdio_addr_i             : in    std_logic_vector(15 downto 0);
      mdio_data_i             : in    std_logic_vector(15 downto 0);
      mdio_data_o             : out   std_logic_vector(15 downto 0);
      mdio_stb_i              : in    std_logic;
      mdio_rw_i               : in    std_logic;
      mdio_ready_o            : out   std_logic);
  end component;


  component ep_tx_framer
    port (
      clk_sys_i        : in    std_logic;
      rst_n_i          : in    std_logic;
      pcs_error_i      : in    std_logic;
      pcs_busy_i       : in    std_logic;
      pcs_data_o       : out   std_logic_vector(17 downto 0);
      pcs_dreq_i       : in    std_logic;
      pcs_valid_o      : out   std_logic;
      tx_data_i        : in    std_logic_vector(15 downto 0);
      tx_ctrl_i        : in    std_logic_vector(4 - 1 downto 0);
      tx_bytesel_i     : in    std_logic;
      tx_sof_p1_i      : in    std_logic;
      tx_eof_p1_i      : in    std_logic;
      tx_dreq_o        : out   std_logic;
      tx_valid_i       : in    std_logic;
      tx_rerror_p1_i   : in    std_logic;
      tx_tabort_p1_i   : in    std_logic;
      tx_terror_p1_o   : out   std_logic;
      tx_pause_i       : in    std_logic;
      tx_pause_delay_i : in    std_logic_vector(15 downto 0);
      tx_pause_ack_o   : out   std_logic;
      tx_flow_enable_i : in    std_logic;
      oob_fid_value_o  : out   std_logic_vector(15 downto 0);
      oob_fid_stb_o    : out   std_logic;
      regs_b           : inout t_ep_registers);
  end component;

  component ep_rx_deframer
    port (
      clk_sys_i          : in    std_logic;
      rst_n_i            : in    std_logic;
      pcs_data_i         : in    std_logic_vector(17 downto 0);
      pcs_valid_i        : in    std_logic;
      pcs_dreq_o         : out   std_logic;
      pcs_busy_i         : in    std_logic;
      oob_data_i         : in    std_logic_vector(47 downto 0);
      oob_valid_i        : in    std_logic;
      oob_ack_o          : out   std_logic;
      rbuf_sof_p1_o      : out   std_logic;
      rbuf_eof_p1_o      : out   std_logic;
      rbuf_ctrl_o        : out   std_logic_vector(4 - 1 downto 0);
      rbuf_data_o        : out   std_logic_vector(15 downto 0);
      rbuf_bytesel_o     : out   std_logic;
      rbuf_valid_o       : out   std_logic;
      rbuf_drop_i        : in    std_logic;
      rbuf_rerror_p1_o   : out   std_logic;
      fc_pause_p_o       : out   std_logic;
      fc_pause_delay_o   : out   std_logic_vector(15 downto 0);
      rmon_o             : inout t_rmon_triggers;
      regs_b             : inout t_ep_registers;
      rtu_rq_smac_o      : out   std_logic_vector(48 - 1 downto 0);
      rtu_rq_dmac_o      : out   std_logic_vector(48 - 1 downto 0);
      rtu_rq_vid_o       : out   std_logic_vector(12 - 1 downto 0);
      rtu_rq_has_vid_o   : out   std_logic;
      rtu_rq_prio_o      : out   std_logic_vector(3 - 1 downto 0);
      rtu_rq_has_prio_o  : out   std_logic;
      rtu_full_i         : in    std_logic;
      rtu_rq_strobe_p1_o : out   std_logic);
  end component;



  component ep_rmon_counters
    generic (
      g_num_counters   : integer;
      g_ram_addr_width : integer);
    port (
      clk_sys_i       : in  std_logic;
      rst_n_i         : in  std_logic;
      cntr_rst_i      : in  std_logic;
      cntr_pulse_i    : in  std_logic_vector(g_num_counters-1 downto 0);
      ram_addr_o      : out std_logic_vector(g_ram_addr_width-1 downto 0);
      ram_data_i      : in  std_logic_vector(31 downto 0);
      ram_data_o      : out std_logic_vector(31 downto 0);
      ram_wr_o        : out std_logic;
      cntr_overflow_o : out std_logic);
  end component;



  component ep_timestamping_unit
    generic (
      g_timestamp_bits_r : natural;
      g_timestamp_bits_f : natural);
    port (
      clk_ref_i            : in  std_logic;
      clk_sys_i            : in  std_logic;
      rst_n_i              : in  std_logic;
      pps_csync_p1_i       : in  std_logic;
      tx_timestamp_stb_p_i : in  std_logic;
      rx_timestamp_stb_p_i : in  std_logic;
      txoob_fid_i          : in  std_logic_vector(16 - 1 downto 0);
      txoob_stb_p_i        : in  std_logic;
      rxoob_data_o         : out std_logic_vector(47 downto 0);
      rxoob_valid_o        : out std_logic;
      rxoob_ack_i          : in  std_logic;
      txtsu_port_id_o      : out std_logic_vector(4 downto 0);
      txtsu_fid_o          : out std_logic_vector(16 -1 downto 0);
      txtsu_tsval_o        : out std_logic_vector(28 + 4 - 1 downto 0);
      txtsu_valid_o        : out std_logic;
      txtsu_ack_i          : in  std_logic;
      ep_tscr_en_txts_i    : in  std_logic;
      ep_tscr_en_rxts_i    : in  std_logic;
      ep_tscr_cs_start_i   : in  std_logic;
      ep_tscr_cs_done_o    : out std_logic;
      ep_ecr_portid_i      : in  std_logic_vector(4 downto 0));
  end component;

  component ep_flow_control
    port (
      clk_sys_i          : in  std_logic;
      rst_n_i            : in  std_logic;
      rx_pause_p1_i      : in  std_logic;
      rx_pause_delay_i   : in  std_logic_vector(15 downto 0);
      tx_pause_o         : out std_logic;
      tx_pause_delay_o   : out std_logic_vector(15 downto 0);
      tx_pause_ack_i     : in  std_logic;
      tx_flow_enable_o   : out std_logic;
      rx_buffer_used_i   : in  std_logic_vector(7 downto 0);
      ep_fcr_txpause_i   : in  std_logic;
      ep_fcr_rxpause_i   : in  std_logic;
      ep_fcr_tx_thr_i    : in  std_logic_vector(7 downto 0);
      ep_fcr_tx_quanta_i : in  std_logic_vector(15 downto 0);
      rmon_rcvd_pause_o  : out std_logic;
      rmon_sent_pause_o  : out std_logic);
  end component;

  component ep_rx_buffer
    generic (
      g_size_log2 : integer);
    port (
      clk_sys_i          : in  std_logic;
      rst_n_i            : in  std_logic;
      fra_data_i         : in  std_logic_vector(15 downto 0);
      fra_ctrl_i         : in  std_logic_vector(4 -1 downto 0);
      fra_sof_p_i        : in  std_logic;
      fra_eof_p_i        : in  std_logic;
      fra_error_p_i      : in  std_logic;
      fra_valid_i        : in  std_logic;
      fra_drop_o         : out std_logic;
      fra_bytesel_i      : in  std_logic;
      fab_data_o         : out std_logic_vector(15 downto 0);
      fab_ctrl_o         : out std_logic_vector(4 -1 downto 0);
      fab_sof_p_o        : out std_logic;
      fab_eof_p_o        : out std_logic;
      fab_error_p_o      : out std_logic;
      fab_valid_o        : out std_logic;
      fab_bytesel_o      : out std_logic;
      fab_dreq_i         : in  std_logic;
      ep_ecr_rx_en_fra_i : in  std_logic;
      buffer_used_o      : out std_logic_vector(7 downto 0);
      rmon_rx_overflow_o : out std_logic);
  end component;

  component ep_wishbone_controller
    port (
      rst_n_i            : in    std_logic;
      wb_clk_i           : in    std_logic;
      wb_addr_i          : in    std_logic_vector(5 downto 0);
      wb_data_i          : in    std_logic_vector(31 downto 0);
      wb_data_o          : out   std_logic_vector(31 downto 0);
      wb_cyc_i           : in    std_logic;
      wb_sel_i           : in    std_logic_vector(3 downto 0);
      wb_stb_i           : in    std_logic;
      wb_we_i            : in    std_logic;
      wb_ack_o           : out   std_logic;
      tx_clk_i           : in    std_logic;
      ep_rmon_ram_addr_i : in    std_logic_vector(4 downto 0);
      ep_rmon_ram_data_o : out   std_logic_vector(31 downto 0);
      ep_rmon_ram_rd_i   : in    std_logic;
      ep_rmon_ram_data_i : in    std_logic_vector(31 downto 0);
      ep_rmon_ram_wr_i   : in    std_logic;
      regs_b             : inout t_ep_registers);
  end component;

  function f_encode_fabric_int (
    data    : std_logic_vector;
    sof     : std_logic;
    eof     : std_logic;
    bytesel : std_logic;
    error   : std_logic) return std_logic_vector;

  function f_is_data(data : in std_logic_vector; valid : in std_logic) return std_logic;
  function f_is_sof(data  : in std_logic_vector; valid : in std_logic) return std_logic;
  function f_is_eof(data  : in std_logic_vector;valid : in std_logic) return std_logic;
  function f_is_error(data  : in std_logic_vector;valid : in std_logic) return std_logic;
  function f_is_single_byte(data  : in std_logic_vector;valid : in std_logic) return std_logic;
  
end endpoint_private_pkg;

-------------------------------------------------------------------------------

package body endpoint_private_pkg is


    function f_encode_fabric_int (
    data    : std_logic_vector;
    sof     : std_logic;
    eof     : std_logic;
    bytesel : std_logic;
    error   : std_logic) return std_logic_vector is

    variable dout : std_logic_vector(17 downto 0);
  begin
    dout(17) := bytesel;
    if(sof = '1' or eof = '1' or error = '1') then
      dout(16)          := '1';
      dout(15)          := sof;
      dout(14)          := eof;
      dout(13)          := error;
      dout(12 downto 0) := (others => 'X');
    else
      dout(16)          := '0';
      dout(15 downto 0) := data;
    end if;
    return dout;
  end f_encode_fabric_int;

  function f_is_data(data : in std_logic_vector; valid : in std_logic)
    return std_logic is
  begin
    return data(16) and valid;
  end f_is_data;


  function f_is_sof
    (data  : in std_logic_vector;
     valid : in std_logic) return std_logic is
  begin
    if (valid = '1' and data(16) = '1' and data(15) = '1') then
      return '1';
    else
      return '0';
    end if;
  end f_is_sof;

  function f_is_eof
    (data  : in std_logic_vector;
     valid : in std_logic) return std_logic is
  begin
    if (valid = '1' and data(16) = '1' and data(14) = '1') then
      return '1';
    else
      return '0';
    end if;
  end f_is_eof;

  function f_is_error
    (data  : in std_logic_vector;
     valid : in std_logic) return std_logic is
  begin
    if (valid = '1' and data(16) = '1' and data(13) = '1') then
      return '1';
    else
      return '0';
    end if;
  end f_is_error;

  function f_is_single_byte
    (data  : in std_logic_vector;
     valid : in std_logic) return std_logic is
  begin
    if (valid = '1' and data(17) = '1' and data(16) = '0') then
      return '1';
    else
      return '0';
    end if;
  end f_is_single_byte;

end endpoint_private_pkg;

-------------------------------------------------------------------------------