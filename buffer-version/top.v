`include"sys_defs.vh"
module top
(
    input wire clock,
    input wire reset
);
wire [9:0] CC_addr,CS_addr,SM_addr,BM_addr,MC_raddr,abcd,buffer_addr_in,buffer_addr_out;
wire [31:0] CC_wData,CC_rData,CS_wData,SM_wData,BM_wData,CM_rData,SM_rData,buffer_data_in,buffer_data_out,data_read_from_buffer;
wire [`BANDWIDTH_WRITE_DATA-1:0] bus_BM,bus_CM_rd,bus_MC;
wire write_buffer,CC_read,CC_write,hit,read_buffer,SM_write,SM_read,CM_write,BM_write,BM_read,done_w,done_r,send_addr,send_buffer,SC_done_sender_rd,write_receiver,read_receiver,send_bus,write_rec,send_bus_BM,send_wr_addr;
wire done_sender_MC,send_MC,write_MC,write_rec_MC,send_bus_MC,done_buffer,addr_done,buffer_hit,write_buffer_out,write_rec_buffer;

cpu  u_cpu 
(
    .clock                   ( clock        ),
    .reset                   ( reset ),
    .rData                   ( CC_rData        ),
    .hit                     ( hit          ),

    .Address                 ( CC_addr      ),
    .Write_Data              ( CC_wData   ),
    .read                    ( CC_read         ),
    .write                   ( CC_write        )
);

cache  u_cache 
(
    .clock                   (clock),
    .reset                   (reset       ),
    .cpuRead                 ( CC_read    ),
    .cpuWrite                ( CC_write   ),
    .cpuAddr                 ( CC_addr    ),
    .cpuData                 ( CC_wData    ),
    .memData                 ( SM_rData    ),
    .done_sender             (SC_done_sender_rd),
    .write_receiver          (write_receiver),
    
    
    .full(full),
    .buffer_hit(buffer_hit),
    .data_read_from_buffer(data_read_from_buffer),
    
    .hit                     ( hit        ),
    .read_buffer                    ( read_buffer       ),
    .write_addrsender                   ( CM_write      ),
    .write_buffer            (write_buffer),
    
    .send_addr                    (send_addr),
    
    .rData                   ( CC_rData),
    .addr                    (buffer_addr_in),
    .addr_rd                 (CS_addr),
    .wData                   (buffer_data_in),
    .addr_sendData           (CS_wData)
);

//read bus from cache to memory
sender sdCM(.clk(clock),.send(send_addr),.reset(reset),.data_in(CS_wData),.addr_in(CS_addr),.write(CM_write),.bus(bus_CM_rd),.send_bus(send_bus),.write_to_rec(write_rec),.done(SC_done_sender_rd));
receiver recCM(.clk(clock),.send(send_bus),.reset(reset),.write_in(write_rec),.bus(bus_CM_rd),.data_out(SM_wData),.addr_out(SM_addr),.write(SM_write),.read(SM_read));



buffer bbff(.clk(clock),.reset(reset),.write_back_address(buffer_addr_in),.write_back_data(buffer_data_in),.write(write_buffer),.done(done_buffer),.addr_done(addr_done), .read(read_buffer),
.full(full),.buffer_hit(buffer_hit),.write_data(buffer_data_out), .write_address(buffer_addr_out),.data_read_to_cache(data_read_from_buffer),.send_wr_data(send_buffer),.send_wr_addr(send_wr_addr),.write_out(write_buffer_out));


//write bus from buffer to memory
sender sdBM(.clk(clock),.send(send_buffer),.reset(reset),.data_in(buffer_data_out),.addr_in(buffer_addr_out),.write(write_buffer_out),.bus(bus_BM),.send_bus(send_bus_BM),.write_to_rec(write_rec_buffer),.done(done_buffer));
receiver recBM(.clk(clock),.send(send_bus_BM),.reset(reset),.write_in(write_rec_buffer),.bus(bus_BM),.data_out(BM_wData),.addr_out(BM_addr),.write(BM_write),.read(BM_read));

sender sdMC(.clk(clock),.send(send_MC),.reset(reset),.data_in(CM_rData),.addr_in(MC_raddr),.write(write_MC),.bus(bus_MC),.send_bus(send_bus_MC),.write_to_rec(write_rec_MC),.done(done_sender_MC));
receiver recMC(.clk(clock),.send(send_bus_MC),.reset(reset),.write_in(write_rec_MC),.bus(bus_MC),.data_out(SM_rData),.addr_out(abcd),.write(write_receiver),.read(read_receiver));


data_mem  u_data_mem (
    .clock                   ( clock        ),
    .reset                   ( reset        ),
    .read                    ( SM_read      ),
    .write                   ( BM_write     ),
    
    
    .done_sender             (done_sender_MC),
    
    .memAddr_wr              ( BM_addr   ),
    .wData                   ( BM_wData     ),
    .memAddr_rd              (SM_addr),

    .rData                   ( CM_rData     ),
    .raddr                   (MC_raddr),
    .send                    (send_MC),
    .write_sender            (write_MC)
);


endmodule
