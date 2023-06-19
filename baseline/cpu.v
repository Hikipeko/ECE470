module cpu (
    input clock,
    input [31:0] rData,
    input hit,
    output [9:0] Address,
    output [31:0] Write_Data,
    output wire read,
    output wire write
);

  reg [3:0] count;
  reg rEnable[11:0];
  reg wEnable[11:0];
  reg [9:0] cacheAddr[11:0];
  reg [31:0] memData[11:0];

  initial begin
    rEnable[0] = 1'b1;
    wEnable[0] = 1'b0;
    cacheAddr[0] = 10'b0001_10_00_00;
    memData[0] = 'd0;
    rEnable[1] = 1'b1;
    wEnable[1] = 1'b0;
    cacheAddr[1] = 10'b0001_01_00_01;
    memData[1] = 'd0;
    rEnable[2] = 1'b0;
    wEnable[2] = 1'b1;
    cacheAddr[2] = 10'b0001_00_00_00;
    memData[2] = 'd123;
    rEnable[3] = 1'b0;
    wEnable[3] = 1'b1;
    cacheAddr[3] = 10'b0000_11_00_10;
    memData[3] = 'd234;
    rEnable[4] = 1'b0;
    wEnable[4] = 1'b1;
    cacheAddr[4] = 10'b0011_10_10_00;
    memData[4] = 'd345;
    rEnable[5] = 1'b0;
    wEnable[5] = 1'b1;
    cacheAddr[5] = 10'b0111_00_11_00;
    memData[5] = 'd456;
    rEnable[6] = 1'b1;
    wEnable[6] = 1'b0;
    cacheAddr[6] = 10'b0011_01_00_00;
    memData[6] = 'd0;
    rEnable[7] = 1'b1;
    wEnable[7] = 1'b0;
    cacheAddr[7] = 10'b0111_10_11_01;
    memData[7] = 'd0;
    rEnable[8] = 1'b0;
    wEnable[8] = 1'b1;
    cacheAddr[8] = 10'b1010_11_10_00;
    memData[8] = 'd567;
    rEnable[9] = 1'b0;
    wEnable[9] = 1'b1;
    cacheAddr[9] = 10'b0001_00_01_11;
    memData[9] = 'd678;
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
