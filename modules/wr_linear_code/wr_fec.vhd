library ieee;;
use ieee;.std_logic_1164.all;

use work.Wishbone_pkg.all;
use work.wr_fabric_pkg.all;

entity wr_fec is
      
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


end entity wr_fec;

architecture wrapper of wr_fec is

  component decoder is
    port (
      clk_i : in std_logic;
      rst_i : in std_logic;
      
      snk_o   : out  t_wrf_sink_out;
      snk_i   : in   t_wrf_sink_in;
      src_o   : out  t_wrf_source_out;
      src_i   : in   t_wrf_source_in;

      wb_slave_i : in  t_wishbone_slave_in;
      wb_slave_o : out t_wishbone_slave_out);
     end component fec;

  component encoder is
    port (
      clk_i : in std_logic;
      rst_i : in std_logic;
      
      snk_o   : out  t_wrf_sink_out;
      snk_i   : in   t_wrf_sink_in;
      src_o   : out  t_wrf_source_out;
      src_i   : in   t_wrf_source_in;

      wb_slave_i : in  t_wishbone_slave_in;
      wb_slave_o : out t_wishbone_slave_out); 
     end component fec;



begin  -- architecture wrapper

  wr_decoder: decoder
    port map (
      clk_i => clk_sys_i,
      rst_i => rst_n_i,
      snk_i => snk_deco_i,
      snk_o => snk_deco_o,
      src_i => src_encod_i,
      src_o => src_encod_o,
      wb_slave_i => wb_slave_i,
      wb_slave_o => wb_slave_o);

  wr_encoder: encoder
    port map (
      clk_i => clk_sys_i,
      rst_i => rst_n_i,
      snk_i => snk_encod_i,
      snk_o => snk_encod_o,
      src_i => src_encod_i,
      src_o => src_encod_o
      wb_slave_i => wb_slave_i,
      wb_slave_o => wb_slave_o);

end architecture wrapper;
