// 
// *File Name: logmem.v
// 
// *Module Description:
//                      Scalable cflog 
//
// *Author(s):
//              - Alexandra Lengert, Adam Caulfield
//
//----------------------------------------------------------------------------


`include "openMSP430_defines.v"
module logmem (

// OUTPUTs
    ram_dout,                      // RAM data output
    read_val_log,                      // Data memory data output for hardware is connected to controller (uut)

// INPUTs
    ram_addr,                      // RAM address for software currently
    read_addr_hw,                      // Data Memory address for the hw side  --> comes from the controller (uut)
    ram_cen,                       // RAM chip enable (low active)
    ram_clk,                       // RAM clock
//    ram_din,                       // RAM data input
   // ram_wen,                        // RAM write enable (low active) (for software no longer needed)
    
// relvenat for writing cflog
    cflow_logs_ptr_din, // Control Flow: pointer to logs being modified
    cflow_src,     // Control Flow: jump from
    cflow_dest,    // Control Flow: jump to
    cflow_hw_wen  // Control Flow, write enable (only hardware can trigger)    
    
);

// PARAMETERs
//============
parameter ADDR_MSB   =  6;         // MSB of the address bus
parameter MEM_SIZE   =  256;       // Memory size in bytes

// OUTPUTs
//============
output      [15:0] ram_dout;       // RAM data output SW
output      [15:0] read_val_log;       // RAM data output HW

// INPUTs
//============
input [ADDR_MSB:0] ram_addr;       // RAM address SW
input [ADDR_MSB:0] read_addr_hw;       // RAM address HW
input              ram_cen;        // RAM chip enable (low active)
input              ram_clk;        // RAM clock
//input       [15:0] ram_din;        // RAM data input
//input        [1:0] ram_wen;        // RAM write enable (low active)


/// INPUTS FOR WRITING CLFOG 
input       [15:0] cflow_logs_ptr_din;  // Control Flow: pointer to logs being modified
input       [15:0] cflow_src;
input       [15:0] cflow_dest;
input              cflow_hw_wen;

// RAM
//============

 

reg   [ADDR_MSB:0] ram_addr_reg;
//reg   [ADDR_MSB:0] ram_addr_reg_hw;
`ifdef ACFA_HW_ONLY
// To get LUT/FF
reg         [15:0] cflog [0:1]; 
`else 
// To emulate memory 
    reg         [15:0] cflog [0:(MEM_SIZE/2)-1];//block ram for the cflog 
`endif

wire        [15:0] mem_val = cflog[ram_addr];
//wire        [15:0] test_val_log = cflog[read_addr_hw]; ///probably
wire [ADDR_MSB:0] write_addr = cflow_logs_ptr_din-16'h2; //write addr is dependent on the cflog_ptr we deduct 2 as the log_ptr points to the next empty log entry

//this is for reading   
always @(posedge ram_clk)
begin
  if (~ram_cen & ram_addr<(MEM_SIZE/2))  //if chip is enabled (so there is a valid reading to this part of the memory and the address in the right space (bit of a hoot and a hat here but any way)) --> MEMSIZe is in byte as memory holds words we devide by two 
    ram_addr_reg <= ram_addr; ///with this we change the current reading addr and therefore the data output (dout)
  
end

assign ram_dout = cflog[ram_addr_reg];

//this is for hardware writing - software writing is blocked for security reasons
always @(posedge ram_clk)
begin
    if (cflow_hw_wen & write_addr < MEM_SIZE/2)
        begin
            cflog[write_addr]             <= cflow_src; // we jump one address as with each write there is are two addresses source and destination
            cflog[write_addr+1'b1]        <= cflow_dest;
         end
//     ram_addr_reg_hw <= read_addr_hw;  // works but shouldn't be needed
      
end

// this is the assignement of data out put based on the read_addr given by controller(uut), this will give the data we will be sending from the specialised uart. 
assign read_val_log = cflog[read_addr_hw];

endmodule // logmem
