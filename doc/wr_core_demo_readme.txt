WR Core demo design README
--------------------------

This is just a quick guide how to get the WR Core demo to work. In order to do that, you'll need:
- Xilinx ISE (tested on v. 13.1) 
- hdlmake (git://ohwr.org/misc/hdl-make.git)
- git & svn
- LM32 toolchain for compiling the software 
- Alessandro's gnurabbit driver for SPEC card (git://gnudd.com/gnurabbit.git)

Synthesis:
---------------------------
* Bulid ISE project:

$ cd syn/spec_1_1/wr_core_demo

* Download necessary IP cores, generate Makefile and ISE project:
$ hdlmake

* Build it (after typing that, go for a coffee, it takes ~6 minutes on core i7-980x)
$ make

As a result, you'll get a file called "spec_top.bin"

Software:
--------------------------
* Make sure you have the LM32 GCC toolchain installed (if not, download it from Lattice's webpage)
* Compile and install the rawrabbit driver

Build the PTP Core firmware:

$ git clone git://github.com/twlostow/wr-core-software.git
$ cd wr-core-software
$ git clone git://gnudd.com/ptp-noposix.git
$ make -C tools
$ make

As a result, you'll obtain a firmware file called wrc.bin

Launching the demo:
--------------------------
(You are still in wr-core-software directory, # = root shell)

* load the FPGA image (loader = loader program from gnurabbit package)
# loader wr-cores/syn/spec_1_1/wr_core_demo/spec_top.bin

* load the LM32 firmware
# make load  

* see if it works
# ./tools/vuart_console