`include "openMSP430_defines.v"
module  controller (
    mclk,
    pc,
    cflow_log_ptr,
    read_val,
    boot,
    flush_log,
    flush_slice,
    ER_done,
    vrf_response_out,
    top_slice,
    bottom_slice,

    //
    start_log,
    trigger,
    read_idx,
    continue,
    byte_val,

    t1,
    t2,
    t3,

    log_ptr_catch_out,
    
    log_idx, //where in logmem are we reading
    read_val_log      // Data memory data output for hardware is connected to controller (uut)
);

input mclk;
input [15:0] pc;
input [15:0] cflow_log_ptr;
input [15:0] read_val;
input boot;
input flush_log;
input flush_slice;
input ER_done;
input [15:0] vrf_response_out;
input [15:0] top_slice;
input [15:0] bottom_slice;

output reg trigger;
output [15:0] read_idx;
output continue;
output [7:0] byte_val;


//// debug
output reg t1;
output reg t2;
output reg t3;

output reg [15:0] log_ptr_catch_out;

//logmem

input  [15:0]       read_val_log;
output [`LOG_MSB:0] log_idx;

///
reg counter;
reg repo_wait;
reg [15:0] log_ptr_catch;
output reg start_log;//ready to send log should be connetcted to flush signal or similar TODO think best possible signal
reg [15:0] trigger_count;

//reg [15:0] send_bytes;

 //initilaising new stuff
reg [15:0] read_idx_reg; // old one as the counting is the same we wont change that (it will just get updated in between)
reg start; 
reg log_finish; //finished sending the log so we can start sending anythhing else 


initial
begin
    // 
    t1 <= 1'b0;
    t2 <= 1'b0;
    t3 <= 1'b0;
    log_ptr_catch <= 16'h0;
    start <= 1'b0;
    counter <= 0;
    trigger_count <= 16'h0;
    trigger <= 1'b0;
    log_ptr_catch_out <= 16'h0;
    repo_wait<= 1'b0;
    start_log<= 1'b0;
    log_finish<= 1'b0;
    read_idx_reg <=1'b0;
end
///

parameter CHAL_SIZE_WORDS  =  16'h10; 
parameter MAC_WORDS  =  16'h10; 
parameter METADATA_SIZE_WORDS  =  16'h7; 

