`include "sys_defs.vh"
module data_mem
(
  input clock,
  input reset,
  input read,
  input write,
  input [9:0] memAddr,
  input [31:0] wData,
  output reg [31:0] rData,
  output reg done
);

// content
reg [31:0] memory [63:0];
integer i;
//initialize the memory with 1 to 64
initial 
begin
  #0 done = 0; rData = 'bz;
  for(i=0;i<64;i=i+1)
  begin
    memory[i]=i;
  end        
end

always @ (posedge clock)
begin
  if(write == 1) begin
    memory[memAddr[9:2]] = wData;
    `MEM_DELAY;
    done = 1;
  end
end

always @ (posedge clock)
begin
  if(read == 1) begin
    `MEM_DELAY;
    rData =  memory[memAddr[9:2]];
    done = 1;
  end
end

always @ (negedge clock) 
begin
  done = 0;
end
endmodule
