
if vcom_opt.count("mixedsvvh") > 0:
  files= [];
  print("Warning: ECA is incompatible with mixed VHDL-SystemVerilog designs, disabling!")
else:
  files = [
  "eca_internals_pkg.vhd",
  "eca_auto_pkg.vhd",
  "eca_queue_auto_pkg.vhd",
  "eca_tlu_auto_pkg.vhd",
  "eca_ac_wbm_auto_pkg.vhd",
  "eca_pkg.vhd",
  "eca_auto.vhd",
  "eca_queue_auto.vhd",
  "eca_tlu_auto.vhd",
  "eca_ac_wbm_auto.vhd",
  "eca_sdp.vhd",
  "eca_tdp.vhd",
  "eca_piso_fifo.vhd",
  "eca_rmw.vhd",
  "eca_free.vhd",
  "eca_data.vhd",
  "eca_scan.vhd",
  "eca_tag_channel.vhd",
  "eca_channel.vhd",
  "eca_adder.vhd",
  "eca_offset.vhd",
  "eca_wr_time.vhd",
  "eca_walker.vhd",
  "eca_search.vhd",
  "eca_wb_event.vhd",
  "eca_msi.vhd",
  "eca.vhd",
  "wr_eca.vhd",
  "eca_ac_wbm.vhd",
  "eca_scubus_channel.vhd",
  "eca_queue.vhd",
  "eca_tlu_fsm.vhd",
  "eca_tlu.vhd"]

