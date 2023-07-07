#!/usr/bin/env zsh

./gen-test.py --write-back
pwd=$(pwd)
baseline_testdir="./temp-baseline"
writebuf_testdir="./temp-writebuf"
cd $baseline_testdir
sed -i '1s/^/`define CONCISE\n/' testbench.v
iverilog testbench.v -o testbench && ./testbench > output
cat output | uniq | sed '$d' | sed '$d' > output-processed
cd $pwd
cd $writebuf_testdir
sed -i '1s/^/`define CONCISE\n/' testbench.v
iverilog testbench.v -o testbench && ./testbench > output
cat output | uniq | sed '$d' | sed '$d' > output-processed
cd $pwd
# echo "begin diff....."
# echo "======================================"
file1="$baseline_testdir/output-processed"
file2="$writebuf_testdir/output-processed"
if diff -q "$file1" "$file2" >/dev/null; then
    echo "pass !!!"
    exit 0
else
    echo "The files are different:"
    diff "$file1" "$file2"
    exit 1
fi
