### Description folders containing code and data
 
`caramel_hw` - contains all Verilog files for CARAMEL hardware. Contains two subdirectories for CARAMEL's submodules: `active_rot_module` and `cfa_module`
 
`logs` - olds current and previous CF-Log files. It is populated during experiments and demo.
 
`msp_bin` - contains `*.mem` files used by Vivado to synthesis program memory onto the openMSP430
 
`openmsp430` - contains all Verilog files for the open source MSP430 (openMSP430) from open-cores
 
`scripts` - all build scripts for experiments
 
`syringe_pump`, `ultrasonic_sensor`, `temperature_sensor`, `rover` - software for example sensor applications
 
`tcb` - contains all source and header files for CARAMEL software TCB.
 
### Requirements / Recommended setup
 
1- Xilinx Vivado (version 2021.1 or higher)
 
2- Python 3.6.9 or higher
 
3- We evaluated CARAMEL on Windows 11
 
4- For Windows users:
    - Setup wsl: https://documentation.ubuntu.com/wsl/stable/howto/install-ubuntu-wsl2/
    - after you clone the repository you might need to change the files via: dos2unix
 
### Setup
 
1- Clone this Repository
 
2- `cd` into `scripts` and run `sudo make install`
 
3- Install Xilinx Vivado: https://www.xilinx.com/support/download.html
 
4- Install pyserial python package using `sudo apt install python3-serial`
 
5- Verify required packages from standard distribution: `time, hmac, hashlib, argparse, pickle, dataclasses, os, collections`.
 
### Create a Vivado Project for CARAMEL
 
1- Start Vivado. On the upper left select: File -> New Project
 
2- Follow the wizard, select a project name and location. In project type, select RTL Project and click Next.
 
3- In the "Add Sources" window, select Add Files and add all .v and .mem files contained in the following directories of this reposiroty:
 
        /caramel_hw
        /msp_bin
        /openmsp430/fpga
        /openmsp430/msp_core
        /openmsp430/msp_memory
        /openmsp430/msp_periph
       
and select Next.
 
Note that /msp_bin contains the pmem.mem and smem.mem binaries, generated in step [Building CARAMEL Software].
 
4- In the "Add Constraints" window, select add files and add the file
 
        openmsp430/contraints_fpga/Basys-3-Master.xdc
 
and select Next.
 
        Note: this file needs to be modified accordingly if you are running CARAMEL in a different FPGA.
 
5- In the "Default Part" window select "Boards", search for Basys3, select it, and click Next.
 
        Note: if you don't see Basys3 as an option you may need to download Basys3 to your Vivado installation.
 
6- Select "Finish". This will conclude the creation of a Vivado Project for CARAMEL.
 
Now we need to configure the project for systhesis.
 
7- In the PROJECT MANAGER "Sources" window, search for openMSP430_fpga (openMSP430_fpga.v) file, right click it and select "Set as Top".
This will make openMSP430_fpga.v the top module in the project hierarchy. Now its name should appear in bold letters.
 
8- In the same "Sources" window, search for openMSP430_defines.v file, right click it and select Set File Type and, from the dropdown menu select "Verilog Header".
 
9- After adding `*.v` and `*.mem` files to the project, open a terminal window and `cd` into `scripts`.
 
10- Run `make ultrasonic` to compile software for the basic test. This will update the `*.mem` files.
 
### Setup Simulation
 
1- Now we are ready to synthesize openmsp430 with CARAMEL hardware. On the left menu of the PROJECT MANAGER, click "Run Synthesis", and select execution parameters (e.g., number of CPUs used for synthesis) according to your PC's capabilities. This step takes 2-10 minutes.
 
2- If synthesis succeeds, a window to "Run Implementation" will appear. Do not "Run Implementation" for the basic test, and close this prompt window.
 
3- In Vivado, click "Add Sources" (Alt-A), then select "Add or create simulation sources", click "Add Files", and select everything inside `openmsp430/simulation`.
 
4- Open the `tb_openMSP430_fpga.sv` file and find line 218. These lines open `*.cflog` files to simulate the transmission of \cflog slices for the basic test. Therefore in line 218, replace `<LOGS_FULL_PATH>` with the full file path of the `logs` subdirectory of the CARAMEL directory.
 
5- Now, navigate to the "Sources" window in Vivado. Search for `tb_openMSP430_fpga`, and in the "Simulation Sources" tab, right-click `tb_openMSP430_fpga.sv` and set its file type as the top module.
 
6- Go back to the Vivado window, and in the "Flow Navigator" tab (on the left-most part of Vivado's window), click "Run Simulation," then "Run Behavioral Simulation."
 
 
### Automated Simulation
 
The simulation is fully automated and includes the Vrf-side delays and RTT delays
 
1. For the automation open `automate_sim.tcl` in the `scripts` folder with your favorite IDE/text editor.
 
2. Update `acfa_exit`. So on line 33 in this file, change this so that it reflects the `acfa_exit` address for the beebs app. The current version has `add_force {/tb_openMSP430_fpga/dut/acfa_memory_0/vrf_resp_mem/mem[32]} -radix hex {e218 0ns}` for ultrasonic. Replace `e218` with the `acfa_exit` address for the app.
 
3. After, run behavioral simulation. Wait for the waveform window to load.
 
4. The simulation will be started through the TCL Console, which should be at the bottom of the default Vivado window. If not, you can add it through the following tool bar: `Window -> Tcl console`
 
5. Click to type in the Tcl console. First, type `pwd` to see where the console is currently running. Navigate using `cd` to the `scripts` folder for CARAMEL.
 
6. Once in `scripts`,  run the `automate_sim.tcl` command. Before doing so, we suggest making the tcl console window slightly bigger so you can see the output there.  
 
7. To run the script, type the following in the tcl command box and then press enter: `source -notrace automate_sim.tcl`.
 
8. After pressing enter, you should see the waveform start moving and `----- CARAMEL START -----` printed in the tcl console. Let it run until the simulation ends.
 
9. As it runs, you should see CARAMEL staus updates. `PREPPING FINAL MESSAGE RECIEVED` means we have reached `ER_done` and Vrf has validated all prior reports, so CARAMEL is preparing the final report.
 
13. Afterwards, the tcl console will print the estimated total run time. It is different than the simulation time as we are calculating the authetication.
 
 
### Changing CARAMEL LOG SIZE
 
1. Navigate to `\tcb\wrapper.c`.
 
2. On lines 40-45 you can see options for the LOG SIZE. Uncomment the size you wish to use.
 
3. Rerun the make command with the app you wish to simulate.
 
4. Navigate to `\openmsp430\msp_core\openMSP430_defines.v`.
 
5. On lines 114-120 you can see options for the LOG SIZE. Uncomment the size you wish to use.
 
6. After saving the changes in `openMSP430_defines.v` you will need to synthesize CARAMEL hardware again. (Follow the steps in Setup Simulation)
 
7. You can simulate CARAMEL with the increased LOG SIZE.
