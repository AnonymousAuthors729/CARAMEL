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
// *File Name: tb_openMSP430.v
//
// *Module Description:
//                      openMSP430 testbench
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 103 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-05 15:44:48 +0100 (Sat, 05 Mar 2011) $
//----------------------------------------------------------------------------
`include "timescale.v"
`ifdef OMSP_NO_INCLUDE
`else
`include "openMSP430_defines.v"
`endif

module  tb_openMSP430;

//
// Wire & Register definition
//------------------------------

// Data Memory interface
wire [`DMEM_MSB:0] dmem_addr;
wire               dmem_cen;
wire        [15:0] dmem_din;
wire         [1:0] dmem_wen;
wire        [15:0] dmem_dout;

// Program Memory interface
wire [`PMEM_MSB:0] pmem_addr;
wire               pmem_cen;
wire        [15:0] pmem_din;
wire         [1:0] pmem_wen;
wire        [15:0] pmem_dout;

// Peripherals interface
wire        [13:0] per_addr;
wire        [15:0] per_din;
wire        [15:0] per_dout;
wire         [1:0] per_we;
wire               per_en;

// Direct Memory Access interface
wire        [15:0] dma_dout;
wire               dma_ready;
wire               dma_resp;
reg         [15:1] dma_addr;
reg         [15:0] dma_din;
reg                dma_en;
reg                dma_priority;
reg          [1:0] dma_we;
reg                dma_wkup;

// Digital I/O
wire               irq_port1;
wire               irq_port2;
wire        [15:0] per_dout_dio;
wire         [7:0] p1_dout;
wire         [7:0] p1_dout_en;
wire         [7:0] p1_sel;
wire         [7:0] p2_dout;
wire         [7:0] p2_dout_en;
wire         [7:0] p2_sel;
wire         [7:0] p3_dout;
wire         [7:0] p3_dout_en;
wire         [7:0] p3_sel;
wire         [7:0] p4_dout;
wire         [7:0] p4_dout_en;
wire         [7:0] p4_sel;
wire         [7:0] p5_dout;
wire         [7:0] p5_dout_en;
wire         [7:0] p5_sel;
wire         [7:0] p6_dout;
wire         [7:0] p6_dout_en;
wire         [7:0] p6_sel;
reg          [7:0] p1_din;
reg          [7:0] p2_din;
reg          [7:0] p3_din;
reg          [7:0] p4_din;
reg          [7:0] p5_din;
reg          [7:0] p6_din;

// Peripheral templates
wire        [15:0] per_dout_temp_8b;
wire        [15:0] per_dout_temp_16b;

// Timer A
wire               irq_ta0;
wire               irq_ta1;
wire        [15:0] per_dout_timerA;
reg                inclk;
reg                taclk;
reg                ta_cci0a;
reg                ta_cci0b;
reg                ta_cci1a;
reg                ta_cci1b;
reg                ta_cci2a;
reg                ta_cci2b;
wire               ta_out0;
wire               ta_out0_en;
wire               ta_out1;
wire               ta_out1_en;
wire               ta_out2;
wire               ta_out2_en;

// Clock / Reset & Interrupts
reg                dco_clk;
wire               dco_enable;
wire               dco_wkup;
reg                dco_local_enable;
reg                lfxt_clk;
wire               lfxt_enable;
wire               lfxt_wkup;
reg                lfxt_local_enable;
wire               mclk;
wire               aclk;
wire               aclk_en;
wire               smclk;
wire               smclk_en;
reg                reset_n;
wire               puc_rst;
reg                nmi;
reg  [`IRQ_NR-3:0] irq;
wire [`IRQ_NR-3:0] irq_acc;
wire [`IRQ_NR-3:0] irq_in;
reg                cpu_en;
reg         [13:0] wkup;
wire        [13:0] wkup_in;

// Scan (ASIC version only)
reg                scan_enable;
reg                scan_mode;

// Debug interface: UART
reg                dbg_en;
wire               dbg_freeze;
wire               dbg_uart_txd;
wire               dbg_uart_rxd;
reg                dbg_uart_rxd_sel;
reg                dbg_uart_rxd_dly;
reg                dbg_uart_rxd_pre;
reg                dbg_uart_rxd_meta;
reg         [15:0] dbg_uart_buf;
reg                dbg_uart_rx_busy;
reg                dbg_uart_tx_busy;

