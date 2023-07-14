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
    cacheAddr[0] = 10'b0001010001;
    memData[0] = 'd691;
    rEnable[1] = 1'b0;
    wEnable[1] = 1'b1;
    cacheAddr[1] = 10'b0000011110;
    memData[1] = 'd51;
    rEnable[2] = 1'b1;
    wEnable[2] = 1'b0;
    cacheAddr[2] = 10'b0000000101;
    memData[2] = 'd945;
    rEnable[3] = 1'b0;
    wEnable[3] = 1'b1;
    cacheAddr[3] = 10'b0001101011;
    memData[3] = 'd722;
    rEnable[4] = 1'b1;
    wEnable[4] = 1'b0;
    cacheAddr[4] = 10'b0000111111;
    memData[4] = 'd156;
    rEnable[5] = 1'b0;
    wEnable[5] = 1'b1;
    cacheAddr[5] = 10'b0011111111;
    memData[5] = 'd702;
    rEnable[6] = 1'b1;
    wEnable[6] = 1'b0;
    cacheAddr[6] = 10'b0000100001;
    memData[6] = 'd59;
    rEnable[7] = 1'b0;
    wEnable[7] = 1'b1;
    cacheAddr[7] = 10'b0011000010;
    memData[7] = 'd312;
    rEnable[8] = 1'b1;
    wEnable[8] = 1'b0;
    cacheAddr[8] = 10'b0011111000;
    memData[8] = 'd900;
    rEnable[9] = 1'b0;
    wEnable[9] = 1'b1;
    cacheAddr[9] = 10'b0010011111;
    memData[9] = 'd487;
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
