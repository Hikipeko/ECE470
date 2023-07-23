`include "sys_defs.vh"

`define BLOCK_OFFSET (cpuAddr[(2+`WORD_PER_BLOCK_ADDR_SIZE)+:`BLOCK_PER_CACHE_ADDR_SIZE])
`define WORD_OFFSET (cpuAddr[2+:`WORD_PER_BLOCK_ADDR_SIZE])
`define TAG_FIELD (cpuAddr[(`MEM_ADDR_SIZE-1):(2+`WORD_PER_BLOCK_ADDR_SIZE+`BLOCK_PER_CACHE_ADDR_SIZE)])

module cache (
    input clock,
    input reset,
    input cpuRead,
    input cpuWrite,
    input [`MEM_ADDR_SIZE-1:0] cpuAddr,
    input [`WORD_SIZE_BIT-1:0] cpuData,
    input [`WORD_SIZE_BIT-1:0] memData,
    input done_sender,
    input write_receiver,
    input read_receiver,

    output reg hit,
    output reg read,
    output reg write,

    output reg send,

    output reg [`WORD_SIZE_BIT-1:0] rData,
    output reg [`MEM_ADDR_SIZE-1:0] addr,
    output reg [`WORD_SIZE_BIT-1:0] wData
);

  reg valid[`BLOCK_PER_CACHE-1:0];
  reg dirty[`BLOCK_PER_CACHE-1:0];
  reg [(`MEM_ADDR_SIZE-2-`WORD_PER_BLOCK_ADDR_SIZE-`BLOCK_PER_CACHE_ADDR_SIZE):0] tag[`BLOCK_PER_CACHE-1:0];
  reg [`WORD_SIZE_BIT-1:0] block[`BLOCK_PER_CACHE-1:0][`WORD_PER_BLOCK-1:0];


  reg [`MEM_ADDR_SIZE-1:0] addr2mem_reg[`WORD_PER_BLOCK-1:0];
  reg [`MEM_ADDR_SIZE-1:0] addrrdmem_reg[`WORD_PER_BLOCK-1:0];
  reg [`WORD_SIZE_BIT-1:0] data2mem_reg[`WORD_PER_BLOCK-1:0];
  reg [4:0] counter_send, counter_read, receiver_counter;
  reg block_transmission_done;

  reg [`WORD_PER_BLOCK_ADDR_SIZE-1:0] j;
  reg [`BLOCK_PER_CACHE_ADDR_SIZE-1:0] i;


  initial begin
    i = 0;
    repeat (`BLOCK_PER_CACHE) begin
      j = 0;
      repeat (`WORD_PER_BLOCK) begin
        block[i][j] = 0;
        j = j + 1;
      end
      dirty[i] = 1'b0;
      valid[i] = 1'b0;
      tag[i] = 0;
      addr2mem_reg[i] = 0;
      addrrdmem_reg[i] = 0;
      data2mem_reg[i] = 0;
      i = i + 1;
    end
    counter_send = 0;
    counter_read = 0;
    receiver_counter = 0;
    block_transmission_done = 0;
    hit = 1'b0;
    read = 1'b0;
    write = 1'b0;
    addr = 'bz;
    rData = 'bz;
    wData = 'bz;
  end

  always @(reset or cpuRead or cpuWrite or cpuAddr or cpuData or block_transmission_done) begin
    hit = 1'b0;
    if (cpuRead == 1'b1) begin  //read case
      if (valid[`BLOCK_OFFSET] == 1'b0 | tag[`BLOCK_OFFSET] != `TAG_FIELD) begin  // miss

        if (counter_read == 0) begin
          counter_read = `WORD_PER_BLOCK;
          j = 0;
          repeat (`WORD_PER_BLOCK) begin
            addrrdmem_reg[j] = {`TAG_FIELD, `BLOCK_OFFSET, j, 2'b00};
            j = j + 1;
          end
        end

      end  // hit
      else begin  // why else??
        rData = block[`BLOCK_OFFSET][`WORD_OFFSET];

        hit   = 1'b1;
      end
    end else if (cpuWrite == 1'b1) begin  //write case
      if (valid[`BLOCK_OFFSET] == 1'b0 | tag[`BLOCK_OFFSET] != `TAG_FIELD) begin  // miss
        if (counter_read == 0) begin
          counter_read = `WORD_PER_BLOCK;
          j = 0;
          repeat (`WORD_PER_BLOCK) begin
            addrrdmem_reg[j] = {`TAG_FIELD, `BLOCK_OFFSET, j, 2'b00};
            j = j + 1;
          end
        end
        valid[`BLOCK_OFFSET] = 1'b1;
        //dirty[`BLOCK_OFFSET] = 1'b1;
        tag[`BLOCK_OFFSET]   = `TAG_FIELD;
      end else begin  //hit (also why else?
        valid[`BLOCK_OFFSET] = 1'b1;
        //dirty[`BLOCK_OFFSET] = 1'b1;
        tag[`BLOCK_OFFSET] = `TAG_FIELD;

        block[`BLOCK_OFFSET][`WORD_OFFSET] = cpuData;


        if (counter_send == 0) begin
          counter_send = `WORD_PER_BLOCK;
          j = 0;
          repeat (`WORD_PER_BLOCK) begin
            addr2mem_reg[j] = {tag[`BLOCK_OFFSET], `BLOCK_OFFSET, j, 2'b00};
            data2mem_reg[j] = block[`BLOCK_OFFSET][j];
            j = j + 1;
          end

        end
        hit = 1'b1;
      end
    end
  end

  //always @(done_sender or write_receiver or read_receiver or addr2mem_reg or addrrdmem_reg or data2mem_reg) begin// no memData
  always @(posedge clock) begin
    if (write_receiver) begin
      block[`BLOCK_OFFSET][receiver_counter] = memData;
      if (receiver_counter == `WORD_PER_BLOCK - 1) begin
        block_transmission_done = 1;
        receiver_counter = 0;
        tag[`BLOCK_OFFSET] = `TAG_FIELD;
        valid[`BLOCK_OFFSET] = 1'b1;
        dirty[`BLOCK_OFFSET] = 1'b0;
      end else begin
        receiver_counter = receiver_counter + 1;
      end
    end else begin
      block_transmission_done = 0;
    end
  end




  always @(negedge clock) begin
    if (done_sender) begin
      send = 0;
      if (counter_send > 0) begin
        counter_send = counter_send - 1;
      end else if (counter_read > 0) begin
        counter_read = counter_read - 1;
      end
    end else begin
      if (counter_read > 0 || counter_send > 0) begin
        send  = 1;
        write = (counter_send > 0);
        if (counter_send > 0) begin
          wData = data2mem_reg[`WORD_PER_BLOCK-counter_send];
          addr  = addr2mem_reg[`WORD_PER_BLOCK-counter_send];
        end else begin
          wData = 0;
          addr  = addrrdmem_reg[`WORD_PER_BLOCK-counter_read];
        end
      end else begin
        send  = 0;
        write = 0;
      end
    end
  end

endmodule
