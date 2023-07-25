#!/usr/bin/env bash

./gen-test-new.py --write-back
pwd=$(pwd)
baseline_testdir="./temp-baseline"
writebuf_testdir="./temp-writebuf"
cd $baseline_testdir
sed -i '1s/^/`define CONCISE\n/' testbench.v
iverilog testbench.v -o testbench && ./testbench > output
# cat output | uniq | sed '$d' | sed '$d' > output-processed
tail -1 output > mem.out
tail -2 output > temp.out
head -1 temp.out >> ../baseline_cycle.out
cd "$pwd"
cd "$writebuf_testdir"
sed -i '1s/^/`define CONCISE\n/' testbench.v
iverilog testbench.v -o testbench && ./testbench > output
# cat output | uniq | sed '$d' | sed '$d' > output-processed
tail -1 output > mem.out
tail -2 output > temp.out
head -1 temp.out >> ../buffer_cycle.out
cd "$pwd"
# echo "begin diff....."
# echo "======================================"
# baseline_file="$baseline_testdir/output-processed"
# buffer_file="$writebuf_testdir/output-processed"
baseline_file="$baseline_testdir/mem.out"
buffer_file="$writebuf_testdir/mem.out"
mem_file="mem.out"
if diff -q "$baseline_file" "$buffer_file" >/dev/null; then
    if diff -q "$buffer_file" "$mem_file" >/dev/null; then
        echo "pass !!!"
        exit 0
    else
        echo "The files are different:"
        diff "$buffer_file" "$mem_file"
        exit 2
    fi
else
    echo "The files are different:"
    diff "$baseline_file" "$buffer_file"
    exit 1
fi
