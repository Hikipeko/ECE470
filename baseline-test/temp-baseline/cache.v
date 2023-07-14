`include"sys_defs.vh"
module cache (
    // input clock,
    input reset,
    input cpuRead,
    input cpuWrite,
    input [`MEM_ADDR_SIZE-1:0] cpuAddr,
    input [`WORD_SIZE_BIT-1:0] cpuData,
    input [`WORD_SIZE_BIT-1:0] memData,
    input done_w,
    input done_r,

    output reg hit,
    output reg read,
    output reg write,
    output reg [`WORD_SIZE_BIT-1:0] rData,
    output reg [`MEM_ADDR_SIZE-1:0] addr,
    output reg [`WORD_SIZE_BIT-1:0] wData
);

  reg valid[3:0];
  reg dirty[3:0];
  reg [`MEM_ADDR_SIZE-7:0] tag[3:0];
  reg [`WORD_SIZE_BIT-1:0] block[3:0][3:0];

  wire [1:0] blockOffset;
  wire [1:0] wordOffset;
  wire [`MEM_ADDR_SIZE-7:0] cpuTag;
  assign blockOffset = cpuAddr[5:4];
  assign wordOffset = cpuAddr[3:2];
  assign cpuTag = cpuAddr[`WORD_SIZE_BIT-1:6];

  integer i;
  initial begin
    for (i = 0; i < 4; i = i + 1) begin
      dirty[i] = 1'b0;
      valid[i] = 1'b0;
      tag[i] = 0;
      block[0][i] = 0;
      block[1][i] = 0;
      block[2][i] = 0;
      block[3][i] = 0;
    end
    hit   = 1'b0;
    read  = 1'b0;
    write = 1'b0;
    addr  = 'bz;
    rData = 'bz;
    wData = 'bz;
  end

  always @(*) begin
    hit = 1'b0;
    #1
      if (cpuRead == 1'b1) begin  //read case
        if (valid[blockOffset] == 1'b0 | tag[blockOffset] != cpuTag) begin  // miss
          if (dirty[blockOffset] == 1'b1) begin  //dirty
            write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b0000};
            wData = block[blockOffset][0];
            #22 write = 0;
            @(posedge done_w) write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b0100};
            wData = block[blockOffset][1];
            #22 write = 0;
            @(posedge done_w) write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b1000};
            wData = block[blockOffset][2];
            #22 write = 0;
            @(posedge done_w) write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b1100};
            wData = block[blockOffset][3];
            #22 write = 0;
            @(posedge done_w);
          end
          read  = 1;
          addr  = {cpuAddr[9:4], 4'b0000};
          #22 read = 0;
          @(posedge done_r); read  = 1;
          block[blockOffset][0] = memData;
          addr = {cpuAddr[9:4], 4'b0100};
          #22 read = 0;
          @(posedge done_r); read  = 1;
          block[blockOffset][1] = memData;
          addr = {cpuAddr[9:4], 4'b1000};
          #22 read = 0;
          @(posedge done_r); read  = 1;
          block[blockOffset][2] = memData;
          addr = {cpuAddr[9:4], 4'b1100};
          #22 read = 0;
          @(posedge done_r);
          block[blockOffset][3] = memData;

          tag[blockOffset] = cpuTag;
          valid[blockOffset] = 1'b1;
          dirty[blockOffset] = 1'b0;
        end
        begin  //hit
          if (wordOffset == 2'b00) begin
            rData = block[blockOffset][0];
          end else if (wordOffset == 2'b01) begin
            rData = block[blockOffset][1];
          end else if (wordOffset == 2'b10) begin
            rData = block[blockOffset][2];
          end else begin
            rData = block[blockOffset][3];
          end
          hit = 1'b1;
        end
      end else if (cpuWrite == 1'b1) begin  //write case
        if (valid[blockOffset] == 1'b0 | tag[blockOffset] != cpuTag) begin  // miss
          if (dirty[blockOffset] == 1'b1) begin  //dirty
            write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b0000};
            wData = block[blockOffset][0];
            #22 write = 0;
            @(posedge done_w) write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b0100};
            wData = block[blockOffset][1];
            #22 write = 0;
            @(posedge done_w) write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b1000};
            wData = block[blockOffset][2];
            #22 write = 0;
            @(posedge done_w) write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b1100};
            wData = block[blockOffset][3];
            #22 write = 0;
            @(posedge done_w);
          end
          read  = 1;
          addr  = {cpuAddr[9:4], 4'b0000};
          #22 read = 0;
          @(posedge done_r) read  = 1;
          block[blockOffset][0] = memData;
          addr = {cpuAddr[9:4], 4'b0100};
          #22 read = 0;
          @(posedge done_r) read  = 1;
          block[blockOffset][1] = memData;
          addr = {cpuAddr[9:4], 4'b1000};
          #22 read = 0;
          @(posedge done_r) read  = 1;
          block[blockOffset][2] = memData;
          addr = {cpuAddr[9:4], 4'b1100};
          #22 read = 0;
          @(posedge done_r);
          block[blockOffset][3] = memData;
          
          tag[blockOffset] = cpuTag;
          valid[blockOffset] = 1'b1;
          dirty[blockOffset] = 1'b0;
        end
        begin  //hit
          valid[blockOffset] = 1'b1;
          dirty[blockOffset] = 1'b1;
          tag[blockOffset]   = cpuTag;
          if (wordOffset == 2'b00) begin
            block[blockOffset][0] = cpuData;
          end else if (wordOffset == 2'b01) begin
            block[blockOffset][1] = cpuData;
          end else if (wordOffset == 2'b10) begin
            block[blockOffset][2] = cpuData;
          end else begin
            block[blockOffset][3] = cpuData;
          end
          hit = 1'b1;
        end
      end
  end


endmodule
