library ieee;;
use ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.wishbone_pkg.all;
use work.gencores_pkg.all;

package xwr_fec_pkg is
  constant c_xwr_wr_fec_sdwb : t_sdwb_device := (
    wbd_begin     => x"0000000000000000",
    wbd_end       => x"000000000000001f",
    sdwb_child    => x"0000000000000000",
    wbd_flags     => x"01", -- big-endian, no-child,present
    wbd_width     => x"04", -- 32-bit port granularity
    abi_ver_major => x"01",
    abi_ver_minor => x"00",
    abi_class     => x"00000000", -- undocumented device
    dev_vendor    => x"00000651", --

-- GSI
    dev_device    => x"cafe0001",
    dev_version   => x"00000001",
    dev_date      => x"20120403",
    description   => "GSI_FEC");

component wr_fec is
    port (
        clk_sys_i    : in   std_logic;
        rst_n_i      : in   std_logic;
        -- To WRPTP core
        snk_deco_o   : out  t_wrf_sink_out;
        snk_deco_i   : in   t_wrf_sink_in;
        src_encod_o  : out  t_wrf_source_out;
        src_encod_i  : in   t_wrf_source_in;
        -- To Etherbone
        snk_encod_o  : out  t_wrf_sink_out;
        snk_encod_i  : in   t_wrf_sink_in;
        src_deco_o   : out  t_wrf_source_out;
        src_deco_i   : in   t_wrf_source_in;
        master_i     : in   t_wishbone_master_in
        -- WB slave
        wb_slave_o  : out t_wishbone_slave_out;
        wb_slave_i  : in  t_wishbone_slave_in);
end component wr_fec;

end package xwr_fec_pkg;
