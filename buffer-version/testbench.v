
module testbench;
  parameter half_period = 10;
  integer i = 1;
  reg clock;
  reg reset = 0;
  top t (clock,reset);

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, testbench);
    // $dumpvars(0, testbench.top.data_mem);

    #0 clock = 1;
    #15000 $finish;
  end

  integer j = 0;
  always #half_period begin
    clock = ~clock;
`ifdef CONCISE
    for (j = 0; j <= 63; j = j + 1) begin
      $write("%d", t.u_data_mem.memory[j]);
    end
    $write("\n");
`else
    $display("==========================================================");
    $display("Time: %d ns", i);
    for (j = 0; j <= 63; j = j + 4) begin
      $display("memory[%d] = %d, memory[%d] = %d, memory[%d] = %d, memory[%d] = %d", j,
               t.u_data_mem.memory[j], j + 1, t.u_data_mem.memory[j+1], j + 2,
               t.u_data_mem.memory[j+2], j + 3, t.u_data_mem.memory[j+3]);
    end
    $display("==========================================================");
    $display(
        "tag[0] = %b,| dirty[0] = %b,| block[0][0] = %d block[0][1] = %d block[0][2] = %d block[0][3] = %d",
        t.u_cache.tag[0], t.u_cache.dirty[0], t.u_cache.block[0][0], t.u_cache.block[0][1],
        t.u_cache.block[0][2], t.u_cache.block[0][3]);
    $display(
        "tag[1] = %b,| dirty[1] = %b,| block[1][0] = %d block[1][1] = %d block[1][2] = %d block[1][3] = %d",
        t.u_cache.tag[1], t.u_cache.dirty[1], t.u_cache.block[1][0], t.u_cache.block[1][1],
        t.u_cache.block[1][2], t.u_cache.block[1][3]);
    $display(
        "tag[2] = %b,| dirty[2] = %b,| block[2][0] = %d block[2][1] = %d block[2][2] = %d block[2][3] = %d",
        t.u_cache.tag[2], t.u_cache.dirty[2], t.u_cache.block[2][0], t.u_cache.block[2][1],
        t.u_cache.block[2][2], t.u_cache.block[2][3]);
    $display(
        "tag[3] = %b,| dirty[3] = %b,| block[3][0] = %d block[3][1] = %d block[3][2] = %d block[3][3] = %d",
        t.u_cache.tag[3], t.u_cache.dirty[3], t.u_cache.block[3][0], t.u_cache.block[3][1],
        t.u_cache.block[3][2], t.u_cache.block[3][3]);
`endif
    i = i + 1;
  end

endmodule
