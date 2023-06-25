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

module tb(
    );
    //universal regs
    reg clk,reset,send;
    
    
    //data sender
    /*reg [`WORD_SIZE_BIT-1:0] data_in;
    wire [`WORD_SIZE_BIT-1:0] data_out;
    wire [`BANDWIDTH_WRITE_DATA-1:0] data_bus;
    wire send_data,done_data,write_data;*/
    
    
    // addr sender
    reg send_wr_addr;
    reg [`MEM_ADDR_SIZE - 1 : 0]write_address;
    wire [`BANDWIDTH_WRITE_ADDRESS-1:0]addr_bus;
    wire [`MEM_ADDR_SIZE - 1 : 0] addr_out;
    wire send_addr,done_addr;
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end
    //data sender
    //sender sd(.clk(clk),.send(send),.reset(reset),.data_in(data_in),.data_bus(data_bus),.send_data(send_data),.done_data(done_data));
    //receiver rec(.clk(clk),.send_data(send_data),.reset(reset),.data_bus(data_bus),.data_out(data_out),.write(write_data));
    
    
    //address sender
    address_sender adsd(.clk(clk),.send(send_wr_addr),.reset(reset),.addr_in(write_address),.addr_bus(addr_bus),.send_addr(send_addr),.done_addr(done_addr));
    address_receiver adrec(.clk(clk),.send_addr(send_addr),.reset(reset),.addr_bus(addr_bus),.addr_out(addr_out));

    
    initial begin
       //test for data sender
       /*reset = 1;
       #20
       reset = 0;
       send = 1;
       data_in = 10;
       #20
       @(posedge(done_data))
       reset = 0;
       send = 1;
       data_in = 32'h12345678;
       #20
       @(posedge(done_data))
       reset = 0;
       send = 1;
       data_in = 32'hffffffff;
       #20
       @(posedge(done_data))
       reset = 0;
       send = 1;
       data_in = 32'habcdffff;
       #20
       @(posedge(done_data))
       reset = 0;
       send = 1;
       data_in = 32'h00000000;
       #20
       @(posedge(done_data))
       reset = 0;
       send = 1;
       data_in = 32'haaaaaaaa;
       #20
       @(posedge(done_data))
       reset = 0;
       send = 1;
       data_in = 32'ha123434a;
       #20
       @(posedge(done_data))
       reset = 0;
       send = 1;
       data_in = 32'hfdcbafff;*/
       
       
       
       // tests for address sender receiver
       reset = 1;
       #20
       reset = 0;
       send_wr_addr = 1;
       write_address = 10;
       #20
       @(posedge(done_addr))
       send_wr_addr = 1;
       write_address = 10'hab;
       #20
       @(posedge(done_addr))
       send_wr_addr = 1;
       write_address = 10'hfff;
       #20
       @(posedge(done_addr))
       send_wr_addr = 1;
       write_address = 10'hbbb;
       #20
       @(posedge(done_addr))
       send_wr_addr = 1;
       write_address = 10'hccc;
       #20
       @(posedge(done_addr))
       send_wr_addr = 1;
       write_address = 10'hddd;
    end
endmodule
