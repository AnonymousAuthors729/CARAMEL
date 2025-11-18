
module  acfa_memory (

// OUTPUTs
    per_dout,                        // Peripheral data output for SW
    ER_min,                          // VAPE ER_min
    ER_max,                          // VAPE ER_max
    read_val,                       // read out put for hard ware 
    vrfmem_write_out,
//    LOG_size,                  // Max log size
    vrf_resp_irq,
    vrf_response_out,
    log_state_out,              //current state of the cflog for vrf/ report necessary

    // INPUTs
    data_addr,              //addr from SW
    data_wr,                // write enabled?
    data_en,                // data genrally enabled /// WHy is it needed here if its peripheral mem?
    //
    cm_uart_continue,           //continue form controller.v
    entered_TCB,
    boot_done,                  // system is up and running
    //cflog signals
    flush_log,
    flush_slice,
    ER_done,
    top_slice,
    bottom_slice,
    
    rx_done,                    //receiving from uart (when doen this should trigger the tcb)
    rx_data_out, 
    read_idx,                       // read value from controller.v 
    //   
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address   
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    
    //writing the cflog I think they can be cleaned out?
    cflow_logs_ptr_din,             // Control Flow: pointer to logs being modified
    cflow_src,
    cflow_dest, 
    cflow_hw_wen,
    puc_rst                         // Main system reset
); 

// OUTPUTs
//=========
output      [15:0] per_dout;        // Peripheral data output
output      [15:0] ER_min;                          // VAPE ER_min
output      [15:0] ER_max;                          // VAPE ER_max
output      [15:0] read_val;
output      [15:0] vrfmem_write_out;
output reg         vrf_resp_irq;
output      [15:0] vrf_response_out;
output      [15:0] log_state_out;
//output      [15:0] LOG_size;                          //  Max log size

// INPUTs
//=========
input        [15:0] data_addr;
input               data_en;
input               data_wr;
//CARAMEL
input              cm_uart_continue;
input              entered_TCB;
input              boot_done;
input              flush_log;       // from log monitor
input              flush_slice;     // from slice monitor
input              ER_done;
input       [15:0] top_slice;       // from slice monitor
input       [15:0] bottom_slice;    // from slice monitor
input              rx_done;         // input from uart-rx -- when RX of a byte is done
input        [7:0] rx_data_out;     // input from uart-rx -- the RX-ed byte
//
input       [15:0] read_idx;        // input from the TX-controller -- index to send next
input              mclk;            // Main system clock
input       [13:0] per_addr;        // Peripheral address
input       [15:0] per_din;         // Peripheral data input
input              per_en;          // Peripheral enable (high active)
input        [1:0] per_we;          // Peripheral write enable (high active)
input              puc_rst;         // Main system reset

//ACFA
input       [15:0] cflow_logs_ptr_din;  // Control Flow: pointer to logs being modified
input       [15:0] cflow_src;
input       [15:0] cflow_dest;
input              cflow_hw_wen;



//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// BASE_ADDR = 0x140
//  - 32*8 = 16*16 = 256 bits of challenge
//  - 16 bits of ER_min
//  - 16 bits of ER_max
//  - 16 bits of current log pointer  
 
parameter       [14:0] METADATA_BASE_ADDR = CHAL_BASE_ADDR+CHAL_SIZE;    // 0x1a0  
parameter       [13:0] METADATA_PER_ADDR = METADATA_BASE_ADDR[14:1];                 
parameter              METADATA_SIZE = 14; 
parameter              METADATA_SIZE_WORDS = 7;
                                                            
// Decoder bit width (defines how many bits are considered)
parameter              DEC_WD      =  5;                 // sizeof(METADATA))-1 
                                                          
// Register addresses offset                             
parameter [DEC_WD-1:0] ERMIN       =  'h0,             //0x1a0
                       ERMAX       =  'h1,             //0x1a2
                       CLOGP       =  'h2,             //0x1a4 
                       TOPSLICE    =  'h3,             //0x1a6 - What I think the address would be
                       BOTTOMSLICE =  'h4,             //0x1a8
                       LOGSTATE    =  'h5,             //0x1aa
                       VRFRESPONSE =  'h6;             //0x1ac
      

