#!/usr/bin/env python3
import os
import random
import shutil
import argparse
import math

LOAD_PROPORTION = .451
STORE_PROPORTION = .1

# Macro defines
WORD_SIZE_BIT = 32 # 32 bit per word
MEM_SIZE_WORD = 64 # number of words in memory

WORD_PER_BLOCK = 8 # number of words in a block
CACHE_SIZE_WORD = 32 # number of words in the cache

BUS_WIDTH = 12 # all kind of bus width
MEM_DELAY_REG = 5 # cycle it takes for memory to respond
INSTR_NUM = 64 # number of instructions

BANDWIDTH_WRITE_DATA = BUS_WIDTH
BANDWIDTH_WRITE_ADDRESS = BUS_WIDTH
BANDWIDTH_READ_DATA = BUS_WIDTH
BANDWIDTH_READ_ADDRESS = BUS_WIDTH
MEM_ADDR_SIZE = int(math.log(MEM_SIZE_WORD,2)) + 2 # data size of a memory address
BLOCK_PER_CACHE = int(CACHE_SIZE_WORD/WORD_PER_BLOCK) # number of blocks in the cache
WORD_PER_BLOCK_ADDR_SIZE = int(math.log(WORD_PER_BLOCK,2)) # data size of a WORD_PER_BLOCK
BLOCK_PER_CACHE_ADDR_SIZE = int(math.log(BLOCK_PER_CACHE,2)) # data size of a BLOCK_PER_CACHE

BANDWIDTH_MULTIPLE = ((WORD_SIZE_BIT+MEM_ADDR_SIZE) % BANDWIDTH_WRITE_ADDRESS == 0) # needed to resolve a bit length error in sender
# BUS_DELAY = 4
# MEM_DELAY = "#100"

# Generate macro file
sys_defs = f'''
`define WORD_SIZE_BIT {WORD_SIZE_BIT}
`define MEM_SIZE_WORD {MEM_SIZE_WORD}
`define MEM_ADDR_SIZE {MEM_ADDR_SIZE}
`define WORD_PER_BLOCK {WORD_PER_BLOCK}
`define CACHE_SIZE_WORD {CACHE_SIZE_WORD}
`define BLOCK_PER_CACHE {BLOCK_PER_CACHE}
`define WORD_PER_BLOCK_ADDR_SIZE {WORD_PER_BLOCK_ADDR_SIZE}
`define BLOCK_PER_CACHE_ADDR_SIZE {BLOCK_PER_CACHE_ADDR_SIZE}
`define BANDWIDTH_WRITE_DATA {BANDWIDTH_WRITE_DATA}
`define BANDWIDTH_WRITE_ADDRESS {BANDWIDTH_WRITE_ADDRESS}
`define BANDWIDTH_READ_DATA {BANDWIDTH_READ_DATA}
`define BANDWIDTH_READ_ADDRESS {BANDWIDTH_READ_ADDRESS}

`define MEM_DELAY_REG {MEM_DELAY_REG}
`define INSTR_NUM {INSTR_NUM}
'''
if (BANDWIDTH_MULTIPLE == 1):
    sys_defs += f'''`define BANDWIDTH_MULTIPLE'''


# Command line parse
parser = argparse.ArgumentParser(description='Process command line arguments.')
parser.add_argument('--write-back', action='store_true', help='Use write-back cache')
parser.add_argument('--write-through', action='store_true', help='Use write-through cache')
args = parser.parse_args()

cacheAddr = []
cacheAddrBin = []

# Generate random cache addresses
for i in range(0,INSTR_NUM):
    cacheAddr.append(random.randint(0,MEM_SIZE_WORD-1) * 4)
    cacheAddrBin.append(format(int(MEM_ADDR_SIZE)) + '\'b' + format(int(cacheAddr[i]), 'b').zfill(8))

