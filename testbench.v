`include "top.v"

module testbench;
  parameter half_period = 10;
  integer i = 1;
  reg clock;
  top t (clock);

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, testbench);
    // $dumpvars(0, testbench.top.data_mem);

    #0 clock = 0;
    #5000 $finish;
  end

  integer j = 0;
  always #half_period begin
    clock = ~clock;
    $display("==========================================================");
    $display("Time: %d ns", i);
    for (j = 0; j <= 63; j = j + 4) begin
      $display("memory[%d] = %d, memory[%d] = %d, memory[%d] = %d, memory[%d] = %d", j,
               t.u_data_mem.memory[j], j + 1, t.u_data_mem.memory[j+1], j + 2,
               t.u_data_mem.memory[j+2], j + 3, t.u_data_mem.memory[j+3]);
    end
    $display("==========================================================");
    $display(
        "tag[0] = %b,| dirty[0] = %b,| block0[0] = %d block0[1] = %d block0[2] = %d block0[3] = %d",
        t.u_cache.tag[0], t.u_cache.dirty[0], t.u_cache.block0[0], t.u_cache.block0[1],
        t.u_cache.block0[2], t.u_cache.block0[3]);
    $display(
        "tag[1] = %b,| dirty[1] = %b,| block1[0] = %d block1[1] = %d block1[2] = %d block1[3] = %d",
        t.u_cache.tag[1], t.u_cache.dirty[1], t.u_cache.block1[0], t.u_cache.block1[1],
        t.u_cache.block1[2], t.u_cache.block1[3]);
    $display(
        "tag[2] = %b,| dirty[2] = %b,| block2[0] = %d block2[1] = %d block2[2] = %d block2[3] = %d",
        t.u_cache.tag[2], t.u_cache.dirty[2], t.u_cache.block2[0], t.u_cache.block2[1],
        t.u_cache.block2[2], t.u_cache.block2[3]);
    $display(
        "tag[3] = %b,| dirty[3] = %b,| block3[0] = %d block3[1] = %d block3[2] = %d block3[3] = %d",
        t.u_cache.tag[3], t.u_cache.dirty[3], t.u_cache.block3[0], t.u_cache.block3[1],
        t.u_cache.block3[2], t.u_cache.block3[3]);
    i = i + 1;
  end

endmodule
