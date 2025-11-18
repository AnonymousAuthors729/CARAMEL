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
// *File Name: openMSP430_fpga.v
//
// *Module Description:
//                      openMSP430 FPGA Top-level for the Diligent
//                     Spartan-3 starter kit.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev$
// $LastChangedBy$
// $LastChangedDate$  
//----------------------------------------------------------------------------
`include "openMSP430_defines.v"
 
module openMSP430_fpga (

/// Clock Sources
    CLK_100MHz,  
//    CLK_SOCKET,

// Slide Switches
    SW7, 
    SW6,
    SW5,
    SW4, 
    SW3,
    SW2,
    SW1,
    SW0,

// Push Button Switches
    BTN3,
    BTN2,
    BTN1,
    BTN0,

// LEDs
    LED15,
    LED14,
    LED13,
    LED12,
    LED11,
    LED10,
    LED9,
    LED8,
    LED7,
    LED6,
    LED5,
    LED4,
    LED3,
    LED2,
    LED1,
    LED0,

// Four-Sigit, Seven-Segment LED Display
    SEG_A,
    SEG_B,
    SEG_C,
    SEG_D,
    SEG_E,
    SEG_F,
    SEG_G,
    SEG_DP,
    SEG_AN0,
    SEG_AN1,
    SEG_AN2,
    SEG_AN3,

// RS-232 Port
    UART_RXD,
    UART_TXD,
//    UART_RXD_A,
//    UART_TXD_A

// JB
    JB1,
//    JB2,
//    JB3,
//    JB4,
//    JB5,
//    JB6,
//    JB7
//    JB8

// JC
    JC1,
    JC2,
//    JC3,
//    JC4,
//    JC5,
//    JC6,
    JC7
//    JC8

// PS/2 Mouse/Keyboard Port
//    PS2_D,
//    PS2_C,

// Fast, Asynchronous SRAM
//    SRAM_A17,	            // Address Bus Connections
//    SRAM_A16,
//    SRAM_A15,
//    SRAM_A14,
//    SRAM_A13,
//    SRAM_A12,
//    SRAM_A11,
//    SRAM_A10,
//    SRAM_A9,
//    SRAM_A8,
//    SRAM_A7,
//    SRAM_A6,
//    SRAM_A5,
//    SRAM_A4,
//    SRAM_A3,
//    SRAM_A2,
//    SRAM_A1,
//    SRAM_A0,
//    SRAM_OE,                // Write enable and output enable control signals
//    SRAM_WE,
//    SRAM0_IO15,             // SRAM Data signals, chip enables, and byte enables
//    SRAM0_IO14,
//    SRAM0_IO13,
//    SRAM0_IO12,
//    SRAM0_IO11,
//    SRAM0_IO10,
//    SRAM0_IO9,
//    SRAM0_IO8,
//    SRAM0_IO7,
//    SRAM0_IO6,
//    SRAM0_IO5,
//    SRAM0_IO4,
//    SRAM0_IO3,
//    SRAM0_IO2,
//    SRAM0_IO1,
//    SRAM0_IO0,
//    SRAM0_CE1,
//    SRAM0_UB1,
//    SRAM0_LB1,
//    SRAM1_IO15,
//    SRAM1_IO14,
//    SRAM1_IO13,
//    SRAM1_IO12,
//    SRAM1_IO11,
//    SRAM1_IO10,
//    SRAM1_IO9,
//    SRAM1_IO8,
//    SRAM1_IO7,
//    SRAM1_IO6,
//    SRAM1_IO5,
//    SRAM1_IO4,
//    SRAM1_IO3,
//    SRAM1_IO2,
//    SRAM1_IO1,
//    SRAM1_IO0,
//    SRAM1_CE2,
//    SRAM1_UB2,
//    SRAM1_LB2,

// VGA Port
//    VGA_R,
//    VGA_G,
//    VGA_B,
//    VGA_HS,
//    VGA_VS
);

// Clock Sources
input     CLK_100MHz;
//input     CLK_SOCKET;

// Slide Switches
input     SW7;
input     SW6;
input     SW5;
input     SW4;
input     SW3;
input     SW2;
input     SW1;
input     SW0;

// Push Button Switches
input     BTN3;
input     BTN2;
input     BTN1;
input     BTN0;

// LEDs
output    LED15;
output    LED14;
output    LED13;
output    LED12;
output    LED11;
output    LED10;
output    LED9;
output    LED8;
output    LED7;
output    LED6;
output    LED5;
output    LED4;
output    LED3;
output    LED2;
output    LED1;
output    LED0;

// Four-Sigit, Seven-Segment LED Display
output    SEG_A;
output    SEG_B;
output    SEG_C;
output    SEG_D;
output    SEG_E;
output    SEG_F;
output    SEG_G;
output    SEG_DP;
output    SEG_AN0;
output    SEG_AN1;
output    SEG_AN2;
output    SEG_AN3;

// RS-232 Port
input     UART_RXD;
output    UART_TXD;
//input     UART_RXD_A;
//output    UART_TXD_A;//

// JB
output       JB1;

// JC
input       JC1;
inout      JC2;
output      JC7;



// PS/2 Mouse/Keyboard Port
//inout     PS2_D;
//output    PS2_C;

// Fast, Asynchronous SRAM
//output    SRAM_A17;	    // Address Bus Connections
//output    SRAM_A16;
//output    SRAM_A15;
//output    SRAM_A14;
//output    SRAM_A13;
//output    SRAM_A12;
//output    SRAM_A11;
//output    SRAM_A10;
//output    SRAM_A9;
//output    SRAM_A8;
//output    SRAM_A7;
//output    SRAM_A6;
//output    SRAM_A5;
//output    SRAM_A4;
//output    SRAM_A3;
//output    SRAM_A2;
//output    SRAM_A1;
//output    SRAM_A0;
//output    SRAM_OE;          // Write enable and output enable control signals
//output    SRAM_WE;
//inout     SRAM0_IO15;       // SRAM Data signals, chip enables, and byte enables
//inout     SRAM0_IO14;
//inout     SRAM0_IO13;
//inout     SRAM0_IO12;
//inout     SRAM0_IO11;
//inout     SRAM0_IO10;
//inout     SRAM0_IO9;
//inout     SRAM0_IO8;
//inout     SRAM0_IO7;
//inout     SRAM0_IO6;
//inout     SRAM0_IO5;
//inout     SRAM0_IO4;
//inout     SRAM0_IO3;
//inout     SRAM0_IO2;
//inout     SRAM0_IO1;
//inout     SRAM0_IO0;
//output    SRAM0_CE1;
//output    SRAM0_UB1;
//output    SRAM0_LB1;
//inout     SRAM1_IO15;
//inout     SRAM1_IO14;
//inout     SRAM1_IO13;
//inout     SRAM1_IO12;
//inout     SRAM1_IO11;
//inout     SRAM1_IO10;
//inout     SRAM1_IO9;
//inout     SRAM1_IO8;
//inout     SRAM1_IO7;
//inout     SRAM1_IO6;
//inout     SRAM1_IO5;
//inout     SRAM1_IO4;
//inout     SRAM1_IO3;
//inout     SRAM1_IO2;
//inout     SRAM1_IO1;
//inout     SRAM1_IO0;
//output    SRAM1_CE2;
//output    SRAM1_UB2;
//output    SRAM1_LB2;

// VGA Port
//output    VGA_R;
//output    VGA_G;
//output    VGA_B;
//output    VGA_HS;
//output    VGA_VS;


//=============================================================================
// 1)  INTERNAL WIRES/REGISTERS/PARAMETERS DECLARATION
//=============================================================================

// openMSP430 output buses
wire        [13:0] per_addr;
wire        [15:0] per_din;
wire         [1:0] per_we;
wire [`DMEM_MSB:0] dmem_addr;
wire        [15:0] dmem_din;
wire         [1:0] dmem_wen;
wire [`PMEM_MSB:0] pmem_addr;
wire        [15:0] pmem_din;
wire         [1:0] pmem_wen;
wire        [13:0] irq_acc;

// openMSP430 input buses
wire   	    [13:0] irq_bus;
wire        [15:0] per_dout;
wire        [15:0] dmem_dout;
wire        [15:0] dmem_ram_dout;

wire        [15:0] pmem_dout;

// GPIO
wire         [7:0] p1_din;
wire         [7:0] p1_dout;
wire         [7:0] p1_dout_en;
wire         [7:0] p1_sel;
wire         [7:0] p2_din;
wire         [7:0] p2_dout;
wire         [7:0] p2_dout_en;
wire         [7:0] p2_sel;
wire         [7:0] p3_din;
wire         [7:0] p3_dout;
wire         [7:0] p3_dout_en;
wire         [7:0] p3_sel;
wire         [7:0] p5_din;
wire         [7:0] p5_dout;
wire         [7:0] p5_dout_en;
wire         [7:0] p5_sel;
wire        [15:0] per_dout_dio;

// Timer A
wire        [15:0] per_dout_tA;

// 7 segment driver
wire        [15:0] per_dout_7seg;

// Simple UART
wire               irq_uart_rx;
wire               irq_uart_tx;
wire        [15:0] per_dout_uart;
wire               hw_uart_txd;
wire               hw_uart_rxd;

// VAPE metadata
wire        [15:0] ER_min;
wire        [15:0] ER_max;

// CFLOW metadata
wire        [15:0]  per_dout_acfa_memory;
wire                cflow_hw_wen;   
wire        [15:0]  cflow_log_ptr;
wire        [15:0]  cflow_src; 
wire        [15:0]  cflow_dest;
wire                flush_log;
wire                boot;
wire                ER_done;

// CARAMEL extension
wire          flush_slice;
wire  [15:0]  top_slice;
wire  [15:0]  bottom_slice; 

// Others
wire               reset_pin;


//=============================================================================
// 2)  CLOCK GENERATION
//=============================================================================

// Input buffers
//------------------------
IBUFG ibuf_clk_main   (.O(clk_100M_in),    .I(CLK_100MHz));
//IBUFG ibuf_clk_socket (.O(clk_socket_in), .I(CLK_SOCKET));


// Digital Clock Manager
//------------------------

// Generate 20MHz clock from 100MHz on-board oscillator  
//`define DCM_FX_MODE
`ifdef DCM_FX_MODE  
DCM dcm_adv_clk_main (   
 
// OUTPUTs
    .CLK0         (),
    .CLK90        (),
    .CLK180       (),
    .CLK270       (),
    .CLK2X        (),
    .CLK2X180     (),
    .CLKDV        (),
    .CLKFX        (dcm_clk),
    .CLKFX180     (),
    .PSDONE       (),
    .STATUS       (),
    .LOCKED       (dcm_locked),

// INPUTs
    .CLKIN        (clk_100M_in),
    .CLKFB        (1'b0),
    .PSINCDEC     (1'b0),
    .PSEN         (1'b0),
    .DSSEN        (1'b0),
    .RST          (reset_pin),
    .PSCLK        (1'b0)
);

// synopsys translate_off
defparam dcm_adv_clk_main.CLK_FEEDBACK          = "NONE";
defparam dcm_adv_clk_main.CLKDV_DIVIDE          = 10;
defparam dcm_adv_clk_main.CLKIN_DIVIDE_BY_2     = "FALSE";
defparam dcm_adv_clk_main.CLKIN_PERIOD          = 20.0;
defparam dcm_adv_clk_main.CLKOUT_PHASE_SHIFT    = "NONE";
defparam dcm_adv_clk_main.DESKEW_ADJUST         = "SYSTEM_SYNCHRONOUS";
defparam dcm_adv_clk_main.DFS_FREQUENCY_MODE    = "LOW";
defparam dcm_adv_clk_main.DLL_FREQUENCY_MODE    = "LOW";
defparam dcm_adv_clk_main.DUTY_CYCLE_CORRECTION = "TRUE";
defparam dcm_adv_clk_main.FACTORY_JF            = 16'hC080;
defparam dcm_adv_clk_main.PHASE_SHIFT           = 0;
defparam dcm_adv_clk_main.STARTUP_WAIT          = "FALSE";

defparam dcm_adv_clk_main.CLKFX_DIVIDE          = 5;
defparam dcm_adv_clk_main.CLKFX_MULTIPLY        = 2;
// synopsys translate_on
`else
DCM dcm_adv_clk_main (

// OUTPUTs
    .CLKDV        (dcm_clk),
    .CLKFX        (),
    .CLKFX180     (),
    .CLK0         (CLK0_BUF),
    .CLK2X        (),
    .CLK2X180     (),
    .CLK90        (),
    .CLK180       (),
    .CLK270       (),
    .LOCKED       (dcm_locked),
    .PSDONE       (),
    .STATUS       (),

// INPUTs
    .CLKFB        (CLKFB_IN),
    .CLKIN        (clk_100M_in),
    .PSEN         (1'b0),
    .PSINCDEC     (1'b0),
    .DSSEN        (1'b0),
    .PSCLK        (1'b0),
    .RST          (reset_pin)
);
BUFG CLK0_BUFG_INST (
    .I(CLK0_BUF),
    .O(CLKFB_IN)
);

// synopsys translate_off
defparam dcm_adv_clk_main.CLK_FEEDBACK          = "1X";
defparam dcm_adv_clk_main.CLKDV_DIVIDE          = 10;
defparam dcm_adv_clk_main.CLKFX_DIVIDE          = 1;
defparam dcm_adv_clk_main.CLKFX_MULTIPLY        = 4;
defparam dcm_adv_clk_main.CLKIN_DIVIDE_BY_2     = "FALSE";
defparam dcm_adv_clk_main.CLKIN_PERIOD          = 20.000;
defparam dcm_adv_clk_main.CLKOUT_PHASE_SHIFT    = "NONE";
defparam dcm_adv_clk_main.DESKEW_ADJUST         = "SYSTEM_SYNCHRONOUS";
defparam dcm_adv_clk_main.DFS_FREQUENCY_MODE    = "LOW";
defparam dcm_adv_clk_main.DLL_FREQUENCY_MODE    = "LOW";
defparam dcm_adv_clk_main.DUTY_CYCLE_CORRECTION = "TRUE";
defparam dcm_adv_clk_main.FACTORY_JF            = 16'h8080;
defparam dcm_adv_clk_main.PHASE_SHIFT           = 0;
defparam dcm_adv_clk_main.STARTUP_WAIT          = "FALSE";
// synopsys translate_on
`endif


//wire 	  dcm_locked = 1'b1;
//wire      reset_n;

//reg 	  dcm_clk;
//always @(posedge clk_100M_in)
//  if (~reset_n) dcm_clk <= 1'b0;
//  else          dcm_clk <= ~dcm_clk;


// Clock buffers
//------------------------
BUFG  buf_sys_clock  (.O(clk_sys), .I(dcm_clk));


//=============================================================================
// 3)  RESET GENERATION & FPGA STARTUP
//=============================================================================

// Reset input buffer
IBUF   ibuf_reset_n   (.O(reset_pin), .I(BTN3));
wire reset_pin_n = ~reset_pin;

// Release the reset only, if the DCM is locked
assign  reset_n = reset_pin_n & dcm_locked;

//Include the startup device
wire  gsr_tb;
wire  gts_tb;
//STARTUP_SPARTAN3 xstartup (.CLK(clk_sys), .GSR(gsr_tb), .GTS(gts_tb));


//=============================================================================
// 4)  OPENMSP430
//=============================================================================

openMSP430 openMSP430_0 (

// OUTPUTs
    .aclk              (),             // ASIC ONLY: ACLK
    .aclk_en           (aclk_en),      // FPGA ONLY: ACLK enable
    .dbg_freeze        (dbg_freeze),   // Freeze peripherals
    .dbg_i2c_sda_out   (),             // Debug interface: I2C SDA OUT
    .dbg_uart_txd      (dbg_uart_txd), // Debug interface: UART TXD
    .dco_enable        (),             // ASIC ONLY: Fast oscillator enable
    .dco_wkup          (),             // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    .dmem_addr         (dmem_addr),    // Data Memory address
    .dmem_cen          (dmem_cen),     // Data Memory chip enable (low active)
    .dmem_din          (dmem_din),     // Data Memory data input
    .dmem_wen          (dmem_wen),     // Data Memory write enable (low active)
    .irq_acc           (irq_acc),      // Interrupt request accepted (one-hot signal)
    .lfxt_enable       (),             // ASIC ONLY: Low frequency oscillator enable
    .lfxt_wkup         (),             // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    .mclk              (mclk),         // Main system clock
    .dma_dout          (),             // Direct Memory Access data output
    .dma_ready         (),             // Direct Memory Access is complete
    .dma_resp          (),             // Direct Memory Access response (0:Okay / 1:Error)
    .per_addr          (per_addr),     // Peripheral address
    .per_din           (per_din),      // Peripheral data input
    .per_we            (per_we),       // Peripheral write enable (high active)
    .per_en            (per_en),       // Peripheral enable (high active)
    .pmem_addr         (pmem_addr),    // Program Memory address
    .pmem_cen          (pmem_cen),     // Program Memory chip enable (low active)
    .pmem_din          (pmem_din),     // Program Memory data input (optional)
    .pmem_wen          (pmem_wen),     // Program Memory write enable (low active) (optional)
    .puc_rst           (puc_rst),      // Main system reset
    .smclk             (),             // ASIC ONLY: SMCLK
    .smclk_en          (smclk_en),     // FPGA ONLY: SMCLK enable
     
    .cflow_hw_wen      (cflow_hw_wen),
    .cflow_log_ptr     (cflow_log_ptr),
    .cflow_src         (cflow_src),
    .cflow_dest        (cflow_dest),
    .flush_log         (flush_log),
    .boot              (boot),
    .ER_done           (ER_done),
    .flush_slice       (flush_slice),
    .top_slice         (top_slice),
    .bottom_slice      (bottom_slice),

    .pc_out            (pc_out),
    .r15_out           (r15_out),
    .data_addr         (data_addr),
    .data_en           (data_en),
    .data_wr           (data_wr),

// INPUTs
    .irq_ta0           (irq_ta0),

    .cpu_en            (1'b1),         // Enable CPU code execution (asynchronous and non-glitchy)
    .dbg_en            (1'b1),         // Debug interface enable (asynchronous and non-glitchy)
    .dbg_i2c_addr      (7'h00),        // Debug interface: I2C Address
    .dbg_i2c_broadcast (7'h00),        // Debug interface: I2C Broadcast Address (for multicore systems)
    .dbg_i2c_scl       (1'b1),         // Debug interface: I2C SCL
    .dbg_i2c_sda_in    (1'b1),         // Debug interface: I2C SDA IN
    .dbg_uart_rxd      (dbg_uart_rxd), // Debug interface: UART RXD (asynchronous)
    .dco_clk           (clk_sys),      // Fast oscillator (fast clock)
    .dmem_dout         (dmem_dout),    // Data Memory data output
    .irq               (irq_bus),      // Maskable interrupts
    .lfxt_clk          (1'b0),         // Low frequency oscillator (typ 32kHz)
    .dma_addr          (15'h0000),     // Direct Memory Access address
    .dma_din           (16'h0000),     // Direct Memory Access data input
    .dma_en            (1'b0),         // Direct Memory Access enable (high active)
    .dma_priority      (1'b0),         // Direct Memory Access priority (0:low / 1:high)
    .dma_we            (2'b00),        // Direct Memory Access write byte enable (high active)
    .dma_wkup          (1'b0),         // ASIC ONLY: DMA Sub-System Wake-up (asynchronous and non-glitchy)
    .nmi               (nmi),          // Non-maskable interrupt (asynchronous)
    .per_dout          (per_dout),     // Peripheral data output
    .pmem_dout         (pmem_dout),    // Program Memory data output
    .reset_n           (reset_n),      // Reset Pin (low active, asynchronous and non-glitchy)
    .scan_enable       (1'b0),         // ASIC ONLY: Scan enable (active during scan shifting)
    .scan_mode         (1'b0),         // ASIC ONLY: Scan mode
    .wkup              (1'b0),          // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)
    .ER_min            (ER_min),
    .ER_max            (ER_max)       // VAPE
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

wire [3:0] anode; // anode signals of the 7-segment LED display
wire [6:0] LED_out; // cathode patterns of the 7-segment LED display
wire [15:0] pc_out;

reg [15:0] pc_d = 16'hffff;
reg [15:0] pc_buff = 16'h0000; 
reg rst_d;
reg [1:0] ctr; 

reg ER_done_status;
reg ER_done_trigger;

//for tb

reg finish;
reg send_done;


initial
begin
    pc_d <= 16'hffff;
    rst_d <= 1'b0; 
    ctr <= 2'b00;
    ER_done_status <= 1'b0;
    finish <= 1'b0;
    send_done <= 1'b0;
    ER_done_trigger <= 1'b0;
    // trigger <= 1'b0;
    // start <= 1'b0;
end  

///// DEBUG ZONE ////
reg [15:0] counter = 0;
// reg [15:0] r15_prev = 0;
// wire [15:0] r15_out;
reg no_rst = 1'b1;
reg t4_r = 1'b0;
reg t1_r = 1'b0;
reg t2_r = 1'b0;
reg t3_r = 1'b0;
reg [7:0] counter_t1 = 0;
reg [7:0] counter_t2 = 0;
reg [7:0] counter_t3 = 0;
reg [7:0] counter_t4 = 0;
//
wire [15:0] debug_min = 16'ha000;
wire [15:0] debug_max = 16'hfffe; ////////


`ifdef ACFA_EQUIPPED

always @(posedge mclk) begin

    if(puc_rst && pc_out != 0)
        no_rst <= 1'b0;

    if(flush_slice)
        t1_r = 1'b1;
    else if(~flush_slice & t1_r)
    begin
        counter_t1 <= counter_t1 + 1;
        t1_r <= 1'b0;
    end

    if(flush_log)
        t2_r = 1'b1;
    else if(~flush_log & t2_r)
    begin
        counter_t2 <= counter_t2 + 1;
        t2_r <= 1'b0;
    end

    if(ER_done)
        t3_r = 1'b1;
    else if(~ER_done & t3_r)
    begin
        counter_t3 <= counter_t3 + 1;
        t3_r <= 1'b0;
    end

    if(vrf_resp_irq)
        t4_r = 1'b1;
    else if(~vrf_resp_irq & t4_r)
    begin
        counter_t4 <= counter_t4 + 1;
        t4_r <= 1'b0;
    end
       
    // if(counter == 16'hffff)
    //     counter <= 16'h0;
    // else
    //     counter <= counter + 16'h1;

    // you're here? you must be trying to debug by printing pc values to the seven seg display
    // since the simulation works fine but implemented version doesn't
    // good luck my friend 

    ////print within range
    if (no_rst == 1'b1 && pc_out >= debug_min && pc_out <= debug_max)
        pc_d <= pc_out;

    ////print upon transition
    // if (no_rst == 1'b1 && (pc_buff == ER_max) & (pc_buff != pc_out)) //pc_out >= debug_min && pc_out <= debug_max && 
        // pc_d <= pc_out;
    // pc_buff <= pc_out;

end
    
    
always @(posedge mclk) begin
    if(ER_done & ~finish)
        finish = 1'b1;
    if(finish & start & ~send_done & ~ER_done_status)
        send_done = 1'b1;
end

`endif

wire [3:0] s0_src = p3_din[7] ?  pc_d[15:12]   :
                    p3_din[6] ?  0 :
                                 counter_t3[7:4];

wire [3:0] s1_src = p3_din[7] ?  pc_d[11:8]   :
                    p3_din[6] ?  0 :
                                 counter_t3[7:4];

wire [3:0] s2_src = p3_din[7] ?  pc_d[7:4]   :
                    p3_din[6] ?  p3_dout[7:4] : 
                                 counter_t4[7:4];

wire [3:0] s3_src = p3_din[7] ?  pc_d[3:0]   :
                    p3_din[6] ?  p3_dout[3:0] : 
                                 counter_t4[3:0];

// wire [3:0] s0_src = r15_out[15:12];
// wire [3:0] s1_src = r15_out[11:8];
// wire [3:0] s2_src = r15_out[7:4];
// wire [3:0] s3_src = r15_out[3:0];
 
my_7_seg_driver driver_7segment_0(
    .clock_100Mhz   (mclk), // 100 Mhz clock source on Basys 3 FPGA
    .s0_src         (s0_src), 
    .s1_src         (s1_src),
    .s2_src         (s2_src), 
    .s3_src         (s3_src),
    .reset          (), // reset 
    .anode          (anode), // anode signals of the 7-segment LED display
    .LED_out        (LED_out)// cathode patterns of the 7-segment LED display
);
////// END DEBUG ZONE   


wire trigger;
wire [15:0] read_idx;
wire continue; 
wire [7:0] byte_val;
wire t1;
wire t2;  
wire t3;
wire [15:0] log_ptr_catch_out;
wire start;


wire [`LOG_MSB:0]   log_addr_hw;
wire [15:0] read_val_log;
controller uut ( 
    /// inputs 
    .mclk             (mclk),
    .pc               (pc_out),
    .cflow_log_ptr    (cflow_log_ptr),
    .read_val         (read_val), 
    .boot             (boot),
    .flush_log        (flush_log),
    .flush_slice      (flush_slice),
    .ER_done          (ER_done),
    .vrf_response_out (vrf_response_out),
    .top_slice        (top_slice),
    .bottom_slice     (bottom_slice),

    // outputs
    .start_log   (start),
    .trigger (trigger),
    .read_idx (read_idx),
    .continue (continue),
    .byte_val (byte_val),

    .t1 (t1),
    .t2 (t2),
    .t3 (t3),
    .log_ptr_catch_out (log_ptr_catch_out), // debugging
    
     //logmem hardware reading 
    .log_idx        (log_addr_hw),
    .read_val_log    (read_val_log)      // Data memory data output for hardware is connected to controller (uut)
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
//wire [15:0] data_en;
//wire [15:0] data_wr;
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


//////////// CFLOG //////////////////    --> clean all the debugging in the end

wire [15:0] log_dout;  //Out put from the log mem

//wire        [15:0] log_din = dmem_din; ///data input defaults to dmem so we can use this with out adjusting it 

parameter LOG_END = `LOG_BASE+ `LOG_SIZE; // needed to calculate the boundaruies of CFLOG. CFlog sits between the base addr and the end 
parameter DMEM_END = `DMEM_BASE+ `DMEM_SIZE;



////deciding which memory region are we addressing, otherwise we might accidentially write to the dmem and cflog at the same time (absolutly did not happen while writting this)
////in other words we decide we want to address cflog if the addr pointer is with in cflog boundaries (sel = select)

wire  log_addr_sel = (data_addr>=`LOG_BASE) && (data_addr< LOG_END); //this works

//// memory works in the end like any other array. Each memory section is its own array so if we want to address logmem[0] the data_addr == LOG_BASE. So this line maps the data_addr to the addr with in logmem
wire [`LOG_MSB:0] log_addr_sw = ((data_addr-`LOG_BASE)>>1);//(switch LE BE)

//wire addr = dout_sel ? ((data_addr-`LOG_BASE)>>1): data_addr-(`DMEM_BASE>>1);

////this is just a debugging signal to make sure we address both ram regions at the right times :)
//// 1 if cflog is addressed and 3 if dmem is addressed otherwise it will be 0
//wire [1:0] sel = (data_addr>=`LOG_BASE) && (data_addr< LOG_END)? 2'b01:
//                   (data_addr>=`DMEM_BASE) && (data_addr< DMEM_END)? 2'b11 : 2'b00; 
                   //((data_addr>=(`DMEM_BASE>>1)) && (data_addr< ( DMEM_END >>1)) )? 2'b11 : 2'b00; 


////active on low!! This just shows that the logmem is actually enabled when it is addressed
wire log_cen = ~(data_en && log_addr_sel);
//wire         [1:0] log_wen = data_en ? ~data_wr: 3; /// this would need a real hard look but we dont write sw


//I think this can go :) is kinda double --testing
////same for dmem we adjust to ensure it is not selected when logmem is selected.  (cen_h) just to differentiate to the signal that comes from the mem_backbone which does the same what is done here (just doesn't have the logmem reguistered there).
////In my opinion it should be possible to integrate logmem into the memory backbone however it was advised against as this might mess with the longest path if not done correctly. So if anyone tries that be careful:)
//wire  dmem_addr_sel = (data_addr>=`DMEM_BASE) && (data_addr< DMEM_END) ;

//wire  [`DMEM_MSB:0] dmem_addr_h  = data_addr-(`DMEM_BASE>>1);

//wire dmem_cen_h = ~(data_en && dmem_addr_sel);



//in difference to the original we have two outputs leaving through the dmem_dout (which is the default so an additional dout (data_output) doesn't neede to be intergrated into the mem backbone)
//Ignore this it BS and did not work: all it does is a simple or so both signals can leave thorugh this. If both happen at the same time something is wrong. And there will be a mistake. 

// dout_sel selcts between logmem and dmem for the data output. It only changes the output when a new one is selected. There are probably other ways but all others failed on me.  
wire dout_sel = ~log_cen? 'b1 : ~dmem_cen ? 'b0: dout_sel;

//so this is the output mux depending on dout_sel it is either log or dmem. If dout_sel is 1 => TRUE then log_dout. 
assign dmem_dout =  dout_sel ? log_dout : dmem_ram_dout ;


                    
                    
//assign dmem_dout = dmem_ram_dout & {16{~dmem_cen}} | log_dout & {16{~log_cen}};//
//assign dmem_dout =  log_addr_sel ? log_dout : 
//                    dmem_addr_sel ? dmem_ram_dout:
//                    dmem_dout ; 


/////////// TESTIN DUMP DELETE WHEN WORKS
//wire [15:0] readtest;
//assign readtest = read_val_log;

parameter SMEM_BASE = `SMEM_BASE;
parameter SMEM_SIZE = `SMEM_SIZE;



logmem #(`LOG_MSB, `LOG_SIZE) logmem_0 (

// OUTPUTs
    .ram_dout    (log_dout),          // Data Memory data output
    .read_val_log    (read_val_log),      // Data memory data output for hardware is connected to controller (uut)

// INPUTs
    .ram_addr    (log_addr_sw),          // Data Memory address form the sw side --> should only be used for reading
    .read_addr_hw   (log_addr_hw),         // Data Memory address for the hw side  --> comes from the controller (uut)
    .ram_cen     (log_cen),           // Data Memory chip enable (low active)
    .ram_clk     (mclk),               // Data Memory clock
//    .ram_din     (log_din),           // Data Memory data input SW
//    .ram_wen     (log_wen),            // Data Memory write enable (low active) SW
    
    // relevant for writing the cflog form hw 
    .cflow_logs_ptr_din (cflow_log_ptr), // Control Flow: pointer to logs being modified
    .cflow_src          (cflow_src),     // Control Flow: jump from
    .cflow_dest         (cflow_dest),    // Control Flow: jump to
    .cflow_hw_wen       (cflow_hw_wen)  // Control Flow, write enable (only hardware can trigger)
);

`endif

//   
// Assign interrupts  
//-------------------------------

`ifdef ACFA_EQUIPPED
wire pc_in_ER = (pc_out >= ER_min) && (pc_out <= ER_max) && (ER_min != 0) && (ER_max != 0);
wire caramel_timer = irq_ta0 & pc_in_ER;
wire acfa_nmi = flush_log | flush_slice | boot | ER_done_trigger | vrf_resp_irq;


assign nmi        =  1'b0;
wire pc_in_TCB = (pc_out >= 16'ha000) && (pc_out <= 16'hdffe);
wire is_accepted_addr = (pc_out == 16'hdffc);
reg accepted = 1'b1;
always @(posedge mclk)
begin
    if (is_accepted_addr)
        accepted <= 1'b1;
    else if (flush_log | flush_slice | caramel_timer)
        accepted <= 1'b0;
end

always @(posedge mclk)
begin
    if(ER_done)
        ER_done_status <= 1'b1;
    else if(ER_done_status & accepted & ~pc_in_TCB)
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
`endif

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
// Combine peripheral data buses
//-------------------------------
assign per_dout = per_dout_dio  |
                  per_dout_tA   | 
                  per_dout_uart |
                  per_dout_acfa_memory;


//
// GPIO Function selection
//--------------------------

// P1.0/TACLK      I/O pin / Timer_A, clock signal TACLK input
// P1.1/TA0        I/O pin / Timer_A, capture: CCI0A input, compare: Out0 output
// P1.2/TA1        I/O pin / Timer_A, capture: CCI1A input, compare: Out1 output
// P1.3/TA2        I/O pin / Timer_A, capture: CCI2A input, compare: Out2 output
// P1.4/SMCLK      I/O pin / SMCLK signal output
// P1.5/TA0        I/O pin / Timer_A, compare: Out0 output
// P1.6/TA1        I/O pin / Timer_A, compare: Out1 output
// P1.7/TA2        I/O pin / Timer_A, compare: Out2 output
wire [7:0] p1_io_mux_b_unconnected;
wire [7:0] p1_io_dout;
wire [7:0] p1_io_dout_en;
wire [7:0] p1_io_din;

io_mux #8 io_mux_p1 (
		     .a_din      (p1_din),
		     .a_dout     (p1_dout),
		     .a_dout_en  (p1_dout_en),

		     .b_din      ({p1_io_mux_b_unconnected[7],
                                   p1_io_mux_b_unconnected[6],
                                   p1_io_mux_b_unconnected[5],
                                   p1_io_mux_b_unconnected[4],
                                   ta_cci2a,
                                   ta_cci1a,
                                   ta_cci0a,
                                   taclk
                                  }),
		     .b_dout     ({ta_out2,
                                   ta_out1,
                                   ta_out0,
                                   (smclk_en & mclk),
                                   ta_out2,
                                   ta_out1,
                                   ta_out0,
                                   1'b0
                                  }),
		     .b_dout_en  ({ta_out2_en,
                                   ta_out1_en,
                                   ta_out0_en,
                                   1'b1,
                                   ta_out2_en,
                                   ta_out1_en,
                                   ta_out0_en,
                                   1'b0
                                  }),

   	 	     .io_din     (p1_io_din),
		     .io_dout    (p1_io_dout),
		     .io_dout_en (p1_io_dout_en),

		     .sel        (p1_sel)
);



// P2.0/ACLK       I/O pin / ACLK output
// P2.1/INCLK      I/O pin / Timer_A, clock signal at INCLK
// P2.2/TA0        I/O pin / Timer_A, capture: CCI0B input
// P2.3/TA1        I/O pin / Timer_A, compare: Out1 output
// P2.4/TA2        I/O pin / Timer_A, compare: Out2 output
wire [7:0] p2_io_mux_b_unconnected;
wire [7:0] p2_io_dout;
wire [7:0] p2_io_dout_en;
wire [7:0] p2_io_din;

io_mux #8 io_mux_p2 (
		     .a_din      (p2_din),
		     .a_dout     (p2_dout),
		     .a_dout_en  (p2_dout_en),

		     .b_din      ({p2_io_mux_b_unconnected[7],
                                   p2_io_mux_b_unconnected[6],
                                   p2_io_mux_b_unconnected[5],
                                   p2_io_mux_b_unconnected[4],
                                   p2_io_mux_b_unconnected[3],
                                   ta_cci0b,
                                   inclk,
                                   p2_io_mux_b_unconnected[0]
                                  }),
		     .b_dout     ({1'b0,
                                   1'b0,
                                   1'b0,
                                   ta_out2,
                                   ta_out1,
                                   1'b0,
                                   1'b0,
                                   (aclk_en & mclk)
                                  }),
		     .b_dout_en  ({1'b0,
                                   1'b0,
                                   1'b0,
                                   ta_out2_en,
                                   ta_out1_en,
                                   1'b0,
                                   1'b0,
                                   1'b1
                                  }),

   	 	     .io_din     (p2_io_din),
		     .io_dout    (p2_io_dout),
		     .io_dout_en (p2_io_dout_en),

		     .sel        (p2_sel)
);


//=============================================================================
// 6)  PROGRAM AND DATA MEMORIES
//=============================================================================

// Data Memory

ram #(`DMEM_MSB, `DMEM_SIZE) dmem_0 (

// OUTPUTs
    .ram_dout    (dmem_ram_dout),          // Data Memory data output (_ram_) to differentiate to the original dmem_dout

// INPUTs
    .ram_addr    (dmem_addr),          // Data Memory address
    .ram_cen     (dmem_cen),           // Data Memory chip enable (low active)
    .ram_clk     (mclk),               // Data Memory clock
    .ram_din     (dmem_din),           // Data Memory data input
    .ram_wen     (dmem_wen)            // Data Memory write enable (low active)
);
   
pmem #(`PMEM_MSB, `PMEM_SIZE)//, ER_MAX_addr, OR_MAX_addr, EXEC_addr)
pmem_0 (

// OUTPUTs
    .ram_dout    (pmem_dout),          // Program Memory data output
// INPUTs
    .ram_addr    (pmem_addr),          // Program Memory address
    .ram_cen     (pmem_cen),           // Program Memory chip enable (low active)
    .ram_clk     (mclk),               // Program Memory clock
    .ram_din     (pmem_din),           // Program Memory data input
    .ram_wen     (pmem_wen)            // Program Memory write enable (low active)
);

//=============================================================================
// 7)  I/O CELLS
//=============================================================================


// Slide Switches (Port 1 inputs)
//--------------------------------
IBUF  SW7_PIN        (.O(p3_din[7]),                   .I(SW7));
IBUF  SW6_PIN        (.O(p3_din[6]),                   .I(SW6));
IBUF  SW5_PIN        (.O(p3_din[5]),                   .I(SW5));
//IBUF  SW4_PIN        (.O(p3_din[4]),                   .I(SW4));
//IBUF  SW4_PIN        (.O(1'b1),                        .I(SW4));
IBUF  SW3_PIN        (.O(p3_din[3]),                   .I(SW3));
IBUF  SW2_PIN        (.O(p3_din[2]),                   .I(SW2));
IBUF  SW1_PIN        (.O(p3_din[1]),                   .I(SW1));
IBUF  SW0_PIN        (.O(p3_din[0]),                   .I(SW0));

// LEDs (Port 1 outputs)
//-----------------------
wire [7:0] upper_LEDs; 
assign upper_LEDs[7] = irq_ta0; //stat_out[7];
assign upper_LEDs[6] = irq_ta0; //stat_out[6];
assign upper_LEDs[5] = irq_ta0; //stat_out[5];
assign upper_LEDs[4] = irq_ta0; //stat_out[4];
//assign upper_LEDs[3] = caramel_timer; //stat_out[3];
//assign upper_LEDs[2] = caramel_timer; //stat_out[2];
//assign upper_LEDs[1] = caramel_timer; //stat_out[1];
//assign upper_LEDs[0] = caramel_timer; //stat_out[0];

OBUF  LED15_PIN      (.I(upper_LEDs[7]),  .O(LED15));
OBUF  LED14_PIN      (.I(upper_LEDs[6]),  .O(LED14)); 
OBUF  LED13_PIN      (.I(upper_LEDs[5]),  .O(LED13));
OBUF  LED12_PIN      (.I(upper_LEDs[4]),  .O(LED12));
OBUF  LED11_PIN      (.I(upper_LEDs[3]),  .O(LED11));
OBUF  LED10_PIN      (.I(upper_LEDs[2]),  .O(LED10)); 
OBUF  LED9_PIN       (.I(upper_LEDs[1]),  .O(LED9));
OBUF  LED8_PIN       (.I(upper_LEDs[0]),  .O(LED8));
OBUF  LED7_PIN       (.I(p3_dout[7]),  .O(LED7));
OBUF  LED6_PIN       (.I(p3_dout[6]),  .O(LED6));
OBUF  LED5_PIN       (.I(p3_dout[5]),  .O(LED5));
OBUF  LED4_PIN       (.I(p3_dout[4]),  .O(LED4));
//OBUF  LED4_PIN       (.I(mclk),  .O(LED4));
OBUF  LED3_PIN       (.I(p3_dout[3]),  .O(LED3));
OBUF  LED2_PIN       (.I(p3_dout[2]),  .O(LED2));
OBUF  LED1_PIN       (.I(p3_dout[1]),  .O(LED1));
//OBUF  LED1_PIN       (.I(mclk),  .O(LED1));
OBUF  LED0_PIN       (.I(p3_dout[0]),  .O(LED0));

// Push Button Switches
//----------------------
//IBUF  BTN2_PIN       (.O(),                            .I(BTN2));
IBUF  BTN2_PIN       (.O(p2_io_din[1]),                            .I(BTN2));
//IBUF  BTN1_PIN       (.O(p2_io_din[0]),                            .I(BTN1));
IBUF  BTN1_PIN       (.O(),                            .I(BTN1));
//IBUF  BTN0_PIN       (.O(p1_io_din[0]),                            .I(BTN0));
IBUF  BTN0_PIN       (.O(),                            .I(BTN0));


// Four-Sigit, Seven-Segment LED Display
//---------------------------------------
OBUF  SEG_A_PIN      (.I(LED_out[6]),                      .O(SEG_A));
OBUF  SEG_B_PIN      (.I(LED_out[5]),                      .O(SEG_B));
OBUF  SEG_C_PIN      (.I(LED_out[4]),                      .O(SEG_C));
OBUF  SEG_D_PIN      (.I(LED_out[3]),                      .O(SEG_D));
OBUF  SEG_E_PIN      (.I(LED_out[2]),                      .O(SEG_E));
OBUF  SEG_F_PIN      (.I(LED_out[1]),                      .O(SEG_F));
OBUF  SEG_G_PIN      (.I(LED_out[0]),                      .O(SEG_G));
OBUF  SEG_DP_PIN     (.I(),                     .O(SEG_DP));
OBUF  SEG_AN0_PIN    (.I(anode[0]),                    .O(SEG_AN0));
OBUF  SEG_AN1_PIN    (.I(anode[1]),                    .O(SEG_AN1));
OBUF  SEG_AN2_PIN    (.I(anode[2]),                    .O(SEG_AN2));
OBUF  SEG_AN3_PIN    (.I(anode[3]),                    .O(SEG_AN3));

//assign SEG_A = LED_out[6];
//assign SEG_B = LED_out[5];
//assign SEG_C = LED_out[4];
//assign SEG_D = LED_out[3];
//assign SEG_E = LED_out[2];
//assign SEG_F = LED_out[1];
//assign SEG_G = LED_out[0];

//assign SEG_AN0 = anode[0];
//assign SEG_AN1 = anode[1];
//assign SEG_AN2 = anode[2];
//assign SEG_AN3 = anode[3];

// RS-232 Port
//----------------------
// P1.1 (TX) and P2.2 (RX)
//assign p1_io_din      = 8'h00;
//assign p2_io_din[7:3] = 5'h00;
//assign p2_io_din[1:0] = 2'h0;

// Mux the RS-232 port between:
//   - GPIO port P1.1 (TX) / P2.2 (RX)
//   - the debug interface.
//   - the simple hardware UART
//
// The mux is controlled with the SW0/SW1 switches:
//        00 = debug interface
//        01 = GPIO
//        10 = simple hardware uart
//        11 = debug interface
wire sdi_select  = ({p3_din[1], p3_din[0]}==2'b00) |
                   ({p3_din[1], p3_din[0]}==2'b11);
wire gpio_select = ({p3_din[1], p3_din[0]}==2'b01);
wire uart_select = ({p3_din[1], p3_din[0]}==2'b10);

wire   uart_txd_out = gpio_select ? p1_io_dout[1]  :
                      uart_select ? hw_uart_txd    : dbg_uart_txd;

wire   uart_rxd_in;
assign p2_io_din[2] = gpio_select ? uart_rxd_in : 1'b1;
assign hw_uart_rxd  = uart_select ? uart_rxd_in : 1'b1;
assign dbg_uart_rxd = sdi_select  ? uart_rxd_in : 1'b1;

IBUF  UART_RXD_PIN   (.O(uart_rxd_in),                 .I(UART_RXD));
OBUF  UART_TXD_PIN   (.I(uart_txd_out),                .O(UART_TXD));
//IBUF  UART_RXD_A_PIN (.O(),                            .I(UART_RXD_A));
//OBUF  UART_TXD_A_PIN (.I(1'b0),                        .O(UART_TXD_A));

//assign JC2 = p3_dout_en[4] ? p3_dout[4] : 1'bz;
//assign p3_din[4] = JC2;
//IOBUF TMP_HUMID_PIN  (.O(p5_din[1]), .I(p5_dout[1]), .T(~p5_dout_en[1]),        .IO(JC2));
//IOBUF TMP_HUMID_PIN  (.O(p3_dout[1]), .I(p3_din[1]), .T(p3_dout_en[1]),        .IO(JC2));
//OBUF  SENSOR_PIN   (.I(p3_dout[1] & p3_dout_en[1]),                .O(JC2));
//OBUF  SENSOR_PIN   (.I(1'b1),                .O(JC2));

//IBUF  UART_RXD_PIN   (.O(uart_rxd_in),                 .I(JC1));
//OBUF  UART_TXD_PIN   (.I(uart_txd_out),                .O(JC7));


// PS/2 Mouse/Keyboard Port
//--------------------------
//IOBUF PS2_D_PIN      (.O(), .I(1'b0), .T(1'b1),        .IO(PS2_D));
//OBUF  PS2_C_PIN      (.I(1'b0),                        .O(PS2_C));

// Fast, Asynchronous SRAM
//--------------------------
//OBUF  SRAM_A17_PIN   (.I(1'b0),                        .O(SRAM_A17));
//OBUF  SRAM_A16_PIN   (.I(1'b0),                        .O(SRAM_A16));
//OBUF  SRAM_A15_PIN   (.I(1'b0),                        .O(SRAM_A15));
//OBUF  SRAM_A14_PIN   (.I(1'b0),                        .O(SRAM_A14));
//OBUF  SRAM_A13_PIN   (.I(1'b0),                        .O(SRAM_A13));
//OBUF  SRAM_A12_PIN   (.I(1'b0),                        .O(SRAM_A12));
//OBUF  SRAM_A11_PIN   (.I(1'b0),                        .O(SRAM_A11));
//OBUF  SRAM_A10_PIN   (.I(1'b0),                        .O(SRAM_A10));
//OBUF  SRAM_A9_PIN    (.I(1'b0),                        .O(SRAM_A9));
//OBUF  SRAM_A8_PIN    (.I(1'b0),                        .O(SRAM_A8));
//OBUF  SRAM_A7_PIN    (.I(1'b0),                        .O(SRAM_A7));
//OBUF  SRAM_A6_PIN    (.I(1'b0),                        .O(SRAM_A6));
//OBUF  SRAM_A5_PIN    (.I(1'b0),                        .O(SRAM_A5));
//OBUF  SRAM_A4_PIN    (.I(1'b0),                        .O(SRAM_A4));
//OBUF  SRAM_A3_PIN    (.I(1'b0),                        .O(SRAM_A3));
//OBUF  SRAM_A2_PIN    (.I(1'b0),                        .O(SRAM_A2));
//OBUF  SRAM_A1_PIN    (.I(1'b0),                        .O(SRAM_A1));
//OBUF  SRAM_A0_PIN    (.I(1'b0),                        .O(SRAM_A0));
//OBUF  SRAM_OE_PIN    (.I(1'b1),                        .O(SRAM_OE));
//OBUF  SRAM_WE_PIN    (.I(1'b1),                        .O(SRAM_WE));
//IOBUF SRAM0_IO15_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO15));
//IOBUF SRAM0_IO14_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO14));
//IOBUF SRAM0_IO13_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO13));
//IOBUF SRAM0_IO12_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO12));
//IOBUF SRAM0_IO11_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO11));
//IOBUF SRAM0_IO10_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO10));
//IOBUF SRAM0_IO9_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO9));
//IOBUF SRAM0_IO8_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO8));
//IOBUF SRAM0_IO7_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO7));
//IOBUF SRAM0_IO6_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO6));
//IOBUF SRAM0_IO5_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO5));
//IOBUF SRAM0_IO4_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO4));
//IOBUF SRAM0_IO3_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO3));
//IOBUF SRAM0_IO2_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO2));
//IOBUF SRAM0_IO1_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO1));
//IOBUF SRAM0_IO0_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM0_IO0));
//OBUF  SRAM0_CE1_PIN  (.I(1'b1),                        .O(SRAM0_CE1));
//OBUF  SRAM0_UB1_PIN  (.I(1'b1),                        .O(SRAM0_UB1));
//OBUF  SRAM0_LB1_PIN  (.I(1'b1),                        .O(SRAM0_LB1));
//IOBUF SRAM1_IO15_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO15));
//IOBUF SRAM1_IO14_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO14));
//IOBUF SRAM1_IO13_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO13));
//IOBUF SRAM1_IO12_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO12));
//IOBUF SRAM1_IO11_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO11));
//IOBUF SRAM1_IO10_PIN (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO10));
//IOBUF SRAM1_IO9_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO9));
//IOBUF SRAM1_IO8_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO8));
//IOBUF SRAM1_IO7_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO7));
//IOBUF SRAM1_IO6_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO6));
//IOBUF SRAM1_IO5_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO5));
//IOBUF SRAM1_IO4_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO4));
//IOBUF SRAM1_IO3_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO3));
//IOBUF SRAM1_IO2_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO2));
//IOBUF SRAM1_IO1_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO1));
//IOBUF SRAM1_IO0_PIN  (.O(), .I(1'b0), .T(1'b1),        .IO(SRAM1_IO0));
//OBUF  SRAM1_CE2_PIN  (.I(1'b1),                        .O(SRAM1_CE2));
//OBUF  SRAM1_UB2_PIN  (.I(1'b1),                        .O(SRAM1_UB2));
//OBUF  SRAM1_LB2_PIN  (.I(1'b1),                        .O(SRAM1_LB2));

// VGA Port
//---------------------------------------
//OBUF  VGA_R_PIN      (.I(1'b0),                        .O(VGA_R));
//OBUF  VGA_G_PIN      (.I(1'b0),                        .O(VGA_G));
//OBUF  VGA_B_PIN      (.I(1'b0),                        .O(VGA_B));
//OBUF  VGA_HS_PIN     (.I(1'b0),                        .O(VGA_HS));
//OBUF  VGA_VS_PIN     (.I(1'b0),                        .O(VGA_VS));


endmodule // openMSP430_fpga
