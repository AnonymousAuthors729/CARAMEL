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
// *File Name: ram.v
// 
// *Module Description:
//                      Scalable RAM model
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
//----------------------------------------------------------------------------

module vrfmem (

// OUTPUTs
    ram_dout,                      // RAM data output
    write_out, //debugging

// INPUTs
    ram_cen,
    ram_addr,                      // RAM address // specified via software
    ram_clk,                       // RAM clock
    ram_din, //rx_data_out from the UART
    ram_wen, // rx_done from the UART
    //
);

// PARAMETERs
//============
// mem size in bytes
parameter MEM_SIZE   = 66;       // only need 65 but make it an even number 
parameter ADDR_MSB   = 5;

// OUTPUTs
//============
output      [15:0] ram_dout;       // RAM data output (read outut)
output      [15:0] write_out;      // for debugging
// INPUTs
//============
input                    ram_cen;
input       [ADDR_MSB:0] ram_addr;       // RAM address
input                    ram_clk;        // RAM clock
input              [7:0] ram_din;        //rx_data_out from the UART
input              [1:0] ram_wen;        // rx_done from the UART

// RAM 
//============
 
`ifdef ACFA_HW_ONLY
// To get LUT/FF
(* ram_style = "block" *) reg         [15:0] mem [0:1]; 
`else 
// To emulate memory 
(* ram_style = "block" *) reg         [15:0] mem [0:(MEM_SIZE/2)-1]; 
`endif

reg         [15:0] ram_addr_reg;

wire        [15:0] mem_val = mem[ram_addr];  

reg [15:0] write_addr;
reg rx_bit;
reg [15:0] i;
initial  
    begin
        // debug
        // mem[0] = 16'he000;
        // mem[1] = 16'he17a;

        for(i=0; i<MEM_SIZE; i=i+1)
        begin
            mem[i] <= 16'hffff;
            // mem[i] <= ({8{i}} << 8) | {8{i+1}};
        end
        ram_addr_reg <= 0;
        write_addr <= 16'h0;
    end
  
// hw write logic

always @(posedge ram_clk) begin
    if (ram_cen == 1)
        ram_addr_reg <= ram_addr;

    if (ram_wen && (rx_bit == 1'b0))
    begin
        rx_bit <= 1'b1;
        mem[write_addr][15:8]  <= ram_din;
    end
    else if (ram_wen && (rx_bit == 1'b1))
    begin
        rx_bit <= 1'b0;
        mem[write_addr][7:0]   <= ram_din;

        write_addr <= write_addr + 16'h1; // mod mem_size/2
    end

    if (write_addr >= (MEM_SIZE/2))
        write_addr <= 16'h0;
end

// set read_out value
assign ram_dout = mem[ram_addr_reg];
assign write_out = write_addr;//mem[0];

endmodule // vrfmem