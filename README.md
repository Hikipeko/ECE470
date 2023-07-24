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
├── cache_with_sender_receiver	cache modified to have sender and receiver for comparison with the buffered version
│   ├── cache.v
│   ├── cache_write_through.v
│   ├── cpu.v
│   ├── data_mem.v
│   ├── receiver.v
│   ├── sender.v
│   ├── sys_defs.vh
│   ├── testbench.v
│   └── top.v
├── buffered version	cache with write buffer
│   ├── buffer.v
│   ├── cache.v
│   ├── cache_write_through.v
│   ├── cpu.v
│   ├── data_mem.v
│   ├── receiver.v
│   ├── sender.v
│   ├── sys_defs.vh
│   ├── testbench.v
│   └── top.v
├── baseline-test	directory for verification and testing 
│   ├── gen-test.py
│   ├── test.sh
│   └── test-batch.sh
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

## The three modes of testbenches

At the top of ``testbench.v``, modify the `` `define `` parameters to get three different kinds of output.
### CONCISE
```
   0    1   ...  62   63 
000 0 0 0 0 0 
000 0 4 5 627 7 
010 0 40 41 42 468 
001 0 28 29 30 31 
FINISH at cycle  622 with memory:
   0    1    2    3    4    5  627   ...   62   63 
```
### VERBOSE
```
Cycle:         621
mem[  0] =    0	mem[  1] =    1	...	mem[ 63] =   63	
==========================================================
tag[0] = 000 | dirty[0] = 0 | block[0][0] =    0 ... 

| block[3][3] =   31 | 
FINISH at cycle  622 with memory:
   0    1    2    3    4    5  627    ...   61   62   63 
```
### DIFF
```
......

tag[1] =  010 | dirty[1] = 0 | block[1][3] = 39 | 
 	 at cycle  551
tag[1] =  000 | dirty[1] = 0 | 
 	 at cycle  553
...
block[1][2] = 627 | block[1][3] = 7 | 
 	 at cycle  619
FINISH at cycle  622 with memory:
   0    1    2    3    4    5  627   ...   61   62   63 
```