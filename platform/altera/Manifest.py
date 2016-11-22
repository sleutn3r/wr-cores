def __helper():
  dirs = []
  if syn_device[:1] == "5":    dirs.extend(["wr_arria5_phy", "wr_arria5_pll_default"])
  if syn_device[:4] == "ep2a": dirs.extend(["wr_arria2_phy"])
  return dirs
  
files = [ "altera_pkg.vhd", "xwrc_platform_altera.vhd" ]

modules = {"local": __helper() }
