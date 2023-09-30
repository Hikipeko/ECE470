`include "sys_defs.vh"
`define DIFF
module testbench;
  parameter half_period = 10;
  integer cycle = 1;
  reg clock;
  reg reset = 0;
  top t (
      clock,
      reset
  );

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, testbench);
    #0 clock = 1;
    reset = 1;
    #20 
    reset = 0;
    #(`INSTR_NUM * 10000)
      repeat (`BLOCK_PER_CACHE) begin
        if (t.u_cache.dirty[j_loop]) begin
          k_loop = 0;
          repeat (`WORD_PER_BLOCK) begin
            t.u_data_mem.memory[{
              t.u_cache.tag[j_loop], j_loop, k_loop
            }] = t.u_cache.block[j_loop][k_loop];
            k_loop = k_loop + 1;
          end
        end
        j_loop = j_loop + 1;
      end
    for (i = 0; i < `MEM_SIZE_WORD; i = i + 1) begin
      $write("%4d ", t.u_data_mem.memory[i]);
    end
    $write("\n");
    $finish;
  end

  integer i = 0;//iterator for `MEM_SIZE_WORD
  integer j = 0;//iterator for `WORD_PER_BLOCK
  integer k = 0;//iterator for `BLOCK_PER_CACHE
  reg [`BLOCK_PER_CACHE_ADDR_SIZE-1:0] j_loop = 0;
  reg [`WORD_PER_BLOCK_ADDR_SIZE-1:0] k_loop = 0;
  reg finishFlag = 0;

  `ifdef DIFF
  reg valid[`BLOCK_PER_CACHE-1:0];
  reg dirty[`BLOCK_PER_CACHE-1:0];
  reg [(`MEM_ADDR_SIZE-2-`WORD_PER_BLOCK_ADDR_SIZE-`BLOCK_PER_CACHE_ADDR_SIZE):0] tag[`BLOCK_PER_CACHE-1:0];
  reg [`WORD_SIZE_BIT-1:0] block[`BLOCK_PER_CACHE-1:0][`WORD_PER_BLOCK-1:0];
  reg [`WORD_SIZE_BIT-1:0] memory[`MEM_SIZE_WORD-1:0];
  reg diffFlag = 0;

  initial begin
    for (k = 0; k < `BLOCK_PER_CACHE; k = k + 1) begin
      valid[k] = 0;
      dirty[k] = 0;
    end
    for (k = 0; k < `BLOCK_PER_CACHE; k = k + 1) begin
      tag[k] = 0;
      for (j = 0; j < `WORD_PER_BLOCK; j = j + 1) begin
        block[k][j] = 0;
      end
    end
    for (i = 0; i < `MEM_SIZE_WORD; i = i + 1) begin
      memory[i] = i;
    end
  end
  `endif

  always #10 begin
    clock = ~clock;
    if (finishFlag == 0) begin
      `ifdef CONCISE
      for (i = 0; i < `MEM_SIZE_WORD; i = i + 1) begin
        $write("%4d ", t.u_data_mem.memory[i]);
      end
      $write("\n");
      for (k = 0; k < `BLOCK_PER_CACHE; k = k + 1) begin
        $write("%1b %1b ", t.u_cache.tag[k], t.u_cache.dirty[k]);
        for (j = 0; j < `WORD_PER_BLOCK; j = j + 1) begin
          $write("%1d ", t.u_cache.block[k][j]);
        end
        $write("\n");
      end
      `endif

      `ifdef VERBOSE
      $write("==========================================================\n");
      $write("Cycle: %d\n", cycle);
      for (i = 0; i < `MEM_SIZE_WORD; i = i + 1) begin
        $write("mem[%3d] = %4d\t", i, t.u_data_mem.memory[i]);
      end
      $write("\n==========================================================\n");
      for (k = 0; k < `BLOCK_PER_CACHE; k = k + 1) begin
        $write("tag[%1d] = %1b | dirty[%1d] = %1b | ", k, t.u_cache.tag[k], k, t.u_cache.dirty[k]);
        for (j = 0; j < `WORD_PER_BLOCK; j = j + 1) begin
          $write("block[%1d][%1d] = %4d | ", k, j, t.u_cache.block[k][j]);
        end
        $write("\n");
      end
      `endif

      `ifdef DIFF
      diffFlag = 0;
      for (i = 0; i < `MEM_SIZE_WORD; i = i + 1) begin
        if (memory[i] != t.u_data_mem.memory[i]) begin
          $write("mem[%3d] = %4d | ", i, t.u_data_mem.memory[i]);
          diffFlag = 1;
        end
        memory[i] = t.u_data_mem.memory[i];
      end
      for (k = 0; k < `BLOCK_PER_CACHE; k = k + 1) begin
        if (tag[k] != t.u_cache.tag[k] | dirty[k] != t.u_cache.dirty[k]) begin
          $write("tag[%1d] = %4b | dirty[%1d] = %1b | ", k, t.u_cache.tag[k], k,
                 t.u_cache.dirty[k]);
          tag[k]   = t.u_cache.tag[k];
          dirty[k] = t.u_cache.dirty[k];
          diffFlag = 1;
        end
        for (j = 0; j < `WORD_PER_BLOCK; j = j + 1) begin
          if (block[k][j] != t.u_cache.block[k][j]) begin
            $write("block[%1d][%1d] = %1d | ", k, j, t.u_cache.block[k][j]);
            block[k][j] = t.u_cache.block[k][j];
            diffFlag = 1;
          end
        end
      end
      if (diffFlag) begin
        $write("\n \t at cycle %4d\n", cycle);
      end
      `endif
      
      cycle = cycle + 1;
      if (t.u_cpu.finish == 1) begin
        $write("FINISH with memory at cycle:\n");
        $write("%4d\n", cycle);
        finishFlag = 1;
      end
    end
  end

endmodule
