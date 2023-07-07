`timescale 1ns / 1ps
module cpu (
    input clock,
    input reset,
    input [31:0] rData,
    input hit,
    output [9:0] Address,
    output [31:0] Write_Data,
    output wire read,
    output wire write
);

  reg [3:0] count;
  reg rEnable[9:0];
  reg wEnable[9:0];
  reg [9:0] cacheAddr[9:0];
  reg [31:0] memData[9:0];

  initial begin
    rEnable[0] = 1'b1;
    wEnable[0] = 1'b0;
    cacheAddr[0] = 10'b0001_10_00_00;
    memData[0] = 'd0;//read 24     cache 2 : 24 25 26 27
    rEnable[1] = 1'b1;
    wEnable[1] = 1'b0;
    cacheAddr[1] = 10'b0001_01_00_01;
    memData[1] = 'd0;//read 20     cache 1: 20 21 22 23
    rEnable[2] = 1'b0;
    wEnable[2] = 1'b1;
    cacheAddr[2] = 10'b0001_00_00_00;
    memData[2] = 'd123;//write 123 to 16   cache 0: 123 17 18 19
    rEnable[3] = 1'b0;
    wEnable[3] = 1'b1;
    cacheAddr[3] = 10'b0000_11_00_10;
    memData[3] = 'd234;//write 234 to 12 cache 3: 234 13 14 15
    rEnable[4] = 1'b0;
    wEnable[4] = 1'b1;
    cacheAddr[4] = 10'b0011_10_10_00;
    memData[4] = 'd345;//write 345 to 58 cache 2: 56 57 345 59
    rEnable[5] = 1'b0;
    wEnable[5] = 1'b1;
    cacheAddr[5] = 10'b0011_00_11_00;
    memData[5] = 'd456;//write 456 to 51 cache 0: 48 49 50 456 write mem[16]:123
    rEnable[6] = 1'b1;
    wEnable[6] = 1'b0;
    cacheAddr[6] = 10'b0011_01_00_00;
    memData[6] = 'd0;//read 52 cache 1: 52 53 54 55
    rEnable[7] = 1'b1;
    wEnable[7] = 1'b0;
    cacheAddr[7] = 10'b0011_10_11_01;
    memData[7] = 'd0;//read 59 hit
    rEnable[8] = 1'b0;
    wEnable[8] = 1'b1;
    cacheAddr[8] = 10'b0010_11_10_00;
    memData[8] = 'd567;//write 567 to 46 cache 3: 44 45 567 47  write mem[12]:234
    rEnable[9] = 1'b0;
    wEnable[9] = 1'b1;
    cacheAddr[9] = 10'b0001_00_01_11;
    memData[9] = 'd678;//write 678 to 17 cache 0: 123 678 18 19 
    count = 0;
  end

  always @(posedge clock) begin
    if (hit) count = count + 1;
    else count = count;
  end
  assign read = rEnable[count];
  assign write = wEnable[count];
  assign Address = cacheAddr[count];
  assign Write_Data = memData[count];
endmodule
