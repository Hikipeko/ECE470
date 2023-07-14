`timescale 1ns / 1ps
`include "sys_defs.vh"
module data_mem
(
  input clock,
  input reset,
  input read,
  input write,
  
  input done_sender,
  
  input [`MEM_ADDR_SIZE-1:0] memAddr_wr,
  input [`WORD_SIZE_BIT-1:0] wData,
  input [`MEM_ADDR_SIZE-1:0] memAddr_rd,
  output reg [`WORD_SIZE_BIT-1:0] rData,
  output reg [`MEM_ADDR_SIZE-1:0] raddr,
  /*output reg done_w,
  output reg done_r,*/

  output reg send,
  output reg write_sender
);

// content
reg [`WORD_SIZE_BIT-1:0] memory [`MEM_SIZE_WORD-1:0];



reg [`WORD_SIZE_BIT-1:0] delay_simulation_wrdata [`MEM_DELAY_REG - 1 : 0];
reg [`MEM_ADDR_SIZE-1:0] delay_simulation_wraddr [`MEM_DELAY_REG - 1 : 0];
reg [`WORD_SIZE_BIT-1:0] delay_simulation_rdaddr [`MEM_DELAY_REG - 1 : 0];
// whether corresponding delay_simulation_wrdata is valid (should be write to memory)
reg delay_wrprogress [`MEM_DELAY_REG - 1 : 0]; 
// whether corresponding delay_simulation_rdaddr is valid
reg delay_rdprogress [`MEM_DELAY_REG - 1 : 0];

integer i;
// initialize the memory with 1 to MEM_SIZE_WORD
initial 
begin
  #0 // done_w = 0;done_r = 0;
  rData = 'bz;send = 0;
  for(i=0;i<`MEM_SIZE_WORD;i=i+1)
  begin
    memory[i]=i;
  end
  for(i=0;i<`MEM_DELAY_REG;i=i+1)
  begin
    delay_wrprogress[i] = 0;
    delay_rdprogress[i] = 0;
    delay_simulation_wrdata[i] = 0;
    delay_simulation_wraddr[i] = 0;
    delay_simulation_rdaddr[i] = 0;
  end
end

always @ (posedge clock)
begin
  if (delay_wrprogress[`MEM_DELAY_REG - 1] == 1) begin
  // write valid data to memory
    memory[delay_simulation_wraddr[`MEM_DELAY_REG - 1][`MEM_ADDR_SIZE-1:2]] = delay_simulation_wrdata[`MEM_DELAY_REG - 1];
    // done_w = 1;
  end
  for(i=`MEM_DELAY_REG-1;i > 0; i = i - 1)
  // simulate write delay
  begin
    delay_wrprogress[i] = delay_wrprogress[i-1];
    delay_simulation_wrdata[i] = delay_simulation_wrdata[i-1];
    delay_simulation_wraddr[i] = delay_simulation_wraddr[i-1];
  end
  if(write == 1) begin
  // store data in delay register
      delay_wrprogress[0] = 1;
      delay_simulation_wrdata[0] = wData;
      delay_simulation_wraddr[0] = memAddr_wr;
  end
  else begin
      delay_wrprogress[0] = 0;
      delay_simulation_wrdata[0] = 0;
      delay_simulation_wraddr[0] = 0;
  end
  
  for(i=`MEM_DELAY_REG-1;i > 0; i = i - 1)
  // simulate read delay
  begin
    delay_rdprogress[i] = delay_rdprogress[i-1];
    delay_simulation_rdaddr[i] = delay_simulation_rdaddr[i-1];
  end
  if(read == 1) begin
      delay_rdprogress[0] = 1;
      delay_simulation_rdaddr[0] = memAddr_rd;
  end
  else begin
      delay_rdprogress[0] = 0;
      delay_simulation_rdaddr[0] = 0;
  end
end


always @ (negedge clock)
begin
  if (done_sender) send = 0;
  if (delay_rdprogress[`MEM_DELAY_REG - 1] == 1) begin
  // read finished
    rData =  memory[delay_simulation_rdaddr[`MEM_DELAY_REG - 1][`MEM_ADDR_SIZE-1:2]];
    raddr = delay_simulation_rdaddr[`MEM_DELAY_REG - 1];
    // done_r = 1;
    send = 1;
    write_sender = 1;
  end
end


always @ (posedge done_sender) 
begin
    if (delay_rdprogress[`MEM_DELAY_REG - 1] == 1) send = send;
    else send = 0;
end
endmodule
