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

## baseline
``` sh
cd baseline
iverilog testbench.v -o testbench && ./testbench
```