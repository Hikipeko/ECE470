`include"sys_defs.vh"
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

  reg valid[3:0];
  reg dirty[3:0];
  reg [`MEM_ADDR_SIZE-7:0] tag[3:0];
  reg [`WORD_SIZE_BIT-1:0] block[3:0][3:0];
  
  
  reg [`MEM_ADDR_SIZE-1:0] addr2mem_reg[3:0];
  reg [`MEM_ADDR_SIZE-1:0] addrrdmem_reg[3:0];
  reg [`WORD_SIZE_BIT-1:0] data2mem_reg[3:0];
  reg [4:0] counter_send, counter_read, receiver_counter;
  reg block_transmission_done;

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
      if (cpuRead == 1'b1) begin  //read case
        if (valid[cpuAddr[5:4]] == 1'b0 | tag[cpuAddr[5:4]] != cpuAddr[`MEM_ADDR_SIZE-1:6]) begin  // miss
          if (dirty[cpuAddr[5:4]] == 1'b1) begin  //dirty
            if (counter_send == 0) begin
                counter_send = 4;
                addr2mem_reg[0] = {tag[cpuAddr[5:4]], cpuAddr[5:4], 4'b0000};
                data2mem_reg[0] = block[cpuAddr[5:4]][0];
                addr2mem_reg[1]  = {tag[cpuAddr[5:4]], cpuAddr[5:4], 4'b0100};
                data2mem_reg[1] = block[cpuAddr[5:4]][1];
                addr2mem_reg[2]  = {tag[cpuAddr[5:4]], cpuAddr[5:4], 4'b1000};
                data2mem_reg[2] = block[cpuAddr[5:4]][2];
                addr2mem_reg[3]  = {tag[cpuAddr[5:4]], cpuAddr[5:4], 4'b1100};
                data2mem_reg[3] = block[cpuAddr[5:4]][3];
            end
          end
          if (counter_read == 0) begin
            counter_read = 4;
            addrrdmem_reg[0]  = {cpuAddr[9:4], 4'b0000};
            addrrdmem_reg[1] = {cpuAddr[9:4], 4'b0100};
            addrrdmem_reg[2] = {cpuAddr[9:4], 4'b1000};
            addrrdmem_reg[3] = {cpuAddr[9:4], 4'b1100};
          end
        end
        else begin  //hit
          if (cpuAddr[3:2] == 2'b00) begin
            rData = block[cpuAddr[5:4]][0];
          end else if (cpuAddr[3:2] == 2'b01) begin
            rData = block[cpuAddr[5:4]][1];
          end else if (cpuAddr[3:2] == 2'b10) begin
            rData = block[cpuAddr[5:4]][2];
          end else begin
            rData = block[cpuAddr[5:4]][3];
          end
          hit = 1'b1;
        end
      end else if (cpuWrite == 1'b1) begin  //write case
        if (valid[cpuAddr[5:4]] == 1'b0 | tag[cpuAddr[5:4]] != cpuAddr[`MEM_ADDR_SIZE-1:6]) begin  // miss
          if (dirty[cpuAddr[5:4]] == 1'b1) begin  //dirty
            if (counter_send == 0) begin
                counter_send = 4;
                addr2mem_reg[0] = {tag[cpuAddr[5:4]], cpuAddr[5:4], 4'b0000};
                data2mem_reg[0] = block[cpuAddr[5:4]][0];
                addr2mem_reg[1]  = {tag[cpuAddr[5:4]], cpuAddr[5:4], 4'b0100};
                data2mem_reg[1] = block[cpuAddr[5:4]][1];
                addr2mem_reg[2]  = {tag[cpuAddr[5:4]], cpuAddr[5:4], 4'b1000};
                data2mem_reg[2] = block[cpuAddr[5:4]][2];
                addr2mem_reg[3]  = {tag[cpuAddr[5:4]], cpuAddr[5:4], 4'b1100};
                data2mem_reg[3] = block[cpuAddr[5:4]][3];
            end
          end
          if (counter_read == 0) begin
            counter_read = 4;
            addrrdmem_reg[0]  = {cpuAddr[9:4], 4'b0000};
            addrrdmem_reg[1] = {cpuAddr[9:4], 4'b0100};
            addrrdmem_reg[2] = {cpuAddr[9:4], 4'b1000};
            addrrdmem_reg[3] = {cpuAddr[9:4], 4'b1100};
          end
        end
        else begin  //hit
          valid[cpuAddr[5:4]] = 1'b1;
          dirty[cpuAddr[5:4]] = 1'b1;
          tag[cpuAddr[5:4]]   = cpuAddr[`MEM_ADDR_SIZE-1:6];
          if (cpuAddr[3:2] == 2'b00) begin
            block[cpuAddr[5:4]][0] = cpuData;
          end else if (cpuAddr[3:2] == 2'b01) begin
            block[cpuAddr[5:4]][1] = cpuData;
          end else if (cpuAddr[3:2] == 2'b10) begin
            block[cpuAddr[5:4]][2] = cpuData;
          end else begin
            block[cpuAddr[5:4]][3] = cpuData;
          end
          hit = 1'b1;
        end
      end
  end

    //always @(done_sender or write_receiver or read_receiver or addr2mem_reg or addrrdmem_reg or data2mem_reg) begin// no memData
    always @(posedge clock) begin
        if (write_receiver) begin
            block[cpuAddr[5:4]][receiver_counter] = memData;
            if (receiver_counter == 3) begin
                block_transmission_done = 1;
                receiver_counter = 0;
                tag[cpuAddr[5:4]] = cpuAddr[`MEM_ADDR_SIZE-1:6];
                valid[cpuAddr[5:4]] = 1'b1;
                dirty[cpuAddr[5:4]] = 1'b0;
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
