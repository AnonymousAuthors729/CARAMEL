
`define NO_TIMEOUT
reg [32:0] total_cycles = 0;
integer outfile1;
initial
   begin
      $display(" ===============================================");
      $display("|                 START SIMULATION              |");
      $display(" ===============================================");
        
      outfile1=$fopen("./sim.txt","w");

      $display("pc = %h, r1 = %h, r2 = %h, r3 = %h, r4 = %h, r5 = %h, srom_dout = %h, srom_cen = %h, pmem_cen = %h\n", r0, r1, r2, r3, r4, r5, dut.srom_dout, dut.srom_cen, dut.pmem_cen);

      stimulus_done = 1;

     // reset_n       = 1'b1;
     // #93;
     // reset_n       = 1'b0;
   end


reg [32:0] num_non_tcb_cycles = 0;

integer slicefile;
integer i;
integer count = 0;

integer log_ptr = 0;
integer logged_events = 0;

// last instruction of <__stop_progExec__>:
parameter [15:0] PROGRAM_END_INST = 16'he17a;

reg [32:0] num_cycles = 0;
parameter MIN_TICKS = 0;
parameter MAX_TICKS = 100;

//============================================
// Printing to console and debug file
always @(posedge mclk)
begin

      #1 num_cycles = num_cycles + 1;

      if((num_cycles > MIN_TICKS) && (num_cycles < MAX_TICKS))
      begin
         $display("pc = %h, branch_detect = %h, cflow_src = %h, cflow_dest = %h\n",
            dut.acfa_0.pc,
            dut.acfa_0.cflow_0.branch_monitor_0.branch_detect,
            dut.acfa_0.cflow_0.cflow_src,
            dut.acfa_0.cflow_0.cflow_dest,
            );
      end
      // #1 $display("entering_TCB = %h, jmp_or_ret = %h, call = %h, call_irq = %h, irq = %h, acfa_nmi = %h\n",dut.acfa_0.cflow_0.log_monitor_0.entering_TCB,dut.acfa_0.cflow_0.branch_monitor_0.jmp_or_ret,dut.acfa_0.cflow_0.branch_monitor_0.call,dut.acfa_0.cflow_0.branch_monitor_0.call_irq,dut.acfa_0.cflow_0.branch_monitor_0.irq,dut.acfa_0.cflow_0.branch_monitor_0.acfa_nmi);
      
      // Check if r0 = exit instruction
      if(r0==PROGRAM_END_INST || num_cycles > MAX_TICKS)
      begin
            $display("Total time %d cycles", $signed(num_cycles));
            $display("Final state:\n");
            $finish;
      end
end


//=====================================================================
// Capture and write CF-Logs -- ONLY EDIT LOG FILE PATH (lines 68-76)
// //=====================================================================
// wire catch_log_ptr = (dut.acfa_0.pc == 16'ha000) && (dut.acfa_0.pc_nxt != 16'ha000) && (dut.acfa_0.cflow_0.prev_pc != 16'ha000);

// wire logReady = (dut.acfa_0.cflow_hw_wen == 0) && ~catch_log_ptr && (dut.acfa_0.pc > 16'ha000 && dut.acfa_0.pc < 16'hdffe);

// always @(posedge catch_log_ptr)
//       begin
//             $display("Catching log_ptr value (pc=%h)\n", dut.acfa_0.pc);
//             log_ptr <= dut.cflow_log_ptr;
//             //  logged_events <= ((dut.cflow_log_ptr + 16'h0002) >> 1);// + dut.cflow_log_ptr[0];
//             logged_events <= ((dut.cflow_log_ptr) >> 1);// + dut.cflow_log_ptr[0];
//       end

// always @(posedge logReady)
// begin
//       $display("Log is ready (pc=%h)\n", dut.acfa_0.pc);

//        case(count)
//            0: slicefile=$fopen("./0.cflog","w");
//            1: slicefile=$fopen("./1.cflog","w");
//            2: slicefile=$fopen("./2.cflog","w");
//            3: slicefile=$fopen("./3.cflog","w");
//            4: slicefile=$fopen("./4.cflog","w");
//            5: slicefile=$fopen("./5.cflog","w");
//            6: slicefile=$fopen("./6.cflog","w");
//            7: slicefile=$fopen("./7.cflog","w");
//            8: slicefile=$fopen("./8.cflog","w");
//            9: slicefile=$fopen("./9.cflog","w");
//        endcase
       

//        for (i = 0; i < log_ptr; i = i +2) begin
//           // $fdisplay(slicefile,"%h",dut.acfa_memory.logs.logs.ram[i]);  //write as hex 
//           $fdisplay(slicefile,"%h%h",dut.acfa_memory_0.cflog.cflog[i],dut.acfa_memory_0.cflog.cflog[i+1]);  //write as hex 
//            // $fdisplay(slicefile,"%h",dut.dmem_0.mem[16'h1100+i]);  //write as hex
//        end
//        $fdisplay(slicefile,"%d",log_ptr);  //write log_ptr as last value
//        $fdisplay(slicefile,"%d",logged_events);
       
//        $fclose(slicefile);

//        count = count + 1;
//        $display("count = %h\n", count);
// end
//============================================