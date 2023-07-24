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
    cacheAddr[0] = 8'b10001100;
    memData[0] = 'd783;
    rEnable[1] = 1'b0;
    wEnable[1] = 1'b1;
    cacheAddr[1] = 8'b11000100;
    memData[1] = 'd763;
    rEnable[2] = 1'b1;
    wEnable[2] = 1'b0;
    cacheAddr[2] = 8'b11100100;
    memData[2] = 'd102;
    rEnable[3] = 1'b0;
    wEnable[3] = 1'b1;
    cacheAddr[3] = 8'b10001100;
    memData[3] = 'd586;
    rEnable[4] = 1'b1;
    wEnable[4] = 1'b0;
    cacheAddr[4] = 8'b00001100;
    memData[4] = 'd763;
    rEnable[5] = 1'b0;
    wEnable[5] = 1'b1;
    cacheAddr[5] = 8'b11000000;
    memData[5] = 'd55;
    rEnable[6] = 1'b1;
    wEnable[6] = 1'b0;
    cacheAddr[6] = 8'b00101100;
    memData[6] = 'd863;
    rEnable[7] = 1'b0;
    wEnable[7] = 1'b1;
    cacheAddr[7] = 8'b10110000;
    memData[7] = 'd961;
    rEnable[8] = 1'b1;
    wEnable[8] = 1'b0;
    cacheAddr[8] = 8'b00100100;
    memData[8] = 'd312;
    rEnable[9] = 1'b0;
    wEnable[9] = 1'b1;
    cacheAddr[9] = 8'b10100100;
    memData[9] = 'd599;
    rEnable[10] = 1'b1;
    wEnable[10] = 1'b0;
    cacheAddr[10] = 8'b11111100;
    memData[10] = 'd786;
    rEnable[11] = 1'b0;
    wEnable[11] = 1'b1;
    cacheAddr[11] = 8'b01011100;
    memData[11] = 'd532;
    rEnable[12] = 1'b1;
    wEnable[12] = 1'b0;
    cacheAddr[12] = 8'b01011000;
    memData[12] = 'd224;
    rEnable[13] = 1'b0;
    wEnable[13] = 1'b1;
    cacheAddr[13] = 8'b01101000;
    memData[13] = 'd927;
    rEnable[14] = 1'b1;
    wEnable[14] = 1'b0;
    cacheAddr[14] = 8'b01110000;
    memData[14] = 'd685;
    rEnable[15] = 1'b0;
    wEnable[15] = 1'b1;
    cacheAddr[15] = 8'b11101000;
    memData[15] = 'd537;
    rEnable[16] = 1'b1;
    wEnable[16] = 1'b0;
    cacheAddr[16] = 8'b00000000;
    memData[16] = 'd796;
    rEnable[17] = 1'b0;
    wEnable[17] = 1'b1;
    cacheAddr[17] = 8'b11110000;
    memData[17] = 'd955;
    rEnable[18] = 1'b1;
    wEnable[18] = 1'b0;
    cacheAddr[18] = 8'b11011000;
    memData[18] = 'd815;
    rEnable[19] = 1'b0;
    wEnable[19] = 1'b1;
    cacheAddr[19] = 8'b11011000;
    memData[19] = 'd736;
    rEnable[20] = 1'b1;
    wEnable[20] = 1'b0;
    cacheAddr[20] = 8'b11101100;
    memData[20] = 'd856;
    rEnable[21] = 1'b0;
    wEnable[21] = 1'b1;
    cacheAddr[21] = 8'b01111100;
    memData[21] = 'd584;
    rEnable[22] = 1'b1;
    wEnable[22] = 1'b0;
    cacheAddr[22] = 8'b01000100;
    memData[22] = 'd635;
    rEnable[23] = 1'b0;
    wEnable[23] = 1'b1;
    cacheAddr[23] = 8'b00011100;
    memData[23] = 'd124;
    rEnable[24] = 1'b1;
    wEnable[24] = 1'b0;
    cacheAddr[24] = 8'b10100100;
    memData[24] = 'd12;
    rEnable[25] = 1'b0;
    wEnable[25] = 1'b1;
    cacheAddr[25] = 8'b10100100;
    memData[25] = 'd618;
    rEnable[26] = 1'b1;
    wEnable[26] = 1'b0;
    cacheAddr[26] = 8'b00111100;
    memData[26] = 'd572;
    rEnable[27] = 1'b0;
    wEnable[27] = 1'b1;
    cacheAddr[27] = 8'b01110000;
    memData[27] = 'd763;
    rEnable[28] = 1'b1;
    wEnable[28] = 1'b0;
    cacheAddr[28] = 8'b10100100;
    memData[28] = 'd764;
    rEnable[29] = 1'b0;
    wEnable[29] = 1'b1;
    cacheAddr[29] = 8'b01010000;
    memData[29] = 'd150;
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