# Generate module content
module_content = f'''`include "sys_defs.vh"
module cpu (
    input clock,
    input reset,
    input [`WORD_SIZE_BIT-1:0] rData,
    input hit,
    output [`MEM_ADDR_SIZE-1:0] Address,
    output [`WORD_SIZE_BIT-1:0] Write_Data,
    output wire read,
    output wire write,
    output wire finish
);

  reg [9:0] count;
  reg rEnable[`INSTR_NUM-1:0];
  reg wEnable[`INSTR_NUM-1:0];
  reg [`MEM_ADDR_SIZE-1:0] cacheAddr[`INSTR_NUM-1:0];
  reg [`WORD_SIZE_BIT-1:0] memData[`INSTR_NUM-1:0];

  initial begin
'''

# Generate initial memory state
memory = list(range(0,MEM_SIZE_WORD))
readData = []
readAddr = []
# Generate initial block content
for i in range(0, INSTR_NUM):
    # Generate random memData
    memData = random.randint(0, 999)
    random_float = random.random()
    # Create specific cache lines
    specific_cache_lines = f'''
    rEnable[{i}] = 1'b{1 if random_float < LOAD_PROPORTION else 0};
    wEnable[{i}] = 1'b{1 if random_float > 1 - STORE_PROPORTION else 0};
    cacheAddr[{i}] = {cacheAddrBin[i]};
    memData[{i}] = 'd{memData};'''
    module_content += specific_cache_lines
    if random_float > 1 - STORE_PROPORTION:
        memory[int(cacheAddr[i]/4)] = memData
    # elif (i % 4 != 0):
    #     readData.append(memory[i])
    #     readAddr.append(cacheAddr[i])
# open file in write mode
with open('mem.out', 'w') as file:
    for item in memory:
        # write each item on a new line
        file.write("%4d " % item)
    file.write("\n")
    
# Print correct output for memory
# print(*memory, sep = " ")
# print(*readData, sep = "\n")
# print(*readAddr, sep = "\n")
    
# Generate remaining module content
module_content += '''
    count = 0;
  end

  always @(posedge clock) begin
    if (hit || (read == 0 && write == 0)) count = count + 1;
    else count = count;
  end
  assign read = rEnable[count];
  assign write = wEnable[count];
  assign Address = cacheAddr[count];
  assign Write_Data = memData[count];
  assign finish = (count == `INSTR_NUM);
endmodule
'''

# make directories for testing
def make_clean(dir):
    if os.path.exists(dir):
        shutil.rmtree(dir)
    os.mkdir(dir)
    return

baseline_testdir = './temp-baseline'
writebuf_testdir = './temp-writebuf'
make_clean(baseline_testdir)
make_clean(writebuf_testdir)

with open(baseline_testdir + '/cpu.v', 'w') as file:
    file.write(module_content)

with open(baseline_testdir + '/sys_defs.vh', 'w') as file:
    file.write(sys_defs)

with open(writebuf_testdir + '/cpu.v', 'w') as file:
    file.write(module_content)

with open(writebuf_testdir + '/sys_defs.vh', 'w') as file:
    file.write(sys_defs)

# move other files to baseline_testdir
if args.write_through:
    files_to_move = ['cache_write_through.v', 'data_mem.v', 'testbench.v', 'top.v','sender.v','receiver.v']
else:
    files_to_move = ['cache.v', 'data_mem.v', 'testbench.v', 'top.v','sender.v','receiver.v']
for file in files_to_move:
    shutil.copy(f'../cache_with_sender_receiver/{file}', f'{baseline_testdir}/{file}')

# move other files to writebuf_testdir
files_to_move = ['cache.v', 'data_mem.v', 'testbench.v', 'top.v', 'sender.v', 'receiver.v', 'buffer.v']
# files_to_move = ['cache.v', 'data_mem.v', 'testbench.v', 'top.v', 'sender.v', 'receiver.v']
for file in files_to_move:
    shutil.copy(f'../buffer-version/{file}', f'{writebuf_testdir}/{file}')
    # shutil.copy(f'../cache_with_sender_receiver/{file}', f'{writebuf_testdir}/{file}')
