# directory structure


```
.
├── baseline			baseline model without buffers
│   ├── cache.v
│   ├── cpu.v
│   ├── data_mem.v
│   ├── sys_defs.vh
│   ├── testbench.v
│   └── top.v
└── README.md
```

# usage

## compiling baseline
### baseline with iverilog
``` sh
cd baseline
iverilog testbench.v -o testbench && ./testbench
```

### baseline with vivado
``` sh
mkdir -p baseline/sim
cd baseline/sim
xvlog ../cache.v ../cache_write_through.v ../cpu.v ../data_mem.v ../testbench.v ../top.v  ../sys_defs.vh
xelab -debug typical -top testbench -snapshot testbench_snapshot
xsim testbench_snapshot -R
```

## compare baseline with cache_with_sender_receiver

``` sh
cd baseline-test
# test 100 times.  upon failure, the files are compressed in failure-timestamp.zip
chmod u+x ./test-batch.sh
./test-batch.sh 100
```