parameter LOG_SIZE = `LOG_SIZE/2; // now updated to be dependent on defines :)
// parameter LOG_SIZE = 16'h0080; // 256
// parameter LOG_SIZE = 16'h0100; // 512
//parameter LOG_SIZE = 16'h0200; // 1024
// parameter LOG_SIZE = 16'h0400; // 2048
//parameter LOG_SIZE = 16'h0800;   // total words for 4096 bytes cflog  (4kb)
//parameter LOG_SIZE = 16'h1000;   // total words for 8192 bytes cflog  (8kb)
//parameter LOG_SIZE = 16'h1800;   // total words for 12288 bytes cflog  (12kb)8


// Number of ticks between byte transmisions
// CLK_freq / BAUD 
// 20*10^6 / 112500
// ~180
parameter TX_RATE = 180; // real

parameter CONSTANTS = CHAL_SIZE_WORDS+MAC_WORDS+METADATA_SIZE_WORDS;

//always @(posedge (mclk))
//begin
//    if (bottom_slice>top_slice)
//        send_bytes = bottom_slice-top_slice;
//    else 
//        send_bytes = LOG_SIZE - top_slice + bottom_slice;
//end 
reg [15:0] bottom_catch = 0;
reg [15:0] top_catch = 0;
//wire [15:0] send_bytes = (bottom_slice > top_slice) ?  bottom_slice-top_slice : LOG_SIZE - top_slice + bottom_slice;//don't need that any more?
//wire [15:0] total_send =  send_bytes + CHAL_SIZE_WORDS + METADATA_SIZE_WORDS + MAC_WORDS; // or that for the matter ( i am not deleting bc I am unsure what theoriginal intention was...


//These signals track what report we are currently sending. T2 and t3 can occure simultanously this way one isnt't accidentially lost :)
parameter NONE     =  2'b00; 
parameter T2_GEN   =  2'b01;  
parameter T3_GEN   =  2'b10; 
reg [1:0] tx_src = NONE; // 00 - t1, 01 -- t2, 10 -- t3
// triggers to start transmitting 
// TODO need to rethink
// originally turned of triggers when reaching the end of the transmitted log now its the end of METADATA
always @(posedge (mclk))
begin
    if (ER_done)
        t3 <= 1'b1;  
    else if (t3 & (start == 1'b1) && (read_idx > CONSTANTS) && (tx_src == T3_GEN)) //
        t3 <= 1'b0; 
    if(flush_slice)
        t2 <= 1'b1;
    else if (t2 & start && (read_idx > CONSTANTS) && (tx_src == T2_GEN))
        t2 <= 1'b0;  
    // t3 <= start;
end 

// used to detect when vrf has approved the previous report, and the current one can be sent.
reg vrf_acc = 1'b1;



// reg first_exit_done = 1'b0;
wire is_accepted_addr = (pc == 16'hdffc);
wire is_sendoff_addr = (pc == 16'hdffa);
// wire prev_pc_accepted_addr = (prev_pc == 16'hdffc);
// wire prev_pc_sendoff_addr = (prev_pc == 16'hdffa);
reg first_tx = 1'b1;
reg report_ready = 1'b0;
wire one_cflog = (~t2 & t3 & first_tx); /// if the whole exec fits into one cflog, 
always @(posedge mclk)
begin
    if (is_sendoff_addr && (~repo_wait | one_cflog) & ~start)
    begin
        vrf_acc <= ~first_tx;
        report_ready <= 1'b1;
        repo_wait<=1'b1;
    end
    else if (is_accepted_addr | (is_sendoff_addr & first_tx))
    begin
        vrf_acc <= 1'b1;
        first_tx <= 1'b0;
    end
    else if (~report_ready)
        repo_wait<= 1'b0;
end

/// flag to start transmitting (for now we use only t3)
wire tx_pending = (t2 | t3);
wire pc_not_in_tcb = (pc < 16'ha000) | (pc > 16'hdffe);
wire pc_in_tcb = ~pc_not_in_tcb;

always @(posedge (mclk))
begin//so this starts when we are ready to send a report and finished sending the cflog 
    if (tx_pending && report_ready && ~start  && log_finish)//pc_not_in_tcb && TODO debug the thing with counted as ready when it leaves tcb attest?
    begin
        report_ready <= 1'b0;
        //log_ptr_catch <= total_send;
        // log_ptr_catch_out <= cflow_log_ptr;
        start <= 1'b1;  
        read_idx_reg <= 1'b0;
        if (t2)
            tx_src <= T2_GEN;
        else if (t3)
            tx_src <= T3_GEN;
        else
            tx_src <= NONE;
    end
    else if ((start == 1'b1) &&  (read_idx > CONSTANTS) && ~ sending_byte) // finished sending everything after starting to send METADATA and reached the its end  //FORMER:(read_idx >= log_ptr_catch))
     begin
        start <= 1'b0;
        log_finish  <= 1'b0;
        end
        // log_ptr_catch <= 16'h0;
    else if (start == 1'b0)
    begin ///should you be looking at the waves and wonder why bottom doesn't update? that is totally fine. its the top that changes first its a slice (top above bottom) then its the whole log (top below bottom)
        top_catch <= top_slice;
        if (bottom_slice == LOG_SIZE)
            bottom_catch <= LOG_SIZE-1'b1;
        else
            bottom_catch <= bottom_slice+1'b1;
    end
end

//////////// SEND DATA  /////////////// pobably can be merged with the other one but optimizing comes later  --> Or I got fed up with it interfereing with each other and just did it 

//theory: We start sending the cflog with the flush signal as it signals we are preparing a report for vrf.(TODO: ensure it always occurs together with sending! Yes I mean ER_done exception problem)
//systematic of sending should be the same as for Meta data just in a different memory region. so our read addr is based top and bottom slice (top to bottom or top to end and then start to bottom)
// we will need to take out the log pointer in the other sending block (bc  readidx has now a fixed max value)
//changes I would make for sending cflog using log idx instead of readIdx (could potentially be the same here not done yet bc the difference between the addr widths would need an additional address mux or widths adjustment) --> not made up my mind about that...
// add out put mux depending on what is send we choose the reading values from acfamem or logmem

reg sending = 1'b0;// ensures we are not sending while waiting for the next vrf response (so we can only send after receiving a response)
// is needed as the vrf_response_out leaves to fast and does not coincite with a flush signal so while not the pretties and there are probablty otherways like solving it at the source pof vrf_resp signal this works
 always @(posedge (mclk))
 begin
    if (vrf_response_out != 0) 
            sending = 1'b1;
    else if (vrf_response_out == 0 && log_finish)//dont need it any more after we started sending_we probably could cut it earlier
        sending = 1'b0;
 end
 
// originally the last addr so log_idx == bottom is gone to fast so it doesnt finish sending the content of that addr. I tried using counter alone but that did not work either. 
//So this ensures that we stop sending cflog after finishing sending the last byte, so we are sending the full conent of the addr and we finish sending it (sending word might have been more appropriate...)
reg sending_byte =0;
 

 always @(posedge (mclk))
 begin
    if (tx_pending && ~start_log && ~log_finish && sending ) //TODO: better signal for ready to send anything I stole Adams for now additionally for a slice sending can finish before hmac is ready so to stop retransmitting the log we can not have a finished send log
    begin 
        start_log <= 1'b1;// start sending 
        log_finish  <= 1'b0;
        read_idx_reg <= top_slice; //inititalize read_idx_reg with the top_slice as no matter what cflog we are sending this should be the start
        end
    else if (start_log && log_idx == bottom_catch && ~sending_byte && log_idx !=0) // we finish with the log if we first started (XD) and then reached the bottom (so finished sending the bottom) thins works 
    begin
       start_log <= 1'b0; 
        log_finish  <= 1'b1; //set log finished
         read_idx_reg <= 1'b0; //after we finish the log, reset the read_idx_reg for reading the metadata
        end 
 end
 


// output mux for what word is being send (gets fed into the byte val for uart) 
// if the we are currently in the cflog sending phase so we started sending cflog but are not finished the out put value (current value) is the value read from logmem otherwis eits the value from acfa_memory
wire [15:0] current_val;
//if in the process of sending log its the value form logmem otherwise its metadata
assign current_val = (start_log && ~log_finish)  ? read_val_log : read_val ; 

//what is the current log idx (read_addr) for logmem
//assign log_idx = (start_log && ~start && read_idx_reg < bottom_slice)  ? read_idx_reg: 0;
//logic: cflog always starts from the top independent of where bottom is (so log_idx is outomatically read_idx_reg+topslice) if it becomes larger than LOGSIZE we adjust it by substarcting the LOGSIZE so it would start counting from LOG beginning
assign log_idx = read_idx_reg <= LOG_SIZE? read_idx_reg: read_idx_reg - LOG_SIZE;

// i though about adjusting it only when not sending log but that is kinda unnecessary?
//assign read_idx = (start && log_finish) ? read_idx_reg : 0; // SO:
assign read_idx =  read_idx_reg;

///signal for the actual uart doing the sending now ends when METADATA finished sending (becomes controller_en)
assign continue = (start_log  | log_finish);//((log_ptr_catch != 0) && (read_idx < CONSTANTS) ) | ; // TODO: purpose of log_ptr catch and if we need it   IS IT SUPPOSED TO BE A LOGIC (BOOLEAN) SIGNAL?


/// iterates through cflog entries byte by byte in each entry
// trigger_count is delay between bytes
always @(posedge (mclk))
begin
    if (start_log == 1'b1 | start == 1'b1) //report is ready start_log= sening cflog and start clfog is finished and hmac is calculated 
        begin
            if(trigger == 1'b1) // ready to sen the next byte?
            begin
                if(counter == 1'b1) // what part of the cflog entry are we sending. Memory is made up of words but uart sends bytes. so we send lower bits first then the upper bits 
                begin
                    sending_byte <= 1'b1;
                    read_idx_reg <= read_idx_reg + 16'h1;//after sending upper bytes is the next entry read
                    counter <= 1'b0;
                end
                else if(counter == 1'b0)
                    counter <= 1'b1;
                trigger <= 1'b0;
            end
    
            if (trigger_count != TX_RATE) ///essantially a wait until byte is send
                trigger_count <= trigger_count + 1; 
            else
            begin
                trigger_count <= 16'h0;///prepare sending next byte  set timmer (trigger count to zero) and trigger sending next byte
                trigger <= 1'b1;
                if(counter == 1'b1)
                    sending_byte <= 1'b0;
            end
        end
    else
    begin
      //  read_idx_reg <= 16'h0; // 
        counter <= 0;
        trigger_count <= 16'h0;
        trigger <= 1'b0;
    end
end 

///// ouptut wires
assign byte_val = counter ? current_val[15:8] : current_val[7:0];  //byte that is currently being send

////OLD
//assign continue = (log_ptr_catch != 0) & (read_idx <= log_ptr_catch); ///signal for the actual uart doing the sending TODO Update
//assign read_idx = (read_idx_reg < CONSTANTS) ? read_idx_reg : (read_idx_reg + top_catch);  /// that needs changing ///update
// assign log_ptr_catch_out = log_ptr_catch;

endmodule