// Register one-hot decoder utilities                    
parameter              DEC_SZ      =  (1 << DEC_WD);        
parameter [DEC_SZ-1:0] BASE_REG   =  {{DEC_SZ-1{1'b0}}, 1'b1};
                                                         
// Register one-hot decoder                              
parameter [DEC_SZ-1:0] ERMIN_D  = (BASE_REG << ERMIN),  
                       ERMAX_D  = (BASE_REG << ERMAX),
                       CLOGP_D  = (BASE_REG << CLOGP),
                       TOPSLICE_D  = (BASE_REG << TOPSLICE),
                       BOTTOMSLICE_D  = (BASE_REG << BOTTOMSLICE),
                       LOGSTATE_D  = (BASE_REG << LOGSTATE),
                       VRFRESPONSE_D = (BASE_REG << VRFRESPONSE);
                       
//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel      =  per_en & (per_addr[13:DEC_WD-1]==METADATA_BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr     =  {1'b0, per_addr[DEC_WD-2:0]};

// Register address decode
wire [DEC_SZ-1:0] reg_dec      = (ERMIN_D  &  {DEC_SZ{(reg_addr==ERMIN)}}) |
                                 (ERMAX_D  &  {DEC_SZ{(reg_addr==ERMAX)}}) |
                                 (CLOGP_D  &  {DEC_SZ{(reg_addr==CLOGP)}}) |
                                 (TOPSLICE_D  &  {DEC_SZ{(reg_addr==TOPSLICE)}}) |
                                 (BOTTOMSLICE_D  &  {DEC_SZ{(reg_addr==BOTTOMSLICE)}})|
                                 (LOGSTATE_D  &  {DEC_SZ{(reg_addr==LOGSTATE)}})|
                                 (VRFRESPONSE_D & {DEC_SZ{(reg_addr==VRFRESPONSE)}});
                                 
// Read/Write probes
wire              reg_write =  |per_we & reg_sel;
wire              reg_read  = ~|per_we & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {512{reg_write}};
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {512{reg_read}};

///TODO  Inlude read idx form the registers??


//============================================================================
// 3) REGISTERS
//============================================================================ 

// ER_min Register 
//-----------------
reg  [15:0] ermin;

wire        ermin_wr  = reg_wr[ERMIN];
wire [15:0] ermin_nxt = per_din;
 
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        ermin <=  16'h0;
  else if (ermin_wr)  ermin <=  ermin_nxt; 
  
// ER_max Register
//-----------------
reg  [15:0] ermax;

wire       ermax_wr  = reg_wr[ERMAX];
wire [15:0] ermax_nxt = per_din;

always @ (posedge mclk or posedge puc_rst)
if (puc_rst)        ermax <=  16'h0;
else if (ermax_wr) ermax <=  ermax_nxt;

// Cflow_logs_pointer Register
//----------------------------
reg   [15:0] cflow_logs_ptr; 

always @ (posedge mclk or posedge puc_rst)
if (puc_rst)          cflow_logs_ptr <=  16'h0;
else if(entered_TCB & ~cm_uart_continue)  cflow_logs_ptr <=  cflow_logs_ptr_din; //clfow poiter gets updated as long as we are currently not reading from it?

// Top_slice Register
//----------------------------
reg   [15:0] top_slice_reg; 

always @ (posedge mclk or posedge puc_rst)
if (puc_rst)        top_slice_reg <=  16'haa;
else                top_slice_reg <=  top_slice;
   
// Bottom_slice Register
//----------------------------
reg   [15:0] bottom_slice_reg; 

always @ (posedge mclk or posedge puc_rst)
if (puc_rst)        bottom_slice_reg <=  16'hbb; //have to see what that would be?
else                bottom_slice_reg <=  bottom_slice;
  
// Log_State Register
//----------------------------
reg   [15:0] log_state; 
assign log_state_out = log_state;
always @ (posedge mclk or posedge puc_rst)
    if (puc_rst)
        log_state <= 16'hcc; 
    else if (flush_log && flush_slice) 
        log_state <= 16'h3;
    else if (flush_log)
        log_state <= 16'h2;
    else if (flush_slice | ER_done)
        log_state <= 16'h1;

//if (log_full_alex) log_state[1] = 1;
//if (flush) log_state[0] = 1;

// Verfifier Responded Register
//----------------------------
reg   [15:0] vrf_response;  
wire         vrf_resp_wr  = reg_wr[VRFRESPONSE];
wire  [15:0] vrf_resp_nxt = per_din;
always @ (posedge mclk or posedge puc_rst)
if (puc_rst)                       vrf_response = 16'hdd; //reset
else if (vrf_resp_wr)              vrf_response = vrf_resp_nxt; // this is needed to allow clearing via tcb code
else if (flush_log | flush_slice)  vrf_response = 16'h0; //clear upon new report
else if (vrf_irq)                  vrf_response = 16'h1; //set when vrf response


// Challenge Register
//----------------- 
// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR   = 15'h0180;  
 
parameter              CHAL_SIZE  =  16'h20;            // 32 bytes
parameter              CHAL_SIZE_WORDS = 16'h10;              
parameter              CHAL_ADDR_MSB   = 3;         // Address stored in 16-bit registers, address 32*8 bits using 16-bit registers, need 4 bits -> 3 MSB (start from 0)    
 
parameter       [14:0] CHAL_BASE_ADDR = BASE_ADDR;              // 0x180 
   
parameter       [13:0] CHAL_PER_ADDR  = CHAL_BASE_ADDR[14:1];   

wire   [CHAL_ADDR_MSB:0] chal_addr_reg = per_addr-CHAL_PER_ADDR; 
wire                     chal_cen      = per_en & per_addr >= CHAL_PER_ADDR & per_addr < CHAL_PER_ADDR+(CHAL_SIZE*8/16);
wire    [15:0]           chal_dout;
wire    [1:0]            chal_wen      = per_we & {2{per_en}};

wire [15:0] read_val_chal;
chalmem #(
    .MEM_SIZE (CHAL_SIZE),
    .ADDR_MSB (CHAL_ADDR_MSB))
challenges (  

    // OUTPUTs
    .ram_dout    (chal_dout),           // Program Memory data output
    .read_val    (read_val_chal),

    // INPUTs
    .read_addr   (read_idx- 16'h10), //read addr for hw    ////IT said here MAC_SIZE_WORDS my best guess is MEATADATA nope! see mux well now just pretend it HMAC_SIZE_WORDS
    .read_addr_sw (chal_addr_reg),         // Software read for Challenge without tcb has problems
    .ram_addr    (chal_addr_reg),       // Program Memory address
    .ram_cen     (~chal_cen),           // Program Memory chip enable (low active)
    .ram_clk     (mclk),                // Program Memory clock
    .ram_din     (per_din),             // Program Memory data input
    .ram_wen     (~chal_wen)            // Program Memory write enable (low active)
);
wire [15:0]           chal_rd = chal_dout & {16{chal_cen & ~|per_we}};

// HMAC Register
//----------------- 
// Register base address (must be aligned to decoder bit width)
parameter       [14:0] HMAC_BASE_ADDR   = 15'h01ae; 
 
parameter       [15:0] HMAC_SIZE  =  16'h20;            // 32 bytes              
parameter              HMAC_SIZE_WORDS = 16'h10;      
parameter              HMAC_ADDR_MSB   = 4;         // Address stored in 16-bit registers, address 32*8 bits using 16-bit registers, need 4 bits -> 3 MSB (start from 0)    
   
parameter       [13:0] HMAC_PER_ADDR  = HMAC_BASE_ADDR[14:1];   

wire   [HMAC_ADDR_MSB:0] hmac_addr_reg = per_addr-HMAC_PER_ADDR; 
wire                     hmac_cen      = per_en & per_addr >= HMAC_PER_ADDR & per_addr < HMAC_PER_ADDR+(HMAC_SIZE*8/16);
wire    [15:0]           hmac_dout;
wire    [1:0]            hmac_wen      = per_we & {2{per_en}};

wire [15:0] read_val_hmac;
macmem #(
    .MEM_SIZE (HMAC_SIZE),
    .ADDR_MSB (HMAC_ADDR_MSB))
hmac (  

    // OUTPUTs
    .ram_dout    (hmac_dout),           // Program Memory data output
    .read_val    (read_val_hmac),

    // INPUTs
    .read_addr   (read_idx),            //read addr for hardware // Nope:-(METADATA_SIZE_WORDS+CHAL_SIZE_WORDS)--> see mux
    .read_addr_sw(hmac_addr_reg),       //Software read for HMAC without tcb has problems
    .ram_addr    (hmac_addr_reg),       // Program Memory address
    .ram_cen     (~hmac_cen),           // Program Memory chip enable (low active)
    .ram_clk     (mclk),                // Program Memory clock
    .ram_din     (per_din),             // Program Memory data input
    .ram_wen     (~hmac_wen)            // Program Memory write enable (low active)
);
wire [15:0]           hmac_rd = hmac_dout & {16{hmac_cen & ~|per_we}};

//// Control-Flow Logs Registers
////------------------------------  
//parameter               CFLOW_LOGS_ADDR_MSB   =   9;
//parameter               CFLOW_LOGS_SIZE   =  16'h0200; // total words for 1024 bytes cflog 
////parameter               CFLOW_LOGS_SIZE   =  16'h0400;   // total words for 2048 bytes cflog
////parameter               CFLOW_LOGS_SIZE   =  16'h0800;   // total words for 4096 bytes cflog  (4kb)
////parameter               CFLOW_LOGS_SIZE   =  16'h1000;   // total words for 8192 bytes cflog  (8kb)
////parameter               CFLOW_LOGS_SIZE   =  16'h1800;   // total words for 12288 bytes cflog  (12kb)
////                                                          
//parameter       [14:0] CFLOW_LOGS_BASE_ADDR = 14'h0222;
//parameter       [13:0] CFLOW_LOGS_PER_ADDR  = CFLOW_LOGS_BASE_ADDR[14:1];


//wire  [CFLOW_LOGS_ADDR_MSB:0]       cflow_addr_reg  =  {1'b0, 1'b0, per_addr-CFLOW_LOGS_PER_ADDR};
//wire                                cflow_cen       = per_en & per_addr >= CFLOW_LOGS_PER_ADDR 
//                                                        & per_addr < CFLOW_LOGS_PER_ADDR+CFLOW_LOGS_SIZE;
//                                                        // plus full size since each entry is 4 bytes, not 2
//wire    [15:0]                      cflow_dout;


//wire [15:0] read_val_cflog; 
//cflogmem cflog (
//    // OUTPUTs
//    .ram_dout    (cflow_dout),           // Program Memory data output
//    .read_val    (read_val_cflog),
//    // INPUTs
//    .read_addr     (read_idx-CHAL_SIZE_WORDS-METADATA_SIZE_WORDS-HMAC_SIZE_WORDS),       // Program Memory address
//    .read_addr_sw  (cflow_addr_reg),
//    .write_addr    (cflow_logs_ptr_din-16'h2),       // Program Memory address
//    .ram_cen     (~cflow_cen),           // Program Memory chip enable (low active)
//    .ram_clk     (mclk),                // Program Memory clock
//    .ram_din1     (cflow_src),             // Program Memory data input
//    .ram_din2     (cflow_dest),             // Program Memory data input
//    .ram_wen     (cflow_hw_wen)            // Program Memory write enable (low active)
//    //    
//);
     
//wire [15:0]           cflow_rd       = cflow_dout & {16{cflow_cen & ~|per_we}};


// Verifier Response 
//----------------- 
// Register base address (must be aligned to decoder bit width)
parameter       [14:0] VRF_BASE_ADDR  = 16'h01d0;
 
parameter            [15:0] VRF_SIZE  = 66;        
parameter               VRF_ADDR_MSB  = 7;         
   
parameter        [13:0] VRF_PER_ADDR  = VRF_BASE_ADDR[14:1];   

wire   [VRF_ADDR_MSB:0] vrf_addr_reg = per_addr-VRF_PER_ADDR; 
wire                     vrf_cen      = per_en & per_addr >= VRF_PER_ADDR & per_addr < VRF_PER_ADDR+(VRF_SIZE*8/16);
wire    [15:0]           vrf_dout;
wire    [1:0]            vrf_wen      = per_we & {2{per_en}};

vrfmem vrf_resp_mem (  
    // OUTPUTs
    .ram_dout    (vrf_dout),          // Program Memory data output
    .write_out   (vrfmem_write_out),

    // INPUTs
    .ram_cen     (vrf_cen),
    .ram_addr    (vrf_addr_reg),      // read address
    .ram_clk     (mclk),              // Program Memory clock
    .ram_din     (rx_data_out),       // uart rx data out is the write data
    .ram_wen     (rx_done)            // uart rx done is write enable
);
wire [15:0]           vrf_rd = vrf_dout & {16{vrf_cen & ~|per_we}};

// generate irq the entire message was filled (besides boot case since we are already in the tcb)
wire vrf_irq = boot_done && (vrfmem_write_out >= (VRF_SIZE/2));

//// initialize stuff
initial begin
    ermin <= 16'haa11; 
    ermax <= 16'habcd;
    cflow_logs_ptr <= 16'h0000;
//    logsize <= 16'h0000; 
end
 
//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] ermin_rd            = ermin & {16{reg_rd[ERMIN]}};
wire [15:0] ermax_rd            = ermax & {16{reg_rd[ERMAX]}};
wire [15:0] cflow_logs_ptr_rd   = cflow_logs_ptr & {16{reg_rd[CLOGP]}};
wire [15:0] top_slice_rd        = top_slice_reg & {16{reg_rd[TOPSLICE]}};
wire [15:0] bottom_slice_rd     = bottom_slice_reg & {16{reg_rd[BOTTOMSLICE]}};
wire [15:0] log_state_rd        = log_state & {16{reg_rd[LOGSTATE]}};
wire [15:0] vrf_response_rd     = vrf_response & {16{reg_rd[VRFRESPONSE]}};

wire [15:0] per_dout  =  ermin_rd  |
                         ermax_rd  |
                         cflow_logs_ptr_rd |
                         chal_rd |
                        // cflow_rd |
                         hmac_rd |
                         vrf_rd |
                         top_slice_rd|
                         bottom_slice_rd|
                         log_state_rd|
                         vrf_response_rd;
                         
wire [15:0] ER_min = ermin;
wire [15:0] ER_max = ermax;


//============================================================================
// CARAMEL HW TRANSMIT OUTPUTS
//============================================================================

// kid: mom, can you buy me openMSP430's peripheral data output mux?
// mom: we have a peripheral data output mux at home!
wire hw_read_hmac = (read_idx >= 16'h0) && (read_idx < HMAC_SIZE_WORDS);
wire hw_read_chal = (read_idx >= HMAC_SIZE_WORDS) && (read_idx < CHAL_SIZE_WORDS+HMAC_SIZE_WORDS);
wire hw_read_metadata = (read_idx >= CHAL_SIZE_WORDS + HMAC_SIZE_WORDS) && (read_idx < CHAL_SIZE_WORDS + METADATA_SIZE_WORDS + HMAC_SIZE_WORDS);
//wire hw_read_cflog = (read_idx >= CHAL_SIZE_WORDS + METADATA_SIZE_WORDS + HMAC_SIZE_WORDS);
// read_idx is indexing 16-bit words

///// need another for metadata since these regs that aren't connected nicely
wire [2:0] read_idx_metadata = read_idx -  ( CHAL_SIZE_WORDS+HMAC_SIZE_WORDS);
wire [15:0] read_val_metadata = (read_idx_metadata == 3'h0) ? ermin :
                                (read_idx_metadata == 3'h1) ? ermax :
                                (read_idx_metadata == 3'h2) ? cflow_logs_ptr :
                                (read_idx_metadata == 3'h3) ? top_slice_reg :
                                (read_idx_metadata == 3'h4) ? bottom_slice_reg :
                                (read_idx_metadata == 3'h5) ? log_state :
                                (read_idx_metadata == 3'h6) ? vrf_response :
                                16'h0;

//// based on the selector, switch between reading bytes from chal or cflog
assign read_val = hw_read_hmac ? read_val_hmac :
                  hw_read_chal ? read_val_chal :
                  hw_read_metadata ? read_val_metadata :
               //   hw_read_cflog ? read_val_cflog :
                  16'h0;

/// map the irq wire to the output port
// also for some reason we need ``debouncing'' for this irq
// so here's the pnd logic
reg vrf_irq_pnd = 1'b0;
reg delay = 1'b0;
always @(posedge mclk)
begin
    if(vrf_irq)
    begin
        vrf_irq_pnd <= 1'b1;
        delay <= 1'b0;
    end
    else if (vrf_irq_pnd & ~vrf_irq & ~delay) // need two cycle delay lol
    begin
        vrf_resp_irq <= 1'b1;
        vrf_irq_pnd <= 1'b0;
    end
    else if (vrf_resp_irq & ~delay)
        delay <= 1'b1;
    else
    begin
        vrf_resp_irq <= 1'b0;
        delay <= 1'b1;
    end
end

// assign vrf_resp_irq = vrf_irq;

// also we need the state var (set when vrf resp authed and accepted). 
assign vrf_response_out = vrf_response;
///

endmodule 