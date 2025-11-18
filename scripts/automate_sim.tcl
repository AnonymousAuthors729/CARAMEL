## if the code echoing is annoying, run with:
## source -notrace script.tcl
## https://adaptivesupport.amd.com/s/article/62335?language=en_US

puts "----- CARAMEL START -----"

# to ensure vivado doesn't nuke your cpu in case of infinite loop for sme reason
set log_words [get_value {/tb_openMSP430_fpga/log_words}]
set WORST_CASE_TIMEOUT [expr {$log_words*2}] 
## so I set that higher as 100 didn't work with me saying we send the full log at once so 128 words (should also have set like this for all others)
set TIMEOUT_INNER 9000 
set i 0 
set STEP 500us

# constants PER APP (rounded times)
## aha_compress 
set WORD_VERIFY_TIME 100us

# baud rate 
# --> 115200 bits per second
# --> 14400 bytes per second
# --> 14.4 bytes per millisecond
# --> 1 bytes per 0.0694 ms
# --> 1 bytes per 69.4 us (call it 79)
set BAUD_BYTE_STEP 70
## message send from vrf to prv is 65 bytes
## so RX_TIME = 65 * BAUD_BYTE_STEP 
set RX_TIME [expr "$BAUD_BYTE_STEP * 65"]us

## start with prv waiting for vrf challenge for 0.5 ms
run $STEP

### prv first waits for AER min and max from vrf, so simulate that

##new ultrasonic --> e218
#temp_sens --> e232
#syringe --> e1fc
#rover --> e196


#add_force {/tb_openMSP430_fpga/count} {0}
add_force {/tb_openMSP430_fpga/dut/acfa_memory_0/vrf_resp_mem/mem[32]} -radix hex {e218 0ns}

puts "set mem to [get_value {/tb_openMSP430_fpga/dut/acfa_memory_0/vrf_resp_mem/mem[32]}]"

### repeat everying for each report until the ER_done-generated report
set exit_condition 0
set cflog_num 0
while { $exit_condition == 0 && $i < $WORST_CASE_TIMEOUT} {
	puts "Starting on Log No: $cflog_num"
	### no pending reports at this point, so run until the next report starts being sent sent (i.e., run while start = 0)
	set j 0
	while { [get_value {/tb_openMSP430_fpga/dut/uut/continue}] == 0 } {
		run $STEP
		if {$j == $TIMEOUT_INNER} {
			puts "too long to start sending"
			break
		} 
		incr j
	}
	if {$j == $TIMEOUT_INNER} {
			break
	} 

	


	puts "CM-UART Transmitting"

	### TODO --> save the cflog to a file
	## done
	set pc [get_value {/tb_openMSP430_fpga/dut/openMSP430_0/pc}]
	add_force {/tb_openMSP430_fpga/logReady} {1 1ns}
	puts "Saving $cflog_num.cflog at pc = $pc"

	set top_slice [get_value {/tb_openMSP430_fpga/dut/uut/top_catch}]
	scan $top_slice %x top_slice
	puts "TOPSLICE: $top_slice"
	set bottom_slice [get_value {/tb_openMSP430_fpga/dut/uut/bottom_catch}]
	scan $bottom_slice %x bottom_slice
	puts "bottom slice: $bottom_slice"
	
	
	### if we reached here, that means a transmisison started 
	### since we started transmitting, run until the tx is done (i.e., run while start = 1)
	set j 0 
	while { [get_value {/tb_openMSP430_fpga/dut/uut/continue}] == 1 } {
		run $STEP
		if {$j == $TIMEOUT_INNER} {
			puts "sending too too long"
			break
		} 
		incr j
	}
	if {$j == $TIMEOUT_INNER} {
		break
	} 

##TODO delay sending to vrf
	puts "CM-UART Done Transmitting. Waiting for VRF Response"

	puts "Network delay to vrf"
	run 50000us  
	### 50 ms per directio * 1000 for micro sec


	add_force {/tb_openMSP430_fpga/logReady} {0 1ns}
	#-------------------------
	### TODO -- variable wait time for based on total cfslizes (entry_vrf_time * report_size)
	#### DONE
	### you know, maybe we could pass this to the actual vrf and do it live, and then sim the actual vrf time.......... sure when the rest works:)
	## just a thought.
	#set top_slice [get_value {/tb_openMSP430_fpga/dut/uut/top_catch}]
	#scan $top_slice %x top_slice
	
	#puts "TOPSLICE: $top_slice"
	#set bottom_slice [get_value {/tb_openMSP430_fpga/dut/uut/bottom_catch}]
	#scan $bottom_slice %x bottom_slice
	#puts "bottom slice: $bottom_slice"
	# there was a problem when it claculated bottom-top and to was larger than bottom so: form what I saw in the logs as of yet we either send one slice or the whole log
	# so when the bottom is larger than top i set it to a fixed size of 128 word eg. length of log

	puts "calculating slice size"
	if {$bottom_slice < $top_slice} {
		set slice_size [format %d [expr "$log_words - $top_slice + $bottom_slice"]]
	} else {
		#so there where problems with calculating bottom - to as octal numbers so I first set that to calculate in hex
		set slice_size [format %d [expr "$bottom_slice - $top_slice"]] 
	}
	
	puts "Slice size: $slice_size"

	#Memo make sure that actually works numberwise with the new slice_size
	puts "Waiting for verify..."
	#run 1ns
	for {set i 0} {$i < $slice_size} {incr i} {
		run $WORD_VERIFY_TIME
	}

	puts "Network delay to prv"
	run 50000us

	### TODO -- fixed wait time to tx the response (time to send 65 bytes based on BAUD rate)
	#### DONE
	puts "Waiting for response..."
	#TODO delay recieving from vrf
	run $RX_TIME
	#run 1ns

	### TODO -- removed this fixed step when done the above 2 ^
	#### DONE
	# run $STEP

	## done verifying & simulating vrf send, so force vrf_irq
	add_force {/tb_openMSP430_fpga/dut/acfa_memory_0/vrf_irq} -radix hex {1 0ns} -cancel_after 6us
	puts "Got vrf response"

	##

	if { [get_value {/tb_openMSP430_fpga/dut/finish}] == 1 && [get_value {/tb_openMSP430_fpga/dut/ER_done_status}] == 0} {
		puts "program done: $[get_value {/tb_openMSP430_fpga/dut/finish}]"
		set exit_condition 1
	}	

	run $STEP
	incr i
	incr cflog_num

	# puts "end of while loop"
	# puts "$i"
}


