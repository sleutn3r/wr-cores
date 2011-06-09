make

vsim -L XilinxCoreLib -L secureip -L unisim work.main -voptargs="+acc" -t 10fs
radix -hexadecimal
do wave.do
set StdArithNoWarnings 1
set NumericStdNoWarnings 1

run 100us
wave zoomfull