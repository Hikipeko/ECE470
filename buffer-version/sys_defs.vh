// how to use?
// `include"sys_defs.vh" at the begining of the file
// add the sign ` before each call of the variables
//e.g. assign a = `WORD_SIZE_BIT or reg [`WORD_SIZE_BIT:0]


`ifndef _sys_defs_vh
`define _sys_defs_vh



`define WORD_SIZE_BIT 32 //32 bit per word


//Memory parameters
`define MEM_SIZE_WORD 64 //words in memory
`define MEM_ADDR_SIZE 8 //log2(MEM_SIZE*WORD_SIZE/8) data size of each memory address
//need to be byte addressable

// cache `defines
// Cache associativity: Direct mapped!!!!!!!!!!!!!!!!
//Cache replacement policy: Least Recently Used (LRU)
`define WORD_PER_BLOCK 8 //word per block
`define CACHE_SIZE_WORD 16 //total words in cache


`define BLOCK_PER_CACHE (`CACHE_SIZE_WORD/`WORD_PER_BLOCK)
`define WORD_PER_BLOCK_ADDR_SIZE ($clog2(`WORD_PER_BLOCK))
`define BLOCK_PER_CACHE_ADDR_SIZE ($clog2(`BLOCK_PER_CACHE))


//write data bus bandwidth in bit
`define BANDWIDTH_WRITE_DATA 12

//write address bus bandwidth in bit
`define BANDWIDTH_WRITE_ADDRESS 12

//read data bus bandwidth in bit
`define BANDWIDTH_READ_DATA 12

//read address bus bandwidth in bit
`define BANDWIDTH_READ_ADDRESS 12


//bus delay in cycles
`define BUS_DELAY 4


//delay between request and receive in data mem
`define MEM_DELAY #100
`define MEM_DELAY_REG 5

`define INSTR_NUM 30
`endif

