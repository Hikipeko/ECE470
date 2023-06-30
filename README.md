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

## baseline with iverilog
``` sh
cd baseline
iverilog testbench.v -o testbench && ./testbench
```

## baseline with vivado
``` sh
mkdir -p baseline/sim
cd baseline/sim
xvlog ../cache.v ../cache_write_through.v ../cpu.v ../data_mem.v ../testbench.v ../top.v  ../sys_defs.vh
xelab -debug typical -top testbench -snapshot testbench_snapshot
xsim testbench_snapshot -R
```
