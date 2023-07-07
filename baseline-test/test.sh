#!/usr/bin/env zsh

./gen-test.py --write-back
pwd=$(pwd)
baseline_testdir="./temp-baseline"
writebuf_testdir="./temp-writebuf"
cd $baseline_testdir
iverilog testbench.v -o testbench && ./testbench > output
cd $pwd
cd $writebuf_testdir
iverilog testbench.v -o testbench && ./testbench > output
