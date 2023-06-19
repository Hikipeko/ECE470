// how to use?
// `include"sys_defs.vh" at the begining of the file
// add the sign ` before each call of the variables
//e.g. assign a = `WORD_SIZE_BIT or reg [`WORD_SIZE_BIT:0]


`ifndef _sys_defs_vh
`define _sys_defs_vh



`define WORD_SIZE_BIT 32 //32 bit per word


//Memory parameters
`define MEM_SIZE_WORD 256 //words in memory
`define MEM_ADDR_SIZE 10 //log2(MEM_SIZE*WORD_SIZE/8) data size of each memory address
//need to be byte addressable

// cache `defines
// Cache associativity: Direct mapped!!!!!!!!!!!!!!!!
//Cache replacement policy: Least Recently Used (LRU)
`define CACHE_BLOCK_SIZE 1 //worda per block
`define CACHE_SIZE_WORD 8 //total words in cache


//write data bus bandwidth in bit
`define BANDWIDTH_WRITE_DATA 8

//write address bus bandwidth in bit
`define BANDWIDTH_WRITE_ADDRESS 8

//read data bus bandwidth in bit
`define BANDWIDTH_READ_DATA 8

//read address bus bandwidth in bit
`define BANDWIDTH_READ_ADDRESS 8


//bus delay in cycles
`define BUS_DELAY 8


//delay between request and receive in data mem
`define MEM_DELAY #100
`endif

