`include"sys_defs.vh"
module cache (
    input clock,
    input reset,
    input cpuRead,
    input cpuWrite,
    input [`MEM_ADDR_SIZE-1:0] cpuAddr,
    input [`WORD_SIZE_BIT-1:0] cpuData,
    input [`WORD_SIZE_BIT-1:0] memData,
    /*input done_w,
    input done_r,*/
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

  reg valid[3:0];
  reg dirty[3:0];
  reg [`MEM_ADDR_SIZE-7:0] tag[3:0];
  reg [`WORD_SIZE_BIT-1:0] block[3:0][3:0];
  
  
  reg [`MEM_ADDR_SIZE-1:0] addr2mem_reg[3:0];
  reg [`MEM_ADDR_SIZE-1:0] addrrdmem_reg[3:0];
  reg [`WORD_SIZE_BIT-1:0] data2mem_reg[3:0];
  reg [4:0] counter_send, counter_read, receiver_counter;
  reg block_transmission_done;
  
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
      addr2mem_reg[i] = 0;
      addrrdmem_reg[i] = 0;
      data2mem_reg[i] = 0;
      counter_send = 0;
      counter_read = 0;
      receiver_counter = 0;
      block_transmission_done = 0;
    end
    hit   = 1'b0;
    read  = 1'b0;
    write = 1'b0;
    addr  = 'bz;
    rData = 'bz;
    wData = 'bz;
  end

  always @(reset or cpuRead or cpuWrite or cpuAddr or cpuData or block_transmission_done) begin
    hit = 1'b0;
    #1
      if (cpuRead == 1'b1) begin  //read case
        if (valid[blockOffset] == 1'b0 | tag[blockOffset] != cpuTag) begin  // miss
          
          if (counter_read == 0) begin
            counter_read = 4;
            addrrdmem_reg[0]  = {cpuAddr[9:4], 4'b0000};
            addrrdmem_reg[1] = {cpuAddr[9:4], 4'b0100};
            addrrdmem_reg[2] = {cpuAddr[9:4], 4'b1000};
            addrrdmem_reg[3] = {cpuAddr[9:4], 4'b1100};
          end
          //valid[blockOffset] = 1'b1;
          //dirty[blockOffset] = 1'b1;
          //tag[blockOffset]   = cpuTag;
        
          /*read  = 1;
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
          dirty[blockOffset] = 1'b0;*/
        end
         // hit
        else begin  // why else??
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
          if (counter_read == 0) begin
            counter_read = 4;
            addrrdmem_reg[0]  = {cpuAddr[9:4], 4'b0000};
            addrrdmem_reg[1] = {cpuAddr[9:4], 4'b0100};
            addrrdmem_reg[2] = {cpuAddr[9:4], 4'b1000};
            addrrdmem_reg[3] = {cpuAddr[9:4], 4'b1100};
          end
          valid[blockOffset] = 1'b1;
          //dirty[blockOffset] = 1'b1;
          tag[blockOffset]   = cpuTag;
        end
        else begin  //hit (also why else?
          valid[blockOffset] = 1'b1;
          //dirty[blockOffset] = 1'b1;
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
          
          if (counter_send == 0) begin
                counter_send = 4;
                addr2mem_reg[0] = {tag[blockOffset], cpuAddr[5:4], 4'b0000};
                data2mem_reg[0] = block[blockOffset][0];
                addr2mem_reg[1]  = {tag[blockOffset], cpuAddr[5:4], 4'b0100};
                data2mem_reg[1] = block[blockOffset][1];
                addr2mem_reg[2]  = {tag[blockOffset], cpuAddr[5:4], 4'b1000};
                data2mem_reg[2] = block[blockOffset][2];
                addr2mem_reg[3]  = {tag[blockOffset], cpuAddr[5:4], 4'b1100};
                data2mem_reg[3] = block[blockOffset][3];
            end
          hit = 1'b1;
        end
      end
  end

    //always @(done_sender or write_receiver or read_receiver or addr2mem_reg or addrrdmem_reg or data2mem_reg) begin// no memData
    always @(posedge clock) begin
        if (write_receiver) begin
            block[blockOffset][receiver_counter] = memData;
            if (receiver_counter == 3) begin
                block_transmission_done = 1;
                receiver_counter = 0;
                tag[blockOffset] = cpuTag;
                valid[blockOffset] = 1'b1;
                dirty[blockOffset] = 1'b0;
            end
            else begin
                receiver_counter = receiver_counter + 1;
            end
        end
        else begin
             block_transmission_done = 0;
        end
    end
    
    
    
    
    always @(negedge clock) begin
        if (done_sender) begin
            send = 0;
            if (counter_send > 0 ) begin
                counter_send = counter_send - 1;
            end
            else if (counter_read > 0) begin
                counter_read = counter_read - 1;
            end
        end
        else begin
            if (counter_read > 0 || counter_send > 0) begin
                send = 1;
                write = (counter_send > 0);
                if (counter_send > 0 ) begin
                    wData = data2mem_reg[4-counter_send];
                    addr = addr2mem_reg[4-counter_send];
                end
                else begin
                    wData = 0;
                    addr = addrrdmem_reg[4-counter_read];
                end
            end
            else begin
                send = 0;
                write = 0;
            end
        end
    end

endmodule