# so we should set this to if i is larger than WORST case  or better why is slice size and worst case dependend on the same variable?
if {$i == $WORST_CASE_TIMEOUT || $j == $TIMEOUT_INNER} {
	puts "TIMEOUT: Timeout reached... double check before your computer is nuked"
} elseif {$exit_condition == 1} { #cathcing to make sure its actually finished and not anything else that went wrong
	puts "PREPPING FINAL MESSAGE RECIEVED"

	### TODO --> save the ER_done cflog to a file
	## done
	add_force {/tb_openMSP430_fpga/logReady} {1 1ns}


	##send_done status is only set if it was alrteady send so if it isn't it should be set only thi
	
	if {[get_value {/tb_openMSP430_fpga/dut/send_done}] == 0 } {


		### vrf responded, so run until the next report starts being sent sent (i.e., run while start = 0)
		while { [get_value {/tb_openMSP430_fpga/dut/uut/start}] == 0 } {
			run $STEP
		}
		puts "CM-UART Transmitting"

		### now we started transmitting, so run until the report is sent (i.e., run while start = 1)
		while { [get_value {/tb_openMSP430_fpga/dut/uut/start}] == 1 } {
			run $STEP
		}
		puts "CM-UART Done Transmitting"

		# close_sim 
		# launch_simulation

	}

	puts "----- CARAMEL DONE -----"
} else {
	## yep we reached something else went wrong good luck finding what it is :)
	## just incase something goes boom!

	puts "There is something wrong here bro..." 
	puts "log_num: $cflog_num"

}


##### TODO -- ADD IN the HMAC TIME blub
## done

## returns the time of the sim in micro seconds
## based on above ^ this captures execution + delays for vrf response
set cur_time [current_time] 
regexp {([0-9.]+)} $cur_time -> cur_time_num

set total_hmac1_bytes [get_value {/tb_openMSP430_fpga/total_hmac1_bytes}] 
puts "Total hmac1 bytes: $total_hmac1_bytes"
## per alex spreadsheet (in micro-sec) -- adjust if needed
set hmac1_per_byte_time 24
set hmac1_time [expr "$total_hmac1_bytes * $hmac1_per_byte_time"]
puts "Total hmac1 time: $hmac1_time"

set total_hmac2_bytes [get_value {/tb_openMSP430_fpga/total_hmac2_bytes}]
## per alex spreadsheet (in micro-sec) -- adjust if needed
set hmac2_per_byte_time 427
set hmac2_time [expr "$total_hmac2_bytes * $hmac2_per_byte_time"]
puts "Total hmac2 time: $hmac2_time"

### $hmac1_time
set total_run_time [expr "$hmac2_time + $cur_time_num"]  
set time_time_sec [expr {$total_run_time / 1000000.0}]
puts "Not adding calculated hmac1 anymore:)"
puts "Estimated total run time: $total_run_time micro-sec ($time_time_sec sec)"

set contentions [get_value {/tb_openMSP430_fpga/contentions}]
puts "Total contentions: $contentions"
puts "------------------------"