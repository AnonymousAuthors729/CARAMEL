//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
// 
// *File Name: tb_openMSP430_fpga.v
// 
// *Module Description:
//                      openMSP430 FPGA testbench
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
//----------------------------------------------------------------------------
`include "timescale.v"
`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_defines.v"
`endif

module  tb_openMSP430_fpga;

//
// Wire & Register definition
//------------------------------
wire         [7:0] p3_dout = dut.p3_dout;
wire         [7:0] p1_dout = dut.p1_dout;
wire       [15:0] pc    = dut.openMSP430_0.inst_pc;

wire [15:0] data_addr = dut.openMSP430_0.acfa_0.data_addr;
wire data_en = dut.openMSP430_0.acfa_0.data_en;
wire data_wr = dut.openMSP430_0.acfa_0.data_wr;

wire       puc_rst = dut.openMSP430_0.puc_rst;
wire       acfa_reset = dut.openMSP430_0.acfa_0.cflow_reset;
wire       vrased_reset = dut.openMSP430_0.acfa_0.vrased_reset;
wire       garota_reset = dut.openMSP430_0.acfa_0.garota_reset;

// acfa triggers
wire       acfa_nmi = dut.openMSP430_0.acfa_0.cflow_0.acfa_nmi;
wire       boot = dut.boot;
wire       flush_log = dut.flush_log;
wire       flush_slice = dut.flush_slice;
wire       irq_ta0 = dut.irq_ta0;
wire       ER_done = dut.ER_done;

//track tcb 
parameter TCB_att_min = 16'ha100;
parameter TCB_att_max = 16'hbffe;
parameter TCB_wait_min = 16'ha14a;
parameter TCB_wait_max = 16'ha1ea; 
parameter TCB_min = 16'ha000;
parameter TCB_max = 16'hdffe;
wire       in_TCB_attest = (dut.openMSP430_0.pc >= TCB_att_min) & (dut.openMSP430_0.pc <= TCB_att_max);
wire       in_TCB_wait = (dut.openMSP430_0.pc >= TCB_wait_min) & (dut.openMSP430_0.pc <= TCB_wait_max);
wire       in_TCB = (dut.openMSP430_0.pc >= TCB_min) & (dut.openMSP430_0.pc <= TCB_max);
wire       in_ER = (dut.openMSP430_0.pc >= dut.ER_min) & (dut.openMSP430_0.pc <= dut.ER_max);
wire       per_en  = dut.per_en;



// CPU registers
//====================== 
//wire       [15:0] pc    = dut.openMSP430_0.inst_pc;
wire       [15:0] r0    = dut.openMSP430_0.execution_unit_0.register_file_0.r0;
wire       [15:0] r1    = dut.openMSP430_0.execution_unit_0.register_file_0.r1;
wire       [15:0] r2    = dut.openMSP430_0.execution_unit_0.register_file_0.r2;
wire       [15:0] r3    = dut.openMSP430_0.execution_unit_0.register_file_0.r3;
wire       [15:0] r4    = dut.openMSP430_0.execution_unit_0.register_file_0.r4;
wire       [15:0] r5    = dut.openMSP430_0.execution_unit_0.register_file_0.r5;
wire       [15:0] r6    = dut.openMSP430_0.execution_unit_0.register_file_0.r6;
wire       [15:0] r7    = dut.openMSP430_0.execution_unit_0.register_file_0.r7;
wire       [15:0] r8    = dut.openMSP430_0.execution_unit_0.register_file_0.r8;
wire       [15:0] r9    = dut.openMSP430_0.execution_unit_0.register_file_0.r9;
wire       [15:0] r10   = dut.openMSP430_0.execution_unit_0.register_file_0.r10;
wire       [15:0] r11   = dut.openMSP430_0.execution_unit_0.register_file_0.r11;
wire       [15:0] r12   = dut.openMSP430_0.execution_unit_0.register_file_0.r12;
wire       [15:0] r13   = dut.openMSP430_0.execution_unit_0.register_file_0.r13;
wire       [15:0] r14   = dut.openMSP430_0.execution_unit_0.register_file_0.r14;
wire       [15:0] r15   = dut.openMSP430_0.execution_unit_0.register_file_0.r15;

///$display("\tValue of log = %0d",dut.logmem_0.cflog[0]);  //write as hex 

integer log_ptr = 0;
integer logged_events = 0;

wire catch_log_ptr = (dut.openMSP430_0.acfa_0.pc == 16'ha000) && (dut.openMSP430_0.acfa_0.pc_nxt != 16'ha000) && (dut.openMSP430_0.acfa_0.cflow_0.prev_pc != 16'ha000);
always @(posedge catch_log_ptr)
begin
    log_ptr <= dut.cflow_log_ptr;
//  logged_events <= ((dut.cflow_log_ptr + 16'h0002) >> 1);// + dut.cflow_log_ptr[0];
    logged_events <= ((dut.cflow_log_ptr) >> 1);// + dut.cflow_log_ptr[0];
end

reg logReady = 1'b0;// = (dut.openMSP430_0.acfa_0.cflow_hw_wen == 0) && ~catch_log_ptr && (dut.openMSP430_0.acfa_0.pc == 16'ha000);
// generate log slices as files
// save cflog files
integer slicefile;
string fname;
integer i;

task save_cflog;
    input int bottom, top;

   //these are just a sainity check to compate between the sv task and the tcl file
//    $display("\tValue of top = %0d",top);
//    $display("\tValue of bottom = %0d",bottom);
//    $display("\tActual value of bottom = %0d",bottom_test);
    // fname = $sformatf("<LOGS_FULL_PATH>/%0d.cflog", count);

    
//        slicefile=$fopen(fname,"w");
        // since we wrap around the out put is generated differently this set up is also used in the tcb and I guess the controller.v as well it differentiates whether the bottom already loop but the top hasn't 
        //TODO: sainity check if the log out out now is correct or if we need more adjustments (shouldnt change much for the runtimes
        if (top < bottom)//normal top is above bottom 
        begin //2
            for (i = top; i <= bottom; i = i +2)
            begin //3
//               $fdisplay(slicefile,"%h%h",dut.acfa_memory_0.cflog.cflog[i],dut.acfa_memory_0.cflog.cflog[i+1]);  //write as hex 
//               $fdisplay(slicefile,"%h%h",dut.logmem_0.cflog[i],dut.logmem_0.cflog[i+1]);
            end //3
        end//2
        else if (top > bottom)//bottom has looped
        begin//4
           for (i = top; i < log_words ; i = i +2)// so we hand out top slice to the end of the cflog
            begin//5
//               $fdisplay(slicefile,"%h%h",dut.acfa_memory_0.cflog.cflog[i],dut.acfa_memory_0.cflog.cflog[i+1]);  //write as hex 
//                 $fdisplay(slicefile,"%h%h",dut.logmem_0.cflog[i],dut.logmem_0.cflog[i+1]);  //write as hex 
            end//5
            for (i = 0; i < bottom; i = i +2) // and then the beginning of the cflog until we reach bottom slice
            begin//6
//               $fdisplay(slicefile,"%h%h",dut.acfa_memory_0.cflog.cflog[i],dut.acfa_memory_0.cflog.cflog[i+1]);  //write as hex 
//                 $fdisplay(slicefile,"%h%h",dut.logmem_0.cflog[i],dut.logmem_0.cflog[i+1]);
            end//6
        end//4
        else
        begin//7
//            $fdisplay(slicefile,"%s","Yeah something is wrong bro...");
//            $fdisplay(slicefile,"%d",top);
//            $fdisplay(slicefile,"%d",bottom);
            
        end//7
        
endtask


int cflog_entries;
wire [15:0] top_test = dut.uut.top_catch;
wire [15:0] bottom_test = dut.uut.bottom_catch;
parameter CHAL_BYTES  = 32;
parameter METADATA_BYTES  = 14; 
parameter PMEM_BYTES  = 1000; // however much PMEM 
integer total_hmac1_bytes = 0;
int log_words = dut.openMSP430_0.acfa_0.cflow_0.slice_monitor_0.LOG_SIZE;
always @(posedge logReady) begin
    save_cflog(bottom_test, top_test);
    
// caluculation of the cflog entries needed to clauclate how many bytes we create the hmac from system is similar to the cflog out put
    if (dut.top_slice < dut.bottom_slice)
        cflog_entries = dut.bottom_slice-dut.top_slice;
    else if (dut.top_slice > dut.bottom_slice)
        cflog_entries = log_words-dut.top_slice + dut.bottom_slice;
    else
        $display("\tVlaue of hamc1 incalculable something is wrong :)");
        
    $display("\tNumber of entries for hmac1 calculation = %0d",cflog_entries);
    total_hmac1_bytes <= total_hmac1_bytes + 2*cflog_entries + METADATA_BYTES + CHAL_BYTES + PMEM_BYTES; 
end

parameter VALIDATE_MSG_ADDR = 16'hc01e;
wire in_validate = (dut.openMSP430_0.pc == VALIDATE_MSG_ADDR);
integer total_hmac2_bytes = 0; 
always @(posedge in_validate) begin
   total_hmac2_bytes <= total_hmac2_bytes + 37; // constant 37 each time
end

integer contentions = 0;
always @(posedge flush_log)
begin
    contentions <= contentions + 1;
end



/////////////////// NEW TRANSMISSION /////////////// 
integer count =0; 
 
string fname_test;
integer testfile;
always @(posedge dut.uut.start_log)///starts with sending the log entries
begin
//    $display("\tValue of top = %0d",top);///test
//    $display("\tValue of bottom = %0d",bottom);
//    $display("\tActual value of bottom = %0d",bottom_test);
    fname_test = $sformatf("<LOGS_FULL_PATH>/CARAMEL/logs/%0d.cflog", count);
    testfile=$fopen(fname_test,"w");   ///open new log file
    count <= count + 1;//count up for next cflog 
end
 
always @(posedge dut.uut.trigger)/// evey trigger writyes the byte currently send into the cflog (looks way different now --> might need a new parser somewhen
begin
//    $display("\tValue of sending = %0h",dut.uut.byte_val);
    $fdisplay(testfile,"%h",dut.uut.byte_val);
end
 
always @(negedge dut.uut.start_log) ///ends sending when log finished (wee could extend it to also include the rest of teh report ...
begin
    $fclose(testfile);
   
end


/*** Instantiate Module ***/

// Clock & Reset
reg               CLK_100MHz;
reg               RESET;

// Slide Switches
reg               SW7;
reg               SW6;
reg               SW5;
reg               SW4;
reg               SW3;
reg               SW2;
reg               SW1;
reg               SW0;

// Push Button Switches
reg               BTN2;
reg               BTN1;
reg               BTN0;

// LEDs

wire              LED7;
wire              LED6;
wire              LED5;
wire              LED4;
wire              LED3;
wire              LED2;
wire              LED1;
wire              LED0;

// Four-Sigit, Seven-Segment LED Display
wire              SEG_A;
wire              SEG_B;
wire              SEG_C;
wire              SEG_D;
wire              SEG_E;
wire              SEG_F;
wire              SEG_G;
wire              SEG_DP;
wire              SEG_AN0;
wire              SEG_AN1;
wire              SEG_AN2;
wire              SEG_AN3;

// UART
reg               UART_RXD;
wire              UART_TXD;

// JB-C
wire              JB1;
wire              JC1;
wire              JC2;
wire              JC7;

// Core debug signals
//wire   [8*32-1:0] i_state;
//wire   [8*32-1:0] e_state;
//wire       [31:0] inst_cycle;
//wire   [8*32-1:0] inst_full;
//wire       [31:0] inst_number;
wire       [15:0] inst_pc;
//wire   [8*32-1:0] inst_short;

//// Testbench variables
//integer           i;
integer           error;
reg               stimulus_done;


//
// Generate Clock & Reset
//------------------------------
initial
  begin
     CLK_100MHz = 1'b0;
      forever #10 CLK_100MHz <= ~CLK_100MHz; // 100 MHz
//     forever #40 CLK_100MHz <= ~CLK_100MHz; // 25 MHz (accurate to MSP430)
  end

initial
  begin
     RESET         = 1'b0;
     #100 RESET    = 1'b1;
     #600 RESET    = 1'b0;
  end

//
// Global initialization
//------------------------------
initial
  begin
     error         = 0;
     stimulus_done = 1;
     SW7           = 1'b0;  // Slide Switches
     SW6           = 1'b0;
     SW5           = 1'b0;
     SW4           = 1'b0;
     SW3           = 1'b0;
     SW2           = 1'b0;
     SW1           = 1'b0;
     SW0           = 1'b0;
     BTN2          = 1'b0;  // Push Button Switches
     BTN1          = 1'b1;  
     BTN0          = 1'b0;
     UART_RXD      = 1'b0;  // UART
     
     forever #137 BTN2 <= ~BTN2; 
  end

//
// openMSP430 FPGA Instance
//----------------------------------

openMSP430_fpga dut (

// Clock Sources
    .CLK_100MHz    (CLK_100MHz),
    //.CLK_SOCKET   (1'b0),

// Slide Switches
    .SW7          (SW7),
    .SW6          (SW6),
    .SW5          (SW5),
    .SW4          (SW4),
    .SW3          (SW3),
    .SW2          (SW2),
    .SW1          (SW1),
    .SW0          (SW0),

// Push Button Switches
    .BTN3         (RESET),
    .BTN2         (BTN2),
    .BTN1         (BTN1),
    .BTN0         (BTN0),
    
// RS-232 Port
    .UART_RXD     (UART_RXD),
    .UART_TXD     (UART_TXD),  

// LEDs
    .LED8         (LED8),
    .LED7         (LED7),
    .LED6         (LED6),
    .LED5         (LED5),
    .LED4         (LED4),
    .LED3         (LED3),
    .LED2         (LED2),
    .LED1         (LED1),
    .LED0         (LED0),
    
    
    // JB-C
    .JB1          (JB1),
    .JC1          (JC1),
    .JC2          (JC2),
    .JC7          (JC7),

// Four-Sigit, Seven-Segment LED Display
    .SEG_A        (SEG_A),
    .SEG_B        (SEG_B),
    .SEG_C        (SEG_C),
    .SEG_D        (SEG_D),
    .SEG_E        (SEG_E),
    .SEG_F        (SEG_F),
    .SEG_G        (SEG_G),
    .SEG_DP       (SEG_DP),
    .SEG_AN0      (SEG_AN0),
    .SEG_AN1      (SEG_AN1),
    .SEG_AN2      (SEG_AN2),
    .SEG_AN3      (SEG_AN3)
    );

   
//
// Debug utility signals
//----------------------------------------
/*
msp_debug msp_debug_0 (

// OUTPUTs
    .e_state      (e_state),       // Execution state
    .i_state      (i_state),       // Instruction fetch state
    .inst_cycle   (inst_cycle),    // Cycle number within current instruction
    .inst_full    (inst_full),     // Currently executed instruction (full version)
    .inst_number  (inst_number),   // Instruction number since last system reset
    .inst_pc      (inst_pc),       // Instruction Program counter
    .inst_short   (inst_short),    // Currently executed instruction (short version)

// INPUTs
    .mclk         (mclk),          // Main system clock
    .puc_rst      (puc_rst)        // Main system reset
);
*/
//
// Generate Waveform
//----------------------------------------
initial
  begin
   `ifdef VPD_FILE
     $vcdplusfile("tb_openMSP430_fpga.vpd");
     $vcdpluson();
   `else
     `ifdef TRN_FILE
        $recordfile ("tb_openMSP430_fpga.trn");
        $recordvars;
     `else
        $dumpfile("tb_openMSP430_fpga.vcd");
        $dumpvars(0, tb_openMSP430_fpga);
     `endif
   `endif
  end

//
// End of simulation
//----------------------------------------
/*
initial // Timeout
  begin
   `ifdef NO_TIMEOUT
   `else
     `ifdef VERY_LONG_TIMEOUT
       #500000000;
     `else     
     `ifdef LONG_TIMEOUT
       #5000000;
     `else     
       #500000;
     `endif
     `endif
       $display(" ===============================================");
       $display("|               SIMULATION FAILED               |");
       $display("|              (simulation Timeout)             |");
       $display(" ===============================================");
       $finish;
   `endif
  end
*/
initial // Normal end of test
  begin
     @(inst_pc===16'hffff)
     $display(" ===============================================");
     if (error!=0)
       begin
	  $display("|               SIMULATION FAILED               |");
	  $display("|     (some verilog stimulus checks failed)     |");
       end
     else if (~stimulus_done)
       begin
	  $display("|               SIMULATION FAILED               |");
	  $display("|     (the verilog stimulus didn't complete)    |");
       end
     else 
       begin
	  $display("|               SIMULATION PASSED               |");
       end
     $display(" ===============================================");
     $finish;
  end

//
// Tasks Definition
//------------------------------

   task tb_error;
      input [65*8:0] error_string;
      begin
	 $display("ERROR: %s %t", error_string, $time);
	 error = error+1;
      end
   endtask


endmodule