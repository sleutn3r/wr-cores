library ieee;
use ieee.std_logic_1164.all;

library work;
use work.genram_pkg.all;
use work.wishbone_pkg.all;
use work.sysc_wbgen2_pkg.all;
use work.wr_fabric_pkg.all;

package wrcore_pkg is

  type t_txtsu_timestamp is record
    stb    : std_logic;
    tsval    : std_logic_vector(31 downto 0);
    port_id  : std_logic_vector(5 downto 0);
    frame_id : std_logic_vector(15 downto 0);
    incorrect : std_logic;
  end record;

  ----------------------------------------------------------------------------- 
  --PPS generator
  -----------------------------------------------------------------------------
  component xwr_pps_gen is
    generic(
      g_interface_mode      : t_wishbone_interface_mode;
      g_address_granularity : t_wishbone_address_granularity
      );
    port (
      clk_ref_i       : in  std_logic;
      clk_sys_i       : in  std_logic;
      rst_n_i         : in  std_logic;
      slave_i         : in  t_wishbone_slave_in;
      slave_o         : out t_wishbone_slave_out;
      pps_in_i        : in  std_logic;
      pps_csync_o     : out std_logic;
      pps_out_o       : out std_logic;
      pps_valid_o     : out std_logic;
      tm_utc_o        : out std_logic_vector(39 downto 0);
      tm_cycles_o     : out std_logic_vector(27 downto 0);
      tm_time_valid_o : out std_logic
      );
  end component;

  -----------------------------------------------------------------------------
  --Mini NIC
  -----------------------------------------------------------------------------
  component xwr_mini_nic
    generic (
      g_interface_mode       : t_wishbone_interface_mode;
      g_address_granularity  : t_wishbone_address_granularity;
      g_memsize_log2         : integer;
      g_buffer_little_endian : boolean);
    port (
      clk_sys_i        : in  std_logic;
      rst_n_i          : in  std_logic;
      mem_data_o       : out std_logic_vector(31 downto 0);
      mem_addr_o       : out std_logic_vector(g_memsize_log2-1 downto 0);
      mem_data_i       : in  std_logic_vector(31 downto 0);
      mem_wr_o         : out std_logic;
      src_o            : out t_wrf_source_out;
      src_i            : in  t_wrf_source_in;
      snk_o            : out t_wrf_sink_out;
      snk_i            : in  t_wrf_sink_in;
      txtsu_port_id_i  : in  std_logic_vector(4 downto 0);
      txtsu_frame_id_i : in  std_logic_vector(16 - 1 downto 0);
      txtsu_tsval_i    : in  std_logic_vector(28 + 4 - 1 downto 0);
      txtsu_valid_i    : in  std_logic;
      txtsu_ack_o      : out std_logic;
      wb_i             : in  t_wishbone_slave_in;
      wb_o             : out t_wishbone_slave_out);
  end component;

  -----------------------------------------------------------------------------
  -- PERIPHERIALS
  -----------------------------------------------------------------------------
  component xwr_syscon_wb
    generic(
      g_interface_mode      : t_wishbone_interface_mode;
      g_address_granularity : t_wishbone_address_granularity
      );
    port (
      rst_n_i   : in std_logic;
      clk_sys_i : in std_logic;

      slave_i : in  t_wishbone_slave_in;
      slave_o : out t_wishbone_slave_out;

      regs_i : in  t_sysc_in_registers;
      regs_o : out t_sysc_out_registers
      );
  end component;

  component wrc_periph is
    generic(
      g_phys_uart    : boolean := true;
      g_virtual_uart : boolean := false;
      g_cntr_period  : integer := 62500;
      g_mem_words    : integer := 16384
      );
    port(
      clk_sys_i   : in  std_logic;
      rst_n_i     : in  std_logic;
      rst_net_n_o : out std_logic;
      rst_wrc_n_o : out std_logic;
      led_red_o   : out std_logic;
      led_green_o : out std_logic;
      scl_o       : out std_logic;
      scl_i       : in  std_logic;
      sda_o       : out std_logic;
      sda_i       : in  std_logic;
      sfp_scl_o   : out std_logic;
      sfp_scl_i   : in  std_logic;
      sfp_sda_o   : out std_logic;
      sfp_sda_i   : in  std_logic;
      sfp_det_i   : in  std_logic;
      memsize_i   : in  std_logic_vector(3 downto 0);
      btn1_i      : in  std_logic;
      btn2_i      : in  std_logic;
      slave_i     : in  t_wishbone_slave_in_array(0 to 2);
      slave_o     : out t_wishbone_slave_out_array(0 to 2);
      uart_rxd_i  : in  std_logic;
      uart_txd_o  : out std_logic;
      owr_en_o    : out std_logic_vector(1 downto 0);
      owr_i       : in  std_logic_vector(1 downto 0)
      );
  end component;

  -----------------------------------------------------------------------------
  -- Soft-PLL
  -----------------------------------------------------------------------------
  component xwr_softpll_ng is
    generic(
      g_tag_bits                 : integer;
      g_interface_mode           : t_wishbone_interface_mode;
      g_address_granularity      : t_wishbone_address_granularity;
      g_num_ref_inputs           : integer;
      g_num_outputs              : integer);
    port(
      clk_sys_i : in std_logic;
      rst_n_i   : in std_logic;
      clk_ref_i  : in std_logic_vector(g_num_ref_inputs-1 downto 0);
      clk_fb_i   : in std_logic_vector(g_num_outputs-1 downto 0);
      clk_dmtd_i : in std_logic;

      dac_dmtd_data_o : out std_logic_vector(15 downto 0);
      dac_dmtd_load_o : out std_logic;
  
      dac_out_data_o : out std_logic_vector(15 downto 0);
      dac_out_sel_o  : out std_logic_vector(3 downto 0);
      dac_out_load_o : out std_logic;
  
      out_enable_i : in  std_logic_vector(g_num_outputs-1 downto 0);
      out_locked_o : out std_logic_vector(g_num_outputs-1 downto 0);
  
      slave_i : in  t_wishbone_slave_in;
      slave_o : out t_wishbone_slave_out;
  
      debug_o : out std_logic_vector(3 downto 0)
      );
  end component;

  -----------------------------------------------------------------------------
  -- WBP MUX
  -----------------------------------------------------------------------------
  component xwbp_mux is
    port(
      clk_sys_i : in std_logic;
      rst_n_i   : in std_logic;

      --ENDPOINT
      ep_src_o     : out t_wrf_source_out;
      ep_src_i     : in  t_wrf_source_in;
      ep_snk_o     : out t_wrf_sink_out;
      ep_snk_i     : in  t_wrf_sink_in;
      --PTP packets eg. from Mini-NIC
      ptp_src_o    : out t_wrf_source_out;
      ptp_src_i    : in  t_wrf_source_in;
      ptp_snk_o    : out t_wrf_sink_out;
      ptp_snk_i    : in  t_wrf_sink_in;
      --External WBP port
      ext_src_o    : out t_wrf_source_out;
      ext_src_i    : in  t_wrf_source_in;
      ext_snk_o    : out t_wrf_sink_out;
      ext_snk_i    : in  t_wrf_sink_in;
      class_core_i : in  std_logic_vector(7 downto 0)
      );
  end component;

end wrcore_pkg;
