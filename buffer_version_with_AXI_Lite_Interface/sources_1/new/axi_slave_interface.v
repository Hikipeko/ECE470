`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.09.2023 15:24:17
// Design Name: 
// Module Name: axi_master_interface
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
`include "sys_defs.vh"

module axi_slave_interface(
    input clk,
    input reset,
    //AW Channel
    input [7:0] AWADDR,
    input AWVALID,
    output reg AWREADY,

    //W Channel
    input [31:0] WDATA,
    input WVALID,
    input WLAST,
    output reg WREADY,
    
    //B Channel
    output reg BRESP,
    output reg BVALID,
    input BREADY,
    
    //AR Channel
    input [7:0] ARADDR,
    input ARVALID,
    output reg ARREADY,
    
    //R Channel 
    output reg [31:0] RDATA,
    output reg RVALID,
    input RREADY,
    output reg RLAST,
    output reg RRESP,
    
    
    // from memory
    //to memory
    input [31:0] MDATA_in,
    input send,
    output reg send_done,
    output reg [31:0] MDATA,
    output reg [7:0] memAddr_rd,
    output reg [7:0] memAddr_wr,
    output reg write,
    output reg read
    
    
    );
    reg w_flag;
    reg [7:0] waddr,raddr;
    //reg [31:0] data [`burst_length_word - 1:0];
    reg [5:0] count;
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            AWREADY <= 0;
            WREADY <= 0;
            ARREADY <= 0;
            count <= 0;
            BRESP <= 0;
            BVALID <= 0;
            RDATA <= 0;
            RVALID <= 0;
            RLAST <= 0;
            RRESP <= 0;
            MDATA <= 0;
            memAddr_rd <= 0;
            memAddr_wr <= 0;
            write <=0;
            read <= 0;
            waddr <= 0;
            raddr <= 0;
            w_flag <= 0;
            /*for (i = 0; i <`burst_length_word; i=i+1) begin
                data[i] <= 0;
            end*/
        end
        else begin
            if (AWVALID && !AWREADY) begin
                waddr <= AWADDR;
                AWREADY <= 1;
                w_flag <= 1;
            end
            else begin
                AWREADY <= 0;
            end
            
            
            if (w_flag) begin
                WREADY <= 1;
                if (WVALID && WREADY) begin
                    if (WLAST) begin
                        memAddr_wr <= waddr;
                        MDATA <= WDATA;
                        write = 1;
                        WREADY <= 0;
                        w_flag <= 0;
                    end
                    else begin
                        memAddr_wr <= waddr;
                        MDATA <= WDATA;
                        write = 1;
                    end
                end
            end
            else begin
                WREADY <= 0;
            end
            
            if (BREADY && WLAST && !BVALID) begin
                BVALID <= 1;
                BRESP <= 1;
            end
            else begin
                BVALID <= 0;
                BRESP <= 0;
            end
            
            if (ARVALID && !ARREADY) begin
                ARREADY <= 1;
                read <= 1;
                memAddr_rd <= ARADDR;
            end
            else begin
                ARREADY <= 0;
                memAddr_rd <= 0;
                read <= 0;
            end
            
            if (RREADY) begin
                if (send) begin
                    RRESP <= 1;
                    RDATA <= MDATA_in;
                    send_done <= 1;
                    RLAST <= 1;
                    RVALID <= 1;
                end
                else begin
                    RVALID <= 0;
                    RRESP <= 0;
                    RDATA <= 0;
                    send_done <= 0;
                    RLAST <= 0;
                end
            end
            else begin
                RVALID <= 0;
                RRESP <= 0;
                RDATA <= 0;
                send_done <= 0;
                RLAST <= 0;
            end
        end
    end
    
    
    /*always @(negedge clk) begin
        WREADY = 0;
        write = 0;
        MDATA = 0;
        read = 0;
        memAddr_rd = 0;
        memAddr_wr = 0;
        if (count > 0) begin
            MDATA = data[0];
            memAddr_wr = waddr;
            for (i = 0; i < `burst_length_word-1; i = i + 1) begin
                data[i] = data[i+1];
            end
            data[`burst_length_word-1] = 0;
            write = 1;
        end
        else begin
            
        end
    end*/
    
endmodule
