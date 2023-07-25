`include "sys_defs.vh"
module data_mem
(
  input clock,
  input reset,
  input read,
  input write,
  input [`MEM_ADDR_SIZE-1:0] memAddr,
  input [`WORD_SIZE_BIT-1:0] wData,
  output reg [`WORD_SIZE_BIT-1:0] rData,
  output reg done_w,
  output reg done_r
);

// content
reg [`WORD_SIZE_BIT-1:0] memory [`MEM_SIZE_WORD:0];
integer i;
//initialize the memory with 1 to MEM_SIZE_WORD
initial 
begin
  #0 done_w = 0;done_r = 0; rData = 'bz;
  for(i=0;i<`MEM_SIZE_WORD;i=i+1)
  begin
    memory[i]=i;
  end        
end

always @ (posedge clock)
begin
  if(write == 1) begin
    memory[memAddr[`MEM_ADDR_SIZE-1:2]] = wData;
    `MEM_DELAY;
    done_w = 1;
  end
end

always @ (posedge clock)
begin
  if(read == 1) begin
    `MEM_DELAY;
    rData =  memory[memAddr[`MEM_ADDR_SIZE-1:2]];
    done_r = 1;
  end
end

always @ (negedge clock) 
begin
  done_w = 0;
  done_r = 0;
end
endmodule