// Debug interface: I2C
wire               dbg_scl;
wire               dbg_sda;
wire               dbg_scl_slave;
wire               dbg_scl_master;
reg                dbg_scl_master_sel;
reg                dbg_scl_master_dly;
reg                dbg_scl_master_pre;
reg                dbg_scl_master_meta;
wire               dbg_sda_slave_out;
wire               dbg_sda_slave_in;
wire               dbg_sda_master_out;
reg                dbg_sda_master_out_sel;
reg                dbg_sda_master_out_dly;
reg                dbg_sda_master_out_pre;
reg                dbg_sda_master_out_meta;
wire               dbg_sda_master_in;
reg         [15:0] dbg_i2c_buf;
reg     [8*32-1:0] dbg_i2c_string;

// Core testbench debuging signals
wire    [8*32-1:0] i_state;
wire    [8*32-1:0] e_state;
wire        [31:0] inst_cycle;
wire    [8*32-1:0] inst_full;
wire        [31:0] inst_number;
wire        [15:0] inst_pc;
wire    [8*32-1:0] inst_short;

// Testbench variables
integer            tb_idx;
integer            tmp_seed;
integer            error;
reg                stimulus_done;


//
// Include files
//------------------------------

// CPU & Memory registers
`include "registers.v"

// Debug interface tasks
`include "dbg_uart_tasks.v"
`include "dbg_i2c_tasks.v"

// Direct Memory Access interface tasks
`include "dma_tasks.v"

// Verilog stimulus
`include "stimulus.v"


//
// Initialize Memory
//------------------------------
initial
  begin
     // Initialize data memory
     //for (tb_idx=0; tb_idx < `DMEM_SIZE/2; tb_idx=tb_idx+1)
     //  dmem_0.mem[tb_idx] = 16'h0000;

     // Initialize program memory
     $readmemh("./smem.mem", dut.srom_0.mem);
     #10 $readmemh("./pmem.mem", pmem_0.mem);
  end


//
// Generate Clock & Reset
//------------------------------
initial
  begin
     dco_clk          = 1'b0;
     dco_local_enable = 1'b0;
     forever
       begin
          #25;   // 20 MHz
          dco_local_enable = (dco_enable===1) ? dco_enable : (dco_wkup===1);
          if (dco_local_enable | scan_mode)
            dco_clk = ~dco_clk;
       end
  end

initial
  begin
     lfxt_clk          = 1'b0;
     lfxt_local_enable = 1'b0;
     forever
       begin
          #763;  // 655 kHz
          lfxt_local_enable = (lfxt_enable===1) ? lfxt_enable : (lfxt_wkup===1);
          if (lfxt_local_enable)
            lfxt_clk = ~lfxt_clk;
       end
  end

initial
  begin
     reset_n       = 1'b1;
     #93;
     reset_n       = 1'b0;
     #593;
     reset_n       = 1'b1;
  end

