`include "cache.v"
`include "cpu.v"
`include "data_mem.v"

module top
(
    input wire clock,
    input wire reset
);
wire [7:0] CC_addr,CM_addr;
wire [31:0] CC_wData,CC_rData,CM_wData,CM_rData;
wire CC_read,CC_write,hit,CM_read,CM_write,done_w,done_r;


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
    .reset                   (reset       ),
    .cpuRead                 ( CC_read    ),
    .cpuWrite                ( CC_write   ),
    .cpuAddr                 ( CC_addr    ),
    .cpuData                 ( CC_wData    ),
    .memData                 ( CM_rData    ),
    .done_w                  ( done_w      ),
    .done_r                  ( done_r      ),

    .hit                     ( hit        ),
    .read                    ( CM_read       ),
    .write                   ( CM_write      ),
    .rData                   ( CC_rData      ),
    .addr                    ( CM_addr       ),
    .wData                   ( CM_wData      )
);

data_mem  u_data_mem (
    .clock                   ( clock        ),
    .reset                   ( reset        ),
    .read                    ( CM_read      ),
    .write                   ( CM_write     ),
    .memAddr                 ( CM_addr   ),
    .wData                   ( CM_wData     ),

    .rData                   ( CM_rData     ),
    .done_w                  ( done_w      ),
    .done_r                  ( done_r      )
);


endmodule
