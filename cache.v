module cache
(
  input cpuRead,
  input cpuWrite,
  input [9:0] cpuAddr,
  input [31:0] cpuData,
  input [31:0] memData,
  input done,
  
  output reg hit,
  output reg read,
  output reg write,
  output reg [31:0] rData,
  output reg [9:0] addr,
  output reg [31:0] wData
);

reg valid [3:0];
reg dirty [3:0];
reg [3:0] tag [3:0];
reg [31:0] block0 [3:0];
reg [31:0] block1 [3:0];
reg [31:0] block2 [3:0];
reg [31:0] block3 [3:0];

wire [1:0] blockOffset;
wire [1:0] wordOffset;
assign blockOffset = cpuAddr[5:4];
assign wordOffset = cpuAddr[3:2];

integer i;
initial
begin
for(i=0;i<3;i=i+1)
begin
  dirty[i] = 1'b0;valid[i] = 1'b0;tag[i] = 4'b0;block0[i] = 32'b0;block1[i] = 32'b0;block2[i] = 32'b0; block3[i] = 32'b0;
end
  hit = 1'b0;
  read = 1'b0;
  write = 1'b0;
  addr = 'bz;
  rData = 'bz;
  wData = 'bz;
end



endmodule
