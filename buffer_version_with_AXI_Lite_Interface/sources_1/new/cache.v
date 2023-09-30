`include "sys_defs.vh"

`define BLOCK_OFFSET (cpuAddr[(2+`WORD_PER_BLOCK_ADDR_SIZE)+:`BLOCK_PER_CACHE_ADDR_SIZE])
`define WORD_OFFSET (cpuAddr[2+:`WORD_PER_BLOCK_ADDR_SIZE])
`define TAG_FIELD (cpuAddr[(`MEM_ADDR_SIZE-1):(2+`WORD_PER_BLOCK_ADDR_SIZE+`BLOCK_PER_CACHE_ADDR_SIZE)])
`define MEM_IN_BLOCK_OFFSET (addr_rd[(2+`WORD_PER_BLOCK_ADDR_SIZE)+:`BLOCK_PER_CACHE_ADDR_SIZE])
`define MEM_IN_WORD_OFFSET (addr_rd[2+:`WORD_PER_BLOCK_ADDR_SIZE])
`define MEM_IN_TAG_FIELD (addr_rd[(`MEM_ADDR_SIZE-1):(2+`WORD_PER_BLOCK_ADDR_SIZE+`BLOCK_PER_CACHE_ADDR_SIZE)])

module cache (
    input clock,
    input reset,
    input cpuRead,
    input cpuWrite,
    input [`MEM_ADDR_SIZE-1:0] cpuAddr,
    input [`WORD_SIZE_BIT-1:0] cpuData,
    input [`WORD_SIZE_BIT-1:0] memData,
    input [`MEM_ADDR_SIZE-1:0] memAddr,
    input done_sender,
    input write_receiver,
    //input read_receiver,
    input full,
    input buffer_hit,
    input [`WORD_SIZE_BIT-1:0] data_read_from_buffer,


    output reg hit,
    output reg read_buffer,
    output reg write_addrsender,
    output reg write_buffer,

    output reg send_addr,

    output reg [`WORD_SIZE_BIT-1:0] rData,
    output reg [`MEM_ADDR_SIZE-1:0] addr,
    output reg [`MEM_ADDR_SIZE-1:0] addr_rd,
    output reg [`WORD_SIZE_BIT-1:0] wData,
    output reg [`WORD_SIZE_BIT-1:0] addr_sendData
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
  reg read_miss;
  reg [2:0] miss_reg;
  reg write_reg;
  reg read_miss_buffer_fetch;

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
    hit = 1'b0;
    read_buffer = 1'b0;
    write_addrsender = 1'b0;
    write_buffer = 0;
    addr = 'bz;
    addr_rd = 'bz;
    rData = 'bz;
    wData = 'bz;
    miss_reg = 0;
    read_miss = 0;
    send_addr = 0;
    addr_sendData = 0;
    counter_send = 0;
    counter_read = 0;
    receiver_counter = 0;
    block_transmission_done = 0;
    write_reg = 0;
    read_miss_buffer_fetch = 0;
  end

  always @(reset or cpuRead or cpuWrite or cpuAddr or cpuData or block_transmission_done or miss_reg) begin
    hit = 1'b0;
    read_miss = 0;
    if (cpuRead == 1'b1) begin  //read case
      if (valid[`BLOCK_OFFSET] == 1'b0 | tag[`BLOCK_OFFSET] != `TAG_FIELD & buffer_hit == 0) begin  // miss
        read_miss = 1;
        if (miss_reg == 2) begin
          if (dirty[`BLOCK_OFFSET] == 1'b1) begin  //dirty
            if (counter_send == 0) begin
              counter_send = `WORD_PER_BLOCK;
              j = 0;
              repeat (`WORD_PER_BLOCK) begin
                addr2mem_reg[j] = {tag[`BLOCK_OFFSET], `BLOCK_OFFSET, j, 2'b00};
                data2mem_reg[j] = block[`BLOCK_OFFSET][j];
                j = j + 1;
              end
            end
          end
          if (counter_read == 0) begin
            counter_read = `WORD_PER_BLOCK;
            j = 0;
            repeat (`WORD_PER_BLOCK) begin
              addrrdmem_reg[j] = {`TAG_FIELD, `BLOCK_OFFSET, j, 2'b00};
              j = j + 1;
            end
          end
        end
      end else begin  //hit
        if (buffer_hit == 1) begin
          hit = 1'b1;
          rData = data_read_from_buffer;
          miss_reg = 0;
        end else begin
          rData = block[`BLOCK_OFFSET][`WORD_OFFSET];
          hit = 1'b1;
          miss_reg = 0;
        end
      end
    end else if (cpuWrite == 1'b1) begin  //write case
      if (valid[`BLOCK_OFFSET] == 1'b0 | tag[`BLOCK_OFFSET] != `TAG_FIELD) begin  // miss
        if (full == 1) begin
          if (dirty[`BLOCK_OFFSET] == 1'b1) begin  //dirty
            if (counter_send == 0) begin
              counter_send = `WORD_PER_BLOCK;
              j = 0;
              repeat (`WORD_PER_BLOCK) begin
                addr2mem_reg[j] = {tag[`BLOCK_OFFSET], `BLOCK_OFFSET, j, 2'b00};
                data2mem_reg[j] = block[`BLOCK_OFFSET][j];
                j = j + 1;
              end
            end
          end
          if (counter_read == 0) begin
            counter_read = `WORD_PER_BLOCK;
            j = 0;
            repeat (`WORD_PER_BLOCK) begin
              addrrdmem_reg[j] = {`TAG_FIELD, `BLOCK_OFFSET, j, 2'b00};
              j = j + 1;
            end
          end
        end else begin
          if (counter_send == 0 && counter_read == 0) begin
            counter_send = 1;
            data2mem_reg[`WORD_PER_BLOCK-counter_send] = cpuData;
            addr2mem_reg[`WORD_PER_BLOCK-counter_send] = cpuAddr;
            write_reg = 1;
          end
        end
      end else begin  //hit
        valid[`BLOCK_OFFSET] = 1'b1;
        dirty[`BLOCK_OFFSET] = 1'b1;
        tag[`BLOCK_OFFSET] = `TAG_FIELD;
        block[`BLOCK_OFFSET][`WORD_OFFSET] = cpuData;
        hit = 1'b1;
      end
    end
  end
  always @(posedge clock) begin
    if (read_miss_buffer_fetch == 1) begin
        if (buffer_hit == 1) begin
          read_miss_buffer_fetch = 0;
          block[addrrdmem_reg[`WORD_PER_BLOCK-counter_read][(2+`WORD_PER_BLOCK_ADDR_SIZE)+:`BLOCK_PER_CACHE_ADDR_SIZE]][addrrdmem_reg[`WORD_PER_BLOCK-counter_read][2+:`WORD_PER_BLOCK_ADDR_SIZE]] = data_read_from_buffer;
          if (receiver_counter == `WORD_PER_BLOCK - 1) begin
            block_transmission_done = !block_transmission_done;
            receiver_counter = 0;
            tag[addrrdmem_reg[`WORD_PER_BLOCK-counter_read][(2+`WORD_PER_BLOCK_ADDR_SIZE)+:`BLOCK_PER_CACHE_ADDR_SIZE]] = addrrdmem_reg[`WORD_PER_BLOCK-counter_read][(`MEM_ADDR_SIZE-1):(2+`WORD_PER_BLOCK_ADDR_SIZE+`BLOCK_PER_CACHE_ADDR_SIZE)];
            valid[addrrdmem_reg[`WORD_PER_BLOCK-counter_read][(2+`WORD_PER_BLOCK_ADDR_SIZE)+:`BLOCK_PER_CACHE_ADDR_SIZE]] = 1'b1;
            dirty[addrrdmem_reg[`WORD_PER_BLOCK-counter_read][(2+`WORD_PER_BLOCK_ADDR_SIZE)+:`BLOCK_PER_CACHE_ADDR_SIZE]] = 1'b0;
          end else begin
            receiver_counter = receiver_counter + 1;
          end
          if (counter_read > 0) begin
            counter_read = counter_read - 1;
          end
        end
    end
    if (miss_reg == 1) begin
      if (buffer_hit) begin
        miss_reg = 0;
      end else begin
        miss_reg = 2;
      end
    end
    if (write_receiver) begin
      block[`MEM_IN_BLOCK_OFFSET][`MEM_IN_WORD_OFFSET] = memData;
      if (receiver_counter == `WORD_PER_BLOCK - 1) begin
        block_transmission_done = !block_transmission_done;
        receiver_counter = 0;
        tag[`MEM_IN_BLOCK_OFFSET] = `MEM_IN_TAG_FIELD;
        valid[`MEM_IN_BLOCK_OFFSET] = 1'b1;
        dirty[`MEM_IN_BLOCK_OFFSET] = 1'b0;
      end else begin
        receiver_counter = receiver_counter + 1;
      end
    end else begin
      block_transmission_done = block_transmission_done;
    end
  end

  always @(negedge clock) begin
    if (done_sender) begin
      send_addr = 0;
      if (counter_read > 0) begin
        counter_read = counter_read - 1;
      end
    end
    if (read_miss == 1 && miss_reg == 0) begin
      if (cpuRead == 1) begin
        read_buffer = 1;
        addr = cpuAddr;
        miss_reg = 1;
      end
    end else begin
      read_buffer = 0;
    end
    if (counter_read > 0 || (counter_send > 0 && full != 1)) begin
      write_buffer = (counter_send > 0 && full != 1);
      if (counter_send > 0) begin
        if (full != 1) begin
          wData = data2mem_reg[`WORD_PER_BLOCK-counter_send];
          addr = addr2mem_reg[`WORD_PER_BLOCK-counter_send];
          counter_send = counter_send - 1;
          if (write_reg == 1 && counter_send == 0) begin
            hit = 1'b1;
            write_reg = 0;
          end
          else begin
            write_reg = write_reg;
          end
        end
      end
      else begin
        if (read_miss_buffer_fetch == 0) begin
            read_miss_buffer_fetch = 1;
            read_buffer = 1;
            addr = addrrdmem_reg[`WORD_PER_BLOCK-counter_read];
        end
        else begin
            read_miss_buffer_fetch = 0;
            send_addr = 1;
            write_addrsender = 0;
            addr_sendData = 0;
            addr_rd = addrrdmem_reg[`WORD_PER_BLOCK-counter_read];
        end
      end
    end
    else begin
      write_buffer = 0;
      send_addr = 0;
    end
  end
endmodule
