`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.09.2023 15:36:54
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench_axi();
    reg clk, reset,write, read;
    reg [7:0] addr_wr, addr_rd;
    reg [127:0] data_wr;
    reg [2:0] w_burst, r_burst;
    integer i;
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        r_burst = 0;
        w_burst = 0;
        
        #10
        reset = 1;
        #20 
        reset = 0;
        write = 1;
        read = 0;
        data_wr = 128'habcd1010efef11112222222233333333;
        addr_wr = 8'b00000100;
        r_burst = 0;
        w_burst = 4;
        @(posedge done)
        read = 1;
        write = 0;
        r_burst = 4;
        w_burst = 0;
        data_wr = 0;
        addr_rd = 8'b00000100;
        #500 
        $finish;
    end
    wire  AWVALID,AWREADY,WVALID, WLAST, WREADY, BRESP, BVALID, BREADY, ARVALID, ARREADY, RVALID, RREADY, RLAST, RRESP,done,done_r;
    wire [7:0] AWADDR, ARADDR,memAddr_rd,memAddr_wr;
    wire [31:0] WDATA, RDATA, data_rd, MDATA_in, MDATA;
    wire send,send_done, write_s, read_s, write_out;
    wire [2:0] AWBURST, ARBURST, burst_rd;
    
    axi_master_interface ami(
        .clk(clk),
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
        .data_rd(data_rd),
        .done(done),
        .done_r(done_r),
        .write_out(write_out),
        .write(write),
        .read(read),
        .addr_wr(addr_wr),
        .addr_rd(addr_rd),
        .data_wr(data_wr),
        .w_burst(w_burst),
        .r_burst(r_burst)
        );
   
    axi_slave_interface asi(
        .clk(clk),
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
        .MDATA_in(MDATA_in),
        .send(send),
        .send_done(send_done),
        .MDATA(MDATA),
        .memAddr_rd(memAddr_rd),
        .memAddr_wr(memAddr_wr),
        .burst_rd(burst_rd),
        .write(write_s),
        .read(read_s)
        );
    
    mem m_u(
        .clk(clk),
        .MDATA_in(MDATA_in),
        .send(send),
        .send_done(send_done),
        .MDATA(MDATA),
        .memAddr_rd(memAddr_rd),
        .memAddr_wr(memAddr_wr),
        .burst_rd(burst_rd),
        .write(write_s),
        .read(read_s)
        );

    always #10 begin
      for (i = 0; i < 6; i = i + 1) begin
        $display("%0h, ", m_u.memory[i]);
      end
    end

endmodule
