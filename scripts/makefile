install:
	apt-get install bison pkg-config gawk clang flex gcc-msp430 iverilog tcl-dev

demo :
	rm -f ../logs/*.cflog
	sed -i 's/#define IS_SIM  SIM/#define IS_SIM  NOT_SIM/g' ../tcb/wrapper.c 
	sh build/run "demo_prv" true

demo_sim:
	rm -f ../logs/*.cflog
	sed -i 's/#define IS_SIM  NOT_SIM/#define IS_SIM  SIM/g' ../tcb/wrapper.c 
	sh build/run "demo_prv" true

sim:
	rm -f ../logs/*.cflog
	sed -i 's/#define IS_SIM  NOT_SIM/#define IS_SIM  SIM/g' ../tcb/wrapper.c 
	sh build/run "ultrasonic_sensor" true

ultrasonic_sensor:
	rm -f ../logs/*.cflog
	sh build/run "ultrasonic_sensor" true

temperature_sensor:
	rm -f ../logs/*.cflog
	sh build/run "temperature_sensor" true

syringe_pump:
	rm -f ../logs/*.cflog
	sh build/run "syringe_pump" true

beebs:
	cp ../beebs/tests/${BEEBS}.c ../beebs/main.c
	sh build/run "beebs" true
	rm ../beebs/main.c
	rm -f ../logs/*.cflog
	
geiger:
	sh build/run "geiger" true

gps: 
	sh build/run "gps" true
	
mouse: 
	sh build/run "mouse" true
	
rc:
	sh build/run "rc" true
	
rover:
	sh build/run "rover" true

clean :
	rm -rf simv *.mem pmem.inc stimulus.v tmp-build