initial
  begin
     tmp_seed                = `SEED;
     tmp_seed                = $urandom(tmp_seed);
     error                   = 0;
     stimulus_done           = 1;
     irq                     = {`IRQ_NR-2{1'b0}};
     nmi                     = 1'b0;
     wkup                    = 14'h0000;
     dma_addr                = 15'h0000;
     dma_din                 = 16'h0000;
     dma_en                  = 1'b0;
     dma_priority            = 1'b0;
     dma_we                  = 2'b00;
     dma_wkup                = 1'b0;
     dma_tfx_cancel          = 1'b0;
     cpu_en                  = 1'b1;
     dbg_en                  = 1'b0;
     dbg_uart_rxd_sel        = 1'b0;
     dbg_uart_rxd_dly        = 1'b1;
     dbg_uart_rxd_pre        = 1'b1;
     dbg_uart_rxd_meta       = 1'b0;
     dbg_uart_buf            = 16'h0000;
     dbg_uart_rx_busy        = 1'b0;
     dbg_uart_tx_busy        = 1'b0;
     dbg_scl_master_sel      = 1'b0;
     dbg_scl_master_dly      = 1'b1;
     dbg_scl_master_pre      = 1'b1;
     dbg_scl_master_meta     = 1'b0;
     dbg_sda_master_out_sel  = 1'b0;
     dbg_sda_master_out_dly  = 1'b1;
     dbg_sda_master_out_pre  = 1'b1;
     dbg_sda_master_out_meta = 1'b0;
     dbg_i2c_string          = "";
     p1_din                  = 8'h00;
     p2_din                  = 8'h00;
     p3_din                  = 8'h00;
     p4_din                  = 8'h00;
     p5_din                  = 8'h00;
     p6_din                  = 8'h00;
     inclk                   = 1'b0;
     taclk                   = 1'b0;
     ta_cci0a                = 1'b0;
     ta_cci0b                = 1'b0;
     ta_cci1a                = 1'b0;
     ta_cci1b                = 1'b0;
     ta_cci2a                = 1'b0;
     ta_cci2b                = 1'b0;
     scan_enable             = 1'b0;
     scan_mode               = 1'b0;
  end


//
// Program Memory
//----------------------------------

ram #(`PMEM_MSB, `PMEM_SIZE) pmem_0 (

// OUTPUTs
    .ram_dout          (pmem_dout),            // Program Memory data output

// INPUTs
    .ram_addr          (pmem_addr),            // Program Memory address
    .ram_cen           (pmem_cen),             // Program Memory chip enable (low active)
    .ram_clk           (mclk),                 // Program Memory clock
    .ram_din           (pmem_din),             // Program Memory data input
    .ram_wen           (pmem_wen)              // Program Memory write enable (low active)
);


//
// Data Memory
//----------------------------------

ram #(`DMEM_MSB, `DMEM_SIZE) dmem_0 (

// OUTPUTs
    .ram_dout          (dmem_dout),            // Data Memory data output

// INPUTs
    .ram_addr          (dmem_addr),            // Data Memory address
    .ram_cen           (dmem_cen),             // Data Memory chip enable (low active)
    .ram_clk           (mclk),                 // Data Memory clock
    .ram_din           (dmem_din),             // Data Memory data input
    .ram_wen           (dmem_wen)              // Data Memory write enable (low active)
);


//
// openMSP430 Instance
//----------------------------------

