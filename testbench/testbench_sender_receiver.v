`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.06.2023 17:38:50
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
`include"sys_defs.vh"

module testbench(
    );

    reg clk,reset,send;
    
    /*reg [`WORD_SIZE_BIT-1:0] data_in;
    wire [`WORD_SIZE_BIT-1:0] data_out;
    wire [`BANDWIDTH_WRITE_DATA-1:0] data_bus;
    wire [`MEM_ADDR_SIZE - 1 : 0] addr_out;
    wire send_data,done,write_data;*/
    
    reg send_wr_addr;
    reg [`MEM_ADDR_SIZE - 1 : 0]write_address;
    wire [`BANDWIDTH_WRITE_ADDRESS-1:0]addr_bus;
    
    wire send_addr,done;
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    
    //sender sd(.clk(clk),.send(send),.reset(reset),.data_in(data_in),.data_bus(data_bus),.send_data(send_data),.done(done));
    //receiver rec(.clk(clk),.send_data(send_data),.reset(reset),.data_bus(data_bus),.data_out(data_out),.write(write_data));
    
    
    
    address_sender adsd(.clk(clk),.send(send_wr_addr),.reset(reset),.addr_in(write_address),.addr_bus(addr_bus),.send_addr(send_addr),.done(done));
    address_receiver adrec(.clk(clk),.send_addr(send_addr),.reset(reset),.addr_bus(addr_bus),.addr_out(addr_out));

    
    initial begin
       /*reset = 1;
       #50
       reset = 0;
       send = 1;
       data_in = 10;*/
       reset = 1;
       #50
       reset = 0;
       send_wr_addr = 1;
       write_address = 10;
       #50
       send_wr_addr = 1;
       write_address = 10'hab;
    end
    /*always@(done)begin
        send = done ? 0 : 1;
        data_in = 32'hef87abcd;
    end*/
endmodule
