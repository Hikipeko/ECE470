#!/usr/bin/env zsh

./gen-test.py --write-back
pwd=$(pwd)
baseline_testdir="./temp-baseline"
writebuf_testdir="./temp-writebuf"
cd $baseline_testdir
sed -i '1s/^/`define CONCISE\n/' testbench.v
iverilog testbench.v -o testbench && ./testbench | uniq | sed '$d' | sed '$d' > output
cd $pwd
cd $writebuf_testdir
sed -i '1s/^/`define CONCISE\n/' testbench.v
iverilog -Wtimescale testbench.v -o testbench && ./testbench | uniq | sed '$d' | sed '$d' > output
cd $pwd
echo "begin diff....."
echo "======================================"
file1="$baseline_testdir/output"
file2="$writebuf_testdir/output"
if diff -q "$file1" "$file2" >/dev/null; then
    echo "pass !!!"
else
    echo "The files are different:"
    diff "$file1" "$file2"
fi
