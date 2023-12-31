`include "sys_defs.vh"
module cpu (
    input clock,
    input reset,
    input [`WORD_SIZE_BIT-1:0] rData,
    input hit,
    output [`MEM_ADDR_SIZE-1:0] Address,
    output [`WORD_SIZE_BIT-1:0] Write_Data,
    output wire read,
    output wire write,
    output wire finish
);

  reg [4:0] count;
  reg rEnable[`INSTR_NUM-1:0];
  reg wEnable[`INSTR_NUM-1:0];
  reg [`MEM_ADDR_SIZE-1:0] cacheAddr[`INSTR_NUM-1:0];
  reg [`WORD_SIZE_BIT-1:0] memData[`INSTR_NUM-1:0];

  initial begin

    rEnable[0] = 1'b1;
    wEnable[0] = 1'b0;
    cacheAddr[0] = 8'b00100100;
    memData[0] = 'd588;
    rEnable[1] = 1'b0;
    wEnable[1] = 1'b1;
    cacheAddr[1] = 8'b10100100;
    memData[1] = 'd716;
    rEnable[2] = 1'b1;
    wEnable[2] = 1'b0;
    cacheAddr[2] = 8'b11010100;
    memData[2] = 'd819;
    rEnable[3] = 1'b0;
    wEnable[3] = 1'b1;
    cacheAddr[3] = 8'b01100000;
    memData[3] = 'd751;
    rEnable[4] = 1'b1;
    wEnable[4] = 1'b0;
    cacheAddr[4] = 8'b00100100;
    memData[4] = 'd375;
    rEnable[5] = 1'b0;
    wEnable[5] = 1'b1;
    cacheAddr[5] = 8'b10111000;
    memData[5] = 'd265;
    rEnable[6] = 1'b1;
    wEnable[6] = 1'b0;
    cacheAddr[6] = 8'b11100100;
    memData[6] = 'd326;
    rEnable[7] = 1'b0;
    wEnable[7] = 1'b1;
    cacheAddr[7] = 8'b01000000;
    memData[7] = 'd158;
    rEnable[8] = 1'b1;
    wEnable[8] = 1'b0;
    cacheAddr[8] = 8'b01011000;
    memData[8] = 'd751;
    rEnable[9] = 1'b0;
    wEnable[9] = 1'b1;
    cacheAddr[9] = 8'b00110000;
    memData[9] = 'd152;
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
  assign finish = (count == `INSTR_NUM);
endmodule
