`include"sys_defs.vh"


module top
(
    input wire clock,
    input wire reset
);
wire [`MEM_ADDR_SIZE-1:0] CC_addr,CS_addr,SM_addr,BM_addr,MC_raddr,abcd,buffer_addr_in,buffer_addr_out;
wire [`WORD_SIZE_BIT-1:0] CC_wData,CC_rData,CS_wData,SM_wData,BM_wData,CM_rData,SM_rData,buffer_data_in,buffer_data_out,data_read_from_buffer;
wire [`BANDWIDTH_WRITE_DATA-1:0] bus_BM,bus_CM_rd,bus_MC;
wire write_buffer,CC_read,CC_write,hit,read_buffer,SM_write,SM_read,CM_write,BM_write,BM_read,done_w,done_r,send_addr,send_buffer,SC_done_sender_rd,write_receiver,read_receiver,send_bus,write_rec,send_bus_BM,send_wr_addr;
wire done_sender_MC,send_MC,write_MC,write_rec_MC,send_bus_MC,done_buffer,addr_done,buffer_hit,write_buffer_out,write_rec_buffer;
wire AWVALID,AWREADY, WVALID, WLAST, WREADY, BRESP, BVALID, BREADY, ARVALID, ARREADY, RVALID, RREADY, RLAST, RRESP, write_out;
wire [7:0] AWADDR, ARADDR;
wire [31:0] WDATA, RDATA;
wire [3:0] AWBURST, ARBURST, w_burst, r_burst,burst_rd;
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
    .memAddr                 (abcd),
    .done_sender             (write_receiver),//(SC_done_sender_rd),
    .write_receiver          (write_out),
    
    
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
    .addr_sendData           (CS_wData),
  
    .r_burst(r_burst)
);



axi_master_interface ami(
    .clk(clock),
    .reset(reset),
    //AW Channel
    .AWADDR(AWADDR),
    .AWVALID(AWVALID),
    .AWBURST(AWBURST),
    .AWREADY(AWREADY),

    //W Channel
    .WDATA(WDATA),
    .WVALID(WVALID),
    .WLAST(WLAST),
    .WREADY(WREADY),

    //B Channel
    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),
    
    //AR Channel
    .ARADDR(ARADDR),
    .ARVALID(ARVALID),
    .ARBURST(ARBURST),
    .ARREADY(ARREADY),
    
    //R Channel 
    .RDATA(RDATA),
    .RVALID(RVALID),
    .RREADY(RREADY),
    .RLAST(RLAST),
    .RRESP(RRESP),
    
    //to cache/buffer
    .data_rd(SM_rData),
    .done(done_buffer),
    .done_r(write_receiver),
    .write_out(write_out),
    .write(write_buffer_out && send_buffer),
    .read(send_addr),
    .addr_wr(buffer_addr_out),
    .addr_rd(CS_addr),
    .data_wr(buffer_data_out),
    .w_burst(w_burst),
    .r_burst(r_burst)
);

axi_slave_interface asi(
    .clk(clock),
    .reset(reset),
    //AW Channel
    .AWADDR(AWADDR),
    .AWVALID(AWVALID),
    .AWBURST(AWBURST),
    .AWREADY(AWREADY),

    //W Channel
    .WDATA(WDATA),
    .WVALID(WVALID),
    .WLAST(WLAST),
    .WREADY(WREADY),

    //B Channel
    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),
    
    //AR Channel
    .ARADDR(ARADDR),
    .ARVALID(ARVALID),
    .ARBURST(ARBURST),
    .ARREADY(ARREADY),
    
    //R Channel 
    .RDATA(RDATA),
    .RVALID(RVALID),
    .RREADY(RREADY),
    .RLAST(RLAST),
    .RRESP(RRESP),
    
    
    // from memory
    //to memory
    .MDATA_in(CM_rData),
    .send(send_MC),
    .send_done(done_sender_MC),
    .MDATA(BM_wData),
    .memAddr_rd(SM_addr),
    .memAddr_wr(BM_addr),
    .burst_rd(burst_rd),
    .write(BM_write),
    .read(SM_read)
    );



buffer bbff(.clk(clock),.reset(reset),.write_back_address(buffer_addr_in),.write_back_data(buffer_data_in),.write(write_buffer),.done(done_buffer),.addr_done(addr_done), .read(read_buffer),
.full(full),.buffer_hit(buffer_hit),.write_data(buffer_data_out), .write_address(buffer_addr_out),.data_read_to_cache(data_read_from_buffer),.send_wr_data(send_buffer),.send_wr_addr(send_wr_addr),.write_out(write_buffer_out),.w_burst(w_burst));


data_mem  u_data_mem (
    .clock                   ( clock        ),
    .reset                   ( reset        ),
    .read                    ( SM_read      ),
    .write                   ( BM_write     ),
    
    
    .done_sender             (done_sender_MC),
    
    .memAddr_wr              ( BM_addr   ),
    .wData                   ( BM_wData     ),
    .memAddr_rd              (SM_addr),
    .burst_rd                 (burst_rd),

    .rData                   ( CM_rData     ),
    .raddr                   (MC_raddr),
    .send                    (send_MC),
    .write_sender            (write_MC)
);


endmodule
