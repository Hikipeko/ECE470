`include "cache.v"
`include "cpu.v"
`include "data_mem.v"
`include "receiver.v"
`include "sender.v"

module top
(
    input wire clock,
    input wire reset
);
wire [9:0] CC_addr,CS_addr,SM_addr,MC_raddr,abcd;
wire [31:0] CC_wData,CC_rData,CS_wData,SM_wData,CM_rData,SM_rData;
wire [`BANDWIDTH_WRITE_DATA-1:0] bus,bus_MC;
wire CC_read,CC_write,hit,CM_read,SM_write,SM_read,CM_write,done_w,done_r,send,done_sender,write_receiver,read_receiver,send_bus,write_rec;
wire done_sender_MC,send_MC,write_MC,write_rec_MC,send_bus_MC;

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
    /*.done_w                  ( done_w      ),
    .done_r                  ( done_r      ),*/
    .done_sender             (done_sender),
    .write_receiver          (write_receiver),
    .read_receiver           (read_receiver),

    .hit                     ( hit        ),
    .read                    ( CM_read       ),
    .write                   ( CM_write      ),
    
    
    .send                    (send),
    
    .rData                   ( CC_rData      ),
    .addr                    ( CS_addr       ),
    .wData                   ( CS_wData      )
);


sender sdCM(.clk(clock),.send(send),.reset(reset),.data_in(CS_wData),.addr_in(CS_addr),.write(CM_write),.bus(bus),.send_bus(send_bus),.write_to_rec(write_rec),.done(done_sender));
receiver recCM(.clk(clock),.send(send_bus),.reset(reset),.write_in(write_rec),.bus(bus),.data_out(SM_wData),.addr_out(SM_addr),.write(SM_write),.read(SM_read));

sender sdMC(.clk(clock),.send(send_MC),.reset(reset),.data_in(CM_rData),.addr_in(MC_raddr),.write(write_MC),.bus(bus_MC),.send_bus(send_bus_MC),.write_to_rec(write_rec_MC),.done(done_sender_MC));
receiver recMC(.clk(clock),.send(send_bus_MC),.reset(reset),.write_in(write_rec_MC),.bus(bus_MC),.data_out(SM_rData),.addr_out(abcd),.write(write_receiver),.read(read_receiver));


data_mem  u_data_mem (
    .clock                   ( clock        ),
    .reset                   ( reset        ),
    .read                    ( SM_read      ),
    .write                   ( SM_write     ),
    
    
    .done_sender             (done_sender_MC),
    
    .memAddr                 ( SM_addr   ),
    .wData                   ( SM_wData     ),

    .rData                   ( CM_rData     ),
    .raddr                   (MC_raddr),
    /*.done_w                  ( done_w      ),
    .done_r                  ( done_r      )*/
    .send                    (send_MC),
    .write_sender            (write_MC)
);


endmodule
