files=["hamm_package_64bit.vhd", "./gf256-pkg.vhd","./wr_hamming_pkg.vhd", "./RS_erasure.vhd", "./parameters.vhd", "./wr_fec_pkg.vhd", "./wr_fec_en_interface.vhd", "./wr_fec_en_engine.vhd", "./wr_fec_en.vhd","./wr_fec_dummy_pck_gen_if.vhd", "./wr_fec_dummy_pck_gen.vhd", "./wr_fec_and_gen.vhd" , "./wr_fec_wb_to_wrf.vhd", "./wr_fec_and_gen_with_wrf.vhd" ]

#with FEC decoder: note ready
#files=["hamm_package_64bit.vhd", "./gf256-pkg.vhd","./wr_hamming_pkg.vhd", "./RS_erasure.vhd", "./parameters.vhd", "./wr_fec_pkg.vhd", "./wr_fec_en_interface.vhd", "./wr_fec_en_engine.vhd", "./wr_fec_en.vhd", "./wr_fec_de_interface.vhd", "./wr_fec_de_engine.vhd", "./wr_fec_de.vhd"]

modules = {"git":"git://ohwr.org/hdl-core-lib/general-cores.git"}


#modules = {"local": ["../../platform/genrams/altera","../../platform/altera_nf"]}

fetchto="../ip_cores"