openMSP430 dut (

// OUTPUTs
    .aclk              (aclk),                 // ASIC ONLY: ACLK
    .aclk_en           (aclk_en),              // FPGA ONLY: ACLK enable
    .dbg_freeze        (dbg_freeze),           // Freeze peripherals
    .dbg_i2c_sda_out   (dbg_sda_slave_out),    // Debug interface: I2C SDA OUT
    .dbg_uart_txd      (dbg_uart_txd),         // Debug interface: UART TXD
    .dco_enable        (dco_enable),           // ASIC ONLY: Fast oscillator enable
    .dco_wkup          (dco_wkup),             // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    .dmem_addr         (dmem_addr),            // Data Memory address
    .dmem_cen          (dmem_cen),             // Data Memory chip enable (low active)
    .dmem_din          (dmem_din),             // Data Memory data input
    .dmem_wen          (dmem_wen),             // Data Memory write byte enable (low active)
    .irq_acc           (irq_acc),              // Interrupt request accepted (one-hot signal)
    .lfxt_enable       (lfxt_enable),          // ASIC ONLY: Low frequency oscillator enable
    .lfxt_wkup         (lfxt_wkup),            // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    .mclk              (mclk),                 // Main system clock
    .dma_dout          (dma_dout),             // Direct Memory Access data output
    .dma_ready         (dma_ready),            // Direct Memory Access is complete
    .dma_resp          (dma_resp),             // Direct Memory Access response (0:Okay / 1:Error)
    .per_addr          (per_addr),             // Peripheral address
    .per_din           (per_din),              // Peripheral data input
    .per_en            (per_en),               // Peripheral enable (high active)
    .per_we            (per_we),               // Peripheral write byte enable (high active)
    .pmem_addr         (pmem_addr),            // Program Memory address
    .pmem_cen          (pmem_cen),             // Program Memory chip enable (low active)
    .pmem_din          (pmem_din),             // Program Memory data input (optional)
    .pmem_wen          (pmem_wen),             // Program Memory write byte enable (low active) (optional)
    .puc_rst           (puc_rst),              // Main system reset
    .smclk             (smclk),                // ASIC ONLY: SMCLK
    .smclk_en          (smclk_en),             // FPGA ONLY: SMCLK enable

// INPUTs
    .cpu_en            (cpu_en),               // Enable CPU code execution (asynchronous)
    .dbg_en            (dbg_en),               // Debug interface enable (asynchronous)
    .dbg_i2c_addr      (I2C_ADDR),             // Debug interface: I2C Address
    .dbg_i2c_broadcast (I2C_BROADCAST),        // Debug interface: I2C Broadcast Address (for multicore systems)
    .dbg_i2c_scl       (dbg_scl_slave),        // Debug interface: I2C SCL
    .dbg_i2c_sda_in    (dbg_sda_slave_in),     // Debug interface: I2C SDA IN
    .dbg_uart_rxd      (dbg_uart_rxd),         // Debug interface: UART RXD (asynchronous)
    .dco_clk           (dco_clk),              // Fast oscillator (fast clock)
    .dmem_dout         (dmem_dout),            // Data Memory data output
    .irq               (irq_in),               // Maskable interrupts
    .lfxt_clk          (lfxt_clk),             // Low frequency oscillator (typ 32kHz)
    .dma_addr          (dma_addr),             // Direct Memory Access address
    .dma_din           (dma_din),              // Direct Memory Access data input
    .dma_en            (dma_en),               // Direct Memory Access enable (high active)
    .dma_priority      (dma_priority),         // Direct Memory Access priority (0:low / 1:high)
    .dma_we            (dma_we),               // Direct Memory Access write byte enable (high active)
    .dma_wkup          (dma_wkup),             // ASIC ONLY: DMA Sub-System Wake-up (asynchronous and non-glitchy)
    .nmi               (nmi),                  // Non-maskable interrupt (asynchronous)
    .per_dout          (per_dout),             // Peripheral data output
    .pmem_dout         (pmem_dout),            // Program Memory data output
    .reset_n           (reset_n),              // Reset Pin (low active, asynchronous)
    .scan_enable       (scan_enable),          // ASIC ONLY: Scan enable (active during scan shifting)
    .scan_mode         (scan_mode),            // ASIC ONLY: Scan mode
    .wkup              (|wkup_in)              // ASIC ONLY: System Wake-up (asynchronous)
);


//=============================================================================
// 5)  OPENMSP430 PERIPHERALS
//=============================================================================

//
// Digital I/O
//-------------------------------

