test

# NEW STUFF - Instructions for ALEX:

Okay now simulation is fully automated and includes the Vrf-side delays

1. The old TB file was converted to `.sv`. Vivado should pick up on this, but just in case, make sure `tb_openMSP430_fpga.sv` is added as a simulation source and the top simulation source. In the `Sources` window, click the + sign. Then chose "add or create simulation source" in the next window. Then, navidate to `openMSP430/simulation/tb_openMSP430_fpga.sv` and add it. Once added, right click it in the `Sources` window and make it the top simulation module.

2. On line `127` in `tb_openMSP430_fpga.sv`, replace the file path with yours. That part isn't automated sadly (maybe we can merge in your version for this?). But, we only need one `$sformat` function call now instead of 1 billion :)

3. Now compile the software. Same as before: `cd` into the `scripts` folder, and run `make beebs BEEBS=<app_name>`.

4. Okay now time for the new stuff involving `automate_sim.tcl` in the `scripts` folder. Open with your favorite IDE/text editor. Still need to manually update the `acfa_exit`. So on line 33 in this file, change this so that it reflects the `acfa_exit` address for the beebs app. The current version has `add_force {/tb_openMSP430_fpga/dut/acfa_memory_0/vrf_resp_mem/mem[32]} -radix hex {e12c 0ns}` for lcdnum. Replace `e12c` with the `acfa_exit` address for the app.

5. Okay, now we can prepare to run. If Synthesis is not up to date, run a synthesis. 

6. After, run behavioral simulation. Wait for the waveform window to load, but don't start anything yet.

7. Okay, now we are using the Tcl Console. It should be at the bottom of the default Vivado window. If not, you can add it through the following tool bar: `Window -> Tcl console`

8. Click to type in the Tcl console. First, type `pwd` to see where the console is currently running. You will need to navigate using `cd` to the `scripts` folder for CARAMEL. So, navigate with `cd` until you reach there.

9. Once in `scripts`, we will run the `automate_sim.tcl` command. Before doing so, I'd suggest making the tcl console window slightly bigger so you can see the output there. My setup is Tcl console on the left, waveform on the right. But that's up to you of course. Also, set up the waveform window because once we start running the script, you won't be able to adjust the window (e.g., zoom in and out) until it ends.

10. To run the script, type the following in the tcl command box and then press enter: `source -notrace automate_sim.tcl`.

11. After pressing enter, you should see the waveform start moving and `----- CARAMEL START -----` printed in the tcl console. Let it run until the simulation ends (for lcdnum, this is ~20ms of simulation time).

12. As it runs, you should see certain things print. `PREPPING FINAL MESSAGE RECIEVED` means we have reached `ER_done` and Vrf has validated all prior reports, so CARAMEL is preparing the final report.

13. Afterwards, the tcl console will print the estimated total run time. It is different than the simulation time since we are not simulating the HMAC. For example, lcdnum has a vivado simulation time of ~20 ms, but after calculating the additional time, the total time is ~0.107 seconds. Only the total estimated time will be printed in the final window.

14. I added in timeouts into the tcl script so they won't simulate forever. It's possible that other apps will require longer than the timeout i currently have there for lcdnum. If that is the case, feel free to adjust based on the ACFA time as an upper bound. Also feel free to message me and i can help you with this part.

15. Other helpful tips: you can do everything in vivado through the tcl window. So after re-making software, you can relaunch sim with the update .mem files with the following: `close_sim; launch_sim; source -notrace automate_sim.tcl`. 

16. If you want to rerun the current sim again (with identical software), use `relaunch_sim; source -notrace automate_sim.tcl`. Note that `relaunch_sim` won't update changes in the `.mem` files, so do step 15 if you updated any software in-between runs.

17. I'd suggest trying it out with lcdnum first. If you run into any issues, i can help you solve them since i have lcdnum working. After we confirm you have that one running, then we can divide the rest. Message me to let me know how it goes! 

# OLD STEPS

## how to simulate

1. In `acfa_hw/controller.v` use the simulation setting for `TX_RATE` (comment out line 78 and add line 77).

2. Run `make ultrasonic_sensor` from `scripts` directory

3. Run behavioral simulation

4. Load `scripts/tb_controller_behav.wcfg` into vivado as the waveform config

5. Simulate 0.5 ms of run-time

6. Right click `vrf_msg[32]` in waveform window, "Force Constant", set "Force Value" as e17a. This simulates receiving the first message (which is non-interrupt inducing)

7. Continue simulation for 7.5 ms. You should see `flush_slice` trigger a transmission, and `ER_done` occur without triggering a transmission, since no verifier response to the first report was simulated yet.

8. At this point, there is a ER_done based report that needs to be prepped and sent. To do so, need to simulated receiving vrf message. To do so, right click `vrf_irq` in the wave form window and "Force Constant". Set "Force Value" as 1 and "Cancel after time offset" to 6us.

9. Simulate for 5ms for it to complete.

## how to deploy on fpga

1. In `acfa_hw/controller.v` use the implementation setting for `TX_RATE` (comment out line 77 and add line 78).

2. Implement + generate bitstream

3. When its ready, click program device

4. Then AFTER programming the device, run `demo_vrf/uart.py`. 

5. After running it, the first slice will be recieved and printed in the window. The window will wait for you to trigger the "vrf accepted" message. Press ENTER to do so

6. Next, any subsequent messages (or run-time implementation errors) will occur
