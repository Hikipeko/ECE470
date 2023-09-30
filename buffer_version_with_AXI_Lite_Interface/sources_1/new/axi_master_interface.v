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

module axi_master_interface(
    input clk,
    input reset,
    //AW Channel
    output reg [7:0] AWADDR,
    output reg AWVALID,
    input AWREADY,

    //W Channel
    output reg [31:0] WDATA,
    output reg WVALID,
    output reg WLAST,
    input WREADY,

    //B Channel
    input BRESP,
    input BVALID,
    output reg BREADY,
    
    //AR Channel
    output reg [7:0] ARADDR,
    output reg ARVALID,
    input ARREADY,
    
    //R Channel 
    input [31:0] RDATA,
    input RVALID,
    output reg RREADY,
    input RLAST,
    input RRESP,
    
    //to cache/buffer
    output reg [31:0] data_rd,
    output reg done,
    output reg done_r,
    input write,
    input read,
    input [7:0] addr_wr,
    input [7:0] addr_rd,
    input [31:0] data_wr
);

    reg flag_w, flag_r;
    always @(posedge clk) begin
        if (reset) begin
            AWADDR <= 0;
            AWVALID <= 0;
            WDATA <= 0;
            WVALID <= 0;
            WLAST <= 0;
            BREADY <= 0;
            ARADDR <= 0;
            ARVALID <= 0;
            RREADY <= 0;
            data_rd <= 0;
            done <= 0;
            done_r <= 0;
            flag_w <= 0;
            flag_r <= 0;
        end
        else begin
            if (write) begin
                if (done) flag_w <= 0;
                if (!flag_w) begin
                    AWADDR <= addr_wr;
                    AWVALID <= 1;
                    if (AWREADY) begin
                        AWADDR <= 0;
                        AWVALID <= 0;
                        flag_w <= 1;
                    end
                end
                else begin
                    AWADDR <= 0;
                    AWVALID <= 0;
                end
                
                if (WREADY && !WLAST) begin
                    WDATA <= data_wr;
                    WVALID <= 1;
                    WLAST <= 1;
                    BREADY <= 1;
                end
                else begin
                    WDATA <= 0;
                    WVALID <= 0;
                    WLAST <= 0;
                    BREADY <= 0;
                end
                
                if (BREADY) begin
                    if (BVALID && BRESP) begin
                        BREADY <= 0;
                        done <= 1;
                    end
                    else begin
                        BREADY <= 1;
                        done <= 0;
                    end
                end
                else begin
                    done <= 0;
                end
            end
            else begin
                AWADDR <= 0;
                AWVALID <= 0;
                WDATA <= 0;
                WVALID <= 0;
                WLAST <= 0;
                BREADY <= 0;
                done <= 0;
                flag_w <= 0;
            end
            
            if (read) begin
                if (done_r) flag_r <= 0;
                if (!flag_r) begin
                    ARADDR <= addr_rd;
                    ARVALID <= 1;
                    if (ARREADY) begin
                        ARADDR <= 0;
                        ARVALID <= 0;
                        flag_r <= 1;
                    end
                end
                else begin
                    ARADDR <= 0;
                    ARVALID <= 0;
                end


                if (flag_r && !done_r) begin
                    RREADY <= 1;
                end
                if (RREADY && RLAST && RVALID) begin
                    RREADY <= 0;
                end
                
                if (RVALID) begin
                    data_rd <= RDATA;
                    if (RRESP && RLAST) done_r <= 1;
                    else done_r <= 0;
                end
                else begin
                    done_r <= 0;
                    data_rd <= 0;
                end
            end
            else begin
                ARADDR <= 0;
                ARVALID <= 0;
                RREADY <= 0;
                data_rd <= 0;
                flag_r <= 0;
                done_r <= 0;
            end
        end
    end

endmodule
