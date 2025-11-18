module  slice_monitor(
    clk,
    //
    pc,
    pc_nxt,
    //
    ER_min,
    ER_max,
    //
    ER_done,
    irq,
    reset,
//	vrf_responded,
	cflow_log_ptr,
	// cflow_log_ptr_nxt, // not used
	
//	loop_detect,
//	branch_detect,

    flush, 
//    hw_wr_en,
	top_slice,
	bottom_slice


);

input		clk;//clock
input   [15:0]  pc;//counter
input   [15:0]  pc_nxt;//counter in next step?
//
input   [15:0]  ER_min;//start and end of CFlog
input   [15:0]  ER_max;

//
input       ER_done;
input       irq; //interrup
input		reset;//reset
input  [15:0]  cflow_log_ptr;//Pointer for: Where in the Cflog are we?
// input   [15:0] cflow_log_ptr_nxt;
//outputs

//output          hw_wr_en;//Ithought hw couldn't be written to?
//output  [15:0]  cflow_log_ptr;//Pointer for: Where in the Cflog are we?
output 			flush;	//flush trigger for cflog blocks //clear log?
output	[15:0]  top_slice;
output	[15:0]  bottom_slice;

// Logging States //////////////////////////////////////////////////////////


//parameter TCB_min = 16'ha000;
parameter TCB_max = 16'hdffe;

// Trigger States
parameter VrfHold  = 1'b0;
parameter EXEC = 1'b1;
//parameter Wait = 2'b01;

parameter LOG_SIZE = 16'h0000; // overwritten by parent module
parameter NUM_BLOCKS = 2;
parameter MAX_CFLOG_SIZE = LOG_SIZE-2; // set as minus 2 to log tcb entry, set as equal to ignore tcb entry
parameter BLOCK_SIZE = LOG_SIZE/NUM_BLOCKS;

//-------------Internal Variables---------------------------
reg             state;
reg             flush_slice;
reg             attest_pend;
reg             res = 1'b1;



//reg             log_full;
reg     [15:0]  bottom_of_slice_reg;
reg     [15:0]  top_of_slice_reg;
reg		[15:0]	track_last_send_reg; //block that was or is verified
reg     [2:0]	where_is_log_ptr;

//

initial
begin
    state = EXEC;
    flush_slice = 1'b0;
    attest_pend = 1'b0;
	track_last_send_reg = 1'b0;//intializing with all 0000
	where_is_log_ptr = 1'b0;
	bottom_of_slice_reg = 16'b0+BLOCK_SIZE;//-2'b10;
	top_of_slice_reg = 16'b0;
end


/////Internal logic

wire cflog_ptr_next = (cflow_log_ptr + 16'h2) % (LOG_SIZE+1);
wire slice_full = (cflow_log_ptr >= bottom_of_slice_reg && cflow_log_ptr <= (bottom_of_slice_reg+2'b10)) && ~finished || ((cflow_log_ptr == MAX_CFLOG_SIZE) && top_slice==16'b0);// update current version doesn't work if cfptr is at end and 
wire vrf_responded = pc==16'hdffc; //temporary -- maybe not anymore?16'hdffa;//


//final state slice
always @(posedge clk)  // do I need resets here?
if(( state == EXEC && slice_full) || ( pc == ER_max && pc != 1'b0))// && pc==16'hdff6)
    state <= VrfHold;
else if (state == VrfHold && vrf_responded)//||(state == Wait && vrf_responded))
    state <= EXEC;
//else if ((state == VrfHold && log_full) ||(state == EXEC && log_full))
//    state <= Wait;
else state <= state;

reg finished = 1'b0;
always @(posedge clk)//or here?
begin
    if(ER_done)
        finished <= 1'b1;  
    else
        finished <= finished;  
end


// output logic
always @(posedge clk)//or here?
if (state == EXEC && slice_full)// || (log_full_lsm && vrf_responded))No! TCB schould have already send!!
    begin
    flush_slice <= 1'b1;
	where_is_log_ptr = (where_is_log_ptr+1) % NUM_BLOCKS; //update when leaving tcb through dff6
	track_last_send_reg = bottom_of_slice_reg;
	bottom_of_slice_reg = BLOCK_SIZE*(where_is_log_ptr+1);
	res<=1'b1;
    end
//else if ((state == VrfHold || state==EXEC) && log_full_lsm )
//	log_full<=1'b1; 
else if (state == VrfHold && slice_full && ( cflog_ptr_next!= top_slice))
    begin
    flush_slice <= 1'b0;
	where_is_log_ptr = (where_is_log_ptr+1)% NUM_BLOCKS; 
	bottom_of_slice_reg = BLOCK_SIZE*(where_is_log_ptr+1);
	end
else if (attest_pend) //Pend --> Acc
    flush_slice <= 0;
//	log_full <= 0;
else if ((vrf_responded && ER_min != 0) && res)
    begin
    top_of_slice_reg = (track_last_send_reg+16'b10) % (LOG_SIZE+2'b10);
    res <=1'b0;
    end
else if (finished && res)
begin
    top_of_slice_reg = (track_last_send_reg+16'b10) % (LOG_SIZE+2'b10);
    res <=1'b0;
    track_last_send_reg = cflow_log_ptr;
end
//else if (state == Wait)
//    log_full<=1'b0;
    
    
always @(posedge clk)
if(flush_slice && irq)//||(log_full_lsm && irq)) // Abort --> Pend
    attest_pend <= 1;
else
    attest_pend <= 0; 
    



//outputs
assign flush = flush_slice; // rename 
assign top_slice = top_of_slice_reg;
assign bottom_slice = track_last_send_reg;
//assign log_full_alex = log_full;

endmodule