omsp_gpio #(.P1_EN(1),
            .P2_EN(1),
            .P3_EN(1),
            .P4_EN(0),
            .P5_EN(1),
            .P6_EN(0)) gpio_0 (

// OUTPUTs
    .irq_port1    (irq_port1),     // Port 1 interrupt
    .irq_port2    (irq_port2),     // Port 2 interrupt
    .p1_dout      (p1_dout),       // Port 1 data output
    .p1_dout_en   (p1_dout_en),    // Port 1 data output enable
    .p1_sel       (p1_sel),        // Port 1 function select
    .p2_dout      (p2_dout),       // Port 2 data output
    .p2_dout_en   (p2_dout_en),    // Port 2 data output enable
    .p2_sel       (p2_sel),        // Port 2 function select
    .p3_dout      (p3_dout),       // Port 3 data output
    .p3_dout_en   (p3_dout_en),    // Port 3 data output enable
    .p3_sel       (p3_sel),        // Port 3 function select
    .p4_dout      (),              // Port 4 data output
    .p4_dout_en   (),              // Port 4 data output enable
    .p4_sel       (),              // Port 4 function select
    .p5_dout      (p5_dout),              // Port 5 data output
    .p5_dout_en   (p5_dout_en),              // Port 5 data output enable
    .p5_sel       (p5_sel),              // Port 5 function select
    .p6_dout      (),              // Port 6 data output
    .p6_dout_en   (),              // Port 6 data output enable
    .p6_sel       (),              // Port 6 function select
    .per_dout     (per_dout_dio),  // Peripheral data output

// INPUTs
    .mclk         (mclk),          // Main system clock
    .p1_din       (p1_din),        // Port 1 data input
    .p2_din       (p2_din),        // Port 2 data input
    .p3_din       (p3_din),        // Port 3 data input
    .p4_din       (8'h00),         // Port 4 data input
    .p5_din       (p5_din),         // Port 5 data input
    .p6_din       (8'h00),         // Port 6 data input
    .per_addr     (per_addr),      // Peripheral address
    .per_din      (per_din),       // Peripheral data input
    .per_en       (per_en),        // Peripheral enable (high active)
    .per_we       (per_we),        // Peripheral write enable (high active)
    .puc_rst      (puc_rst)        // Main system reset
);

//
// Timer A
//----------------------------------------------

omsp_timerA timerA_0 (

// OUTPUTs
    .irq_ta0      (irq_ta0),       // Timer A interrupt: TACCR0
    .irq_ta1      (irq_ta1),       // Timer A interrupt: TAIV, TACCR1, TACCR2
    .per_dout     (per_dout_tA),   // Peripheral data output
    .ta_out0      (ta_out0),       // Timer A output 0
    .ta_out0_en   (ta_out0_en),    // Timer A output 0 enable
    .ta_out1      (ta_out1),       // Timer A output 1
    .ta_out1_en   (ta_out1_en),    // Timer A output 1 enable
    .ta_out2      (ta_out2),       // Timer A output 2
    .ta_out2_en   (ta_out2_en),    // Timer A output 2 enable

// INPUTs
    .ER_done_status (ER_done_status),
    .aclk_en      (aclk_en),       // ACLK enable (from CPU)
    .dbg_freeze   (dbg_freeze),    // Freeze Timer A counter
    .inclk        (inclk),         // INCLK external timer clock (SLOW)
    .irq_ta0_acc  (irq_acc[13]),    // Interrupt request TACCR0 accepted
//    .irq_ta0_acc  (irq_acc[9]),    // Interrupt request TACCR0 accepted
    .mclk         (mclk),          // Main system clock
    .per_addr     (per_addr),      // Peripheral address
    .per_din      (per_din),       // Peripheral data input
    .per_en       (per_en),        // Peripheral enable (high active)
    .per_we       (per_we),        // Peripheral write enable (high active)
    .puc_rst      (puc_rst),       // Main system reset
    .smclk_en     (smclk_en),      // SMCLK enable (from CPU)
    .ta_cci0a     (ta_cci0a),      // Timer A capture 0 input A
    .ta_cci0b     (ta_cci0b),      // Timer A capture 0 input B
    .ta_cci1a     (ta_cci1a),      // Timer A capture 1 input A
    .ta_cci1b     (1'b0),          // Timer A capture 1 input B
    .ta_cci2a     (ta_cci2a),      // Timer A capture 2 input A
    .ta_cci2b     (1'b0),          // Timer A capture 2 input B
    .taclk        (taclk)          // TACLK external timer clock (SLOW)
);

 
//
// Four-Digit, Seven-Segment LED Display driver
//----------------------------------------------
//driver_7segment driver_7segment_0 (

//// OUTPUTs
//    .per_dout     (per_dout_7seg), // Peripheral data output
//    .seg_a        (seg_a_),        // Segment A control
//    .seg_b        (seg_b_),        // Segment B control
//    .seg_c        (seg_c_),        // Segment C control
//    .seg_d        (seg_d_),        // Segment D control
//    .seg_e        (seg_e_),        // Segment E control
//    .seg_f        (seg_f_),        // Segment F control
//    .seg_g        (seg_g_),        // Segment G control
//    .seg_dp       (seg_dp_),       // Segment DP control
//    .seg_an0      (seg_an0_),      // Anode 0 control
//    .seg_an1      (seg_an1_),      // Anode 1 control
//    .seg_an2      (seg_an2_),      // Anode 2 control
//    .seg_an3      (seg_an3_),      // Anode 3 control

//// INPUTs
//    .mclk         (mclk),          // Main system clock
//    .per_addr     (per_addr),      // Peripheral address
//    .per_din      (per_din),       // Peripheral data input
//    .per_en       (per_en),        // Peripheral enable (high active)
//    .per_we       (per_we),        // Peripheral write enable (high active)
//    .puc_rst      (puc_rst)        // Main system reset
//);

wire [6:0] LED_out; // cathode patterns of the 7-segment LED display
wire [15:0] pc_out;

wire trigger;
wire [15:0] read_idx;
wire continue; 
wire [7:0] byte_val;
wire t1;
wire t2;  
wire t3;
wire [15:0] log_ptr_catch_out;
wire start;
controller uut ( 
    /// inputs 
    .mclk       (mclk),
    .pc         (pc_out),
    .cflow_log_ptr (cflow_log_ptr),
    .read_val   (read_val), 
    .boot       (boot),
    .flush_log  (flush_log),
    .flush_slice  (flush_slice),
    .ER_done    (ER_done),
    .vrf_response_out (vrf_response_out),
    .top_slice (top_slice),
    .bottom_slice (bottom_slice),

    // outputs
    .start   (start),
    .trigger (trigger),
    .read_idx (read_idx),
    .continue (continue),
    .byte_val (byte_val),

    .t1 (t1),
    .t2 (t2),
    .t3 (t3),
    .log_ptr_catch_out (log_ptr_catch_out) // debugging
);

// 
// Simple full duplex UART (8N1 protocol)
//----------------------------------------

wire [7:0] ctrl_out;
wire [7:0] stat_out; 
wire rx_done;

wire [7:0] rx_data_out;
// reg [15:0] rx_disp = 16'h0;
// reg debug = 1'b0;

// CMP-UART
omsp_uart #(.BASE_ADDR(15'h0080)) uart_0 (

// OUTPUTs
    .irq_uart_rx  (irq_uart_rx),   // UART receive interrupt
    .irq_uart_tx  (irq_uart_tx),   // UART transmit interrupt
    .per_dout     (per_dout_uart), // Peripheral data output
    .uart_txd     (hw_uart_txd),   // UART Data Transmit (TXD)
    .ctrl_out     (ctrl_out),
    .stat_out     (stat_out),
    .tx_triggered (tx_triggered),
    .tx_done      (tx_done),
    .rx_done      (rx_done),
    .rx_data_out  (rx_data_out),

// INPUTs
    .mclk         (mclk),          // Main system clock
    .per_addr     (per_addr),      // Peripheral address
    .per_din      (per_din),       // Peripheral data input
    .per_en       (per_en),        // Peripheral enable (high active)
    .per_we       (per_we),        // Peripheral write enable (high active)
    .puc_rst      (puc_rst),       // Main system reset
    .smclk_en     (smclk_en),      // SMCLK enable (from CPU)
    .uart_rxd     (hw_uart_rxd),    // UART Data Receive (RXD)
    .irq_rx_acc  (irq_acc[11]),    // Interrupt request RX accepted
    .irq_tx_acc  (irq_acc[6]),    // Interrupt request TX accepted
    .controller_en    (trigger & continue),
    .cflog_val  (byte_val)
);


// acfa_memory
//-----------------------------------------------
//wire [15:0] LOG_size; 
`ifdef ACFA_EQUIPPED
wire [15:0] read_val;
wire [15:0] vrfmem_write_out;
//
wire [15:0] data_addr;
wire [15:0] data_en;
wire [15:0] data_wr;
wire vrf_resp_irq;
wire entered_TCB = (pc_out == 16'ha002);
wire [15:0] vrf_response_out;
wire [15:0] log_state_out;
acfa_memory acfa_memory_0 (

// OUTPUTs
    .per_dout           (per_dout_acfa_memory), // Peripheral data output
    .ER_min             (ER_min),                          // VAPE ER_min
    .ER_max             (ER_max),                          // VAPE ER_max
    .read_val           (read_val),
    .vrfmem_write_out   (vrfmem_write_out),
    .vrf_resp_irq       (vrf_resp_irq),
    .vrf_response_out   (vrf_response_out),
    .log_state_out      (log_state_out),
    
    // INPUTs
    .data_addr          (data_addr),
    .data_en            (data_en),
    .data_wr            (data_wr),
    
    // caramel
    .cm_uart_continue   (continue),
    .entered_TCB        (entered_TCB),
    .boot_done           (boot_done),
    .flush_log          (flush_log),
    .flush_slice        (flush_slice),
    .ER_done            (ER_done),
    .top_slice          (top_slice),
    .bottom_slice       (bottom_slice),
    .rx_done            (rx_done),
    .rx_data_out        (rx_data_out),
    .read_idx           (read_idx),
 
    //
    .mclk               (mclk),          // Main system clock
    .per_addr           (per_addr),      // Peripheral address
    .per_din            (per_din),       // Peripheral data input
    .per_en             (per_en),        // Peripheral enable (high active)
    .per_we             (per_we),        // Peripheral write enable (high active)
    .cflow_logs_ptr_din (cflow_log_ptr), // Control Flow: pointer to logs being modified
    .cflow_src          (cflow_src),     // Control Flow: jump from
    .cflow_dest         (cflow_dest),    // Control Flow: jump to
    .cflow_hw_wen       (cflow_hw_wen),  // Control Flow, write enable (only hardware can trigger)
    .puc_rst            (puc_rst)        // Main system reset
);
`endif

//   
// Assign interrupts  
//-------------------------------
    
always @(posedge mclk)
begin
    nmi <= 1'b0;
end

wire is_accepted_addr = (pc_out == 16'hdffc);
reg ER_done_status = 1'b0;
reg ER_done_trigger = 1'b0;
always @(posedge mclk)
begin
    if(ER_done)
        ER_done_status <= 1'b1;
    else if(ER_done_status & is_accepted_addr)
    begin
        ER_done_trigger <= 1'b1;
        ER_done_status <= 1'b0;
    end
    else
        ER_done_trigger <= 1'b0;
end

reg boot_pnd = 1'b0;
reg boot_done = 1'b0;
wire tcb_exit = (pc_out == 16'hdffe);
always @(posedge mclk)
begin
    if(boot)
        boot_pnd <= 1'b1;
    else if(ER_done_status & tcb_exit)
    begin
        boot_done <= 1'b1;
        boot_pnd <= 1'b0;
    end
end

wire pc_in_ER = (pc_out >= ER_min) && (pc_out <= ER_max) && (ER_min != 0) && (ER_max != 0);
wire caramel_timer = irq_ta0 & pc_in_ER;
wire acfa_nmi = flush_log | flush_slice | boot | ER_done_trigger | vrf_resp_irq;
`ifdef ACFA_EQUIPPED
assign irq_bus    = {acfa_nmi,     // Vector 13  (0xFFFA)
                     caramel_timer,         // Vector 12  (0xFFF8)
                     irq_uart_rx,  // Vector 11  (0xFFF6)
                     1'b0,         // Vector 10  (0xFFF4) - Watchdog -
                     1'b0,         // Vector  9  (0xFFF2)
                     irq_ta1,      // Vector  8  (0xFFF0)
                     1'b0,         // Vector  7  (0xFFEE)
                     irq_uart_tx,  // Vector  6  (0xFFEC) 
                     1'b0,         // Vector  5  (0xFFEA)
                     1'b0,         // Vector  4  (0xFFE8)
                     irq_port2,    // Vector  3  (0xFFE6)
                     irq_port1,    // Vector  2  (0xFFE4)
                     1'b0,         // Vector  1  (0xFFE2)
                     1'b0};        // Vector  0  (0xFFE0)
`else 
assign irq_bus    = {1'b0,     // Vector 13  (0xFFFA)
                     1'b0,         // Vector 12  (0xFFF8)
                     irq_uart_rx,  // Vector 11  (0xFFF6)
                     1'b0,         // Vector 10  (0xFFF4) - Watchdog -
                     irq_ta0,      // Vector  9  (0xFFF2)
                     irq_ta1,      // Vector  8  (0xFFF0)
                     1'b0,         // Vector  7  (0xFFEE)
                     irq_uart_tx,  // Vector  6  (0xFFEC) 
                     1'b0,         // Vector  5  (0xFFEA)
                     1'b0,         // Vector  4  (0xFFE8)
                     irq_port2,    // Vector  3  (0xFFE6)
                     irq_port1,    // Vector  2  (0xFFE4)
                     1'b0,         // Vector  1  (0xFFE2)
                     1'b0};        // Vector  0  (0xFFE0)
`endif

//
// I2C serial debug interface
//----------------------------------

// I2C Bus
//.........................
pullup dbg_scl_inst (dbg_scl);
pullup dbg_sda_inst (dbg_sda);

// I2C Slave (openMSP430)
//.........................
io_cell scl_slave_inst (
    .pad               (dbg_scl),              // I/O pad
    .data_in           (dbg_scl_slave),        // Input
    .data_out_en       (1'b0),                 // Output enable
    .data_out          (1'b0)                  // Output
);

io_cell sda_slave_inst (
    .pad               (dbg_sda),              // I/O pad
    .data_in           (dbg_sda_slave_in),     // Input
    .data_out_en       (!dbg_sda_slave_out),   // Output enable
    .data_out          (1'b0)                  // Output
);

// I2C Master (Debugger)
//.........................
io_cell scl_master_inst (
    .pad               (dbg_scl),              // I/O pad
    .data_in           (),                     // Input
    .data_out_en       (!dbg_scl_master),      // Output enable
    .data_out          (1'b0)                  // Output
);

io_cell sda_master_inst (
    .pad               (dbg_sda),              // I/O pad
    .data_in           (dbg_sda_master_in),    // Input
    .data_out_en       (!dbg_sda_master_out),  // Output enable
    .data_out          (1'b0)                  // Output
);


//
// Debug utility signals
//----------------------------------------
msp_debug msp_debug_0 (

// OUTPUTs
    .e_state           (e_state),              // Execution state
    .i_state           (i_state),              // Instruction fetch state
    .inst_cycle        (inst_cycle),           // Cycle number within current instruction
    .inst_full         (inst_full),            // Currently executed instruction (full version)
    .inst_number       (inst_number),          // Instruction number since last system reset
    .inst_pc           (inst_pc),              // Instruction Program counter
    .inst_short        (inst_short),           // Currently executed instruction (short version)

// INPUTs
    .mclk              (mclk),                 // Main system clock
    .puc_rst           (puc_rst)               // Main system reset
);


//
// Generate Waveform
//----------------------------------------
initial
  begin
   `ifdef NODUMP
   `else
     `ifdef VPD_FILE
        $vcdplusfile("tb_openMSP430.vpd");
        $vcdpluson();
     `else
       `ifdef TRN_FILE
          $recordfile ("tb_openMSP430.trn");
          $recordvars;
       `else
          $dumpfile("tb_openMSP430.vcd");
          $dumpvars(0, tb_openMSP430);
       `endif
     `endif
   `endif
  end

//
// End of simulation
//----------------------------------------

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
       $display("");
       tb_extra_report;
       $finish;
   `endif
  end

initial // Normal end of test
  begin
     @(negedge stimulus_done);
     wait(inst_pc=='hffff);

     $display(" ===============================================");
     if ((dma_rd_error!=0) || (dma_wr_error!=0))
       begin
          $display("|               SIMULATION FAILED               |");
          $display("|           (some DMA transfer failed)          |");
       end
     else if (error!=0)
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
     $display("");
     tb_extra_report;
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

   task tb_extra_report;
      begin
         $display("DMA REPORT: Total Accesses: %-d Total RD: %-d Total WR: %-d", dma_cnt_rd+dma_cnt_wr,     dma_cnt_rd,   dma_cnt_wr);
         $display("            Total Errors:   %-d Error RD: %-d Error WR: %-d", dma_rd_error+dma_wr_error, dma_rd_error, dma_wr_error);
         if (!((`PMEM_SIZE>=4092) && (`DMEM_SIZE>=1024)))
           begin
	      $display("");
              $display("Note: DMA if verification disabled (PMEM must be 4kB or bigger, DMEM must be 1kB or bigger)");
           end
         $display("");
         $display("SIMULATION SEED: %d", `SEED);
         $display("");
      end
   endtask

   task tb_skip_finish;
      input [65*8-1:0] skip_string;
      begin
         $display(" ===============================================");
         $display("|               SIMULATION SKIPPED              |");
         $display("%s", skip_string);
         $display(" ===============================================");
         $display("");
         tb_extra_report;
         $finish;
      end
   endtask

endmodule
