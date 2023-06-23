module cache (
    // input clock,
    input reset,
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

  reg valid[3:0];
  reg dirty[3:0];
  reg [3:0] tag[3:0];
  reg [31:0] block0[3:0];
  reg [31:0] block1[3:0];
  reg [31:0] block2[3:0];
  reg [31:0] block3[3:0];
  // reg [31:0] word;

  wire [1:0] blockOffset;
  wire [1:0] wordOffset;
  wire [3:0] cpuTag;
  assign blockOffset = cpuAddr[5:4];
  assign wordOffset = cpuAddr[3:2];
  assign cpuTag = cpuAddr[9:6];

  integer i;
  initial begin
    for (i = 0; i < 4; i = i + 1) begin
      dirty[i] = 1'b0;
      valid[i] = 1'b0;
      tag[i] = 4'b0;
      block0[i] = 32'b0;
      block1[i] = 32'b0;
      block2[i] = 32'b0;
      block3[i] = 32'b0;
    end
    hit   = 1'b0;
    read  = 1'b0;
    write = 1'b0;
    addr  = 'bz;
    rData = 'bz;
    wData = 'bz;
  end

  //assign hit = (valid[blockOffset] == 1'b0) ? 1'b0 : (tag[blockOffset] == cpuTag);
  always @(*) begin
    hit = 1'b0;
      if (cpuRead == 1'b1) begin  //read case
        if (valid[blockOffset] == 1'b0 | tag[blockOffset] != cpuTag) begin  // miss
          if (dirty[blockOffset] == 1'b1) begin  //dirty
            write = 1;
            #1 write = 0;
            @(posedge done);
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b0000};
            wData = block0[blockOffset];
            write = 1;
            #1 write = 0;
            @(posedge done);
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b0100};
            wData = block1[blockOffset];
            write = 1;
            #1 write = 0;
            @(posedge done);
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b1000};
            wData = block2[blockOffset];
            write = 1;
            #1 write = 0;
            @(posedge done);
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b1100};
            wData = block3[blockOffset];
            // write = 1;
          end
          write = 0;
          read  = 1;
          addr  = {cpuAddr[9:4], 4'b0000};
          #1 read  = 0;
          @(posedge done) read = 1;
          block0[blockOffset] = memData;
          addr = {cpuAddr[9:4], 4'b0100};
          @(posedge done) read = 1;
          #1 read  = 0;
          block1[blockOffset] = memData;
          addr = {cpuAddr[9:4], 4'b1000};
          @(posedge done) read = 1;
          #1 read  = 0;
          block2[blockOffset] = memData;
          addr = {cpuAddr[9:4], 4'b1100};
          @(posedge done) read = 1;
          #1 read  = 0;
          block3[blockOffset] = memData;
          read = 0;
          tag[blockOffset] = cpuTag;
          valid[blockOffset] = 1'b1;
          dirty[blockOffset] = 1'b0;
        end
        begin  //hit
          if (wordOffset == 2'b00) begin
            rData = block0[blockOffset];
          end else if (wordOffset == 2'b01) begin
            rData = block1[blockOffset];
          end else if (wordOffset == 2'b10) begin
            rData = block2[blockOffset];
          end else begin
            rData = block3[blockOffset];
          end
          hit = 1'b1;
        end
      end else if (cpuWrite == 1'b1) begin  //write case
        if (valid[blockOffset] == 1'b0 | tag[blockOffset] != cpuTag) begin  // miss
          if (dirty[blockOffset] == 1'b1) begin  //dirty
            write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b0000};
            wData = block0[blockOffset];
            #1 write = 0;
            @(posedge done) write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b0100};
            wData = block1[blockOffset];
            #1 write = 0;
            @(posedge done) write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b1000};
            wData = block2[blockOffset];
            #1 write = 0;
            @(posedge done) write = 1;
            addr  = {tag[blockOffset], cpuAddr[5:4], 4'b1100};
            wData = block3[blockOffset];
            #1 write = 0;
            @(posedge done);
          end
          write = 0;
          read  = 1;
          addr  = {cpuAddr[9:4], 4'b0000};
          #1 read = 0;
          @(posedge done) read  = 1;
          block0[blockOffset] = memData;
          addr = {cpuAddr[9:4], 4'b0100};
          #1 read = 0;
          @(posedge done) read  = 1;
          block1[blockOffset] = memData;
          addr = {cpuAddr[9:4], 4'b1000};
          #1 read = 0;
          @(posedge done) read  = 1;
          block2[blockOffset] = memData;
          addr = {cpuAddr[9:4], 4'b1100};
          #1 read = 0;
          @(posedge done) read  = 1;
          block3[blockOffset] = memData;
          #1 read = 0;
          
          tag[blockOffset] = cpuTag;
          valid[blockOffset] = 1'b1;
          dirty[blockOffset] = 1'b0;
        end
        begin  //hit
          valid[blockOffset] = 1'b1;
          dirty[blockOffset] = 1'b1;
          tag[blockOffset]   = cpuTag;
          if (wordOffset == 2'b00) begin
            block0[blockOffset] = cpuData;
          end else if (wordOffset == 2'b01) begin
            block1[blockOffset] = cpuData;
          end else if (wordOffset == 2'b10) begin
            block2[blockOffset] = cpuData;
          end else begin
            block3[blockOffset] = cpuData;
          end
          hit = 1'b1;
        end
      end
  end


endmodule
