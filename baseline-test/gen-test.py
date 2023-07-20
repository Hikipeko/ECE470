#!/usr/bin/env python3
import os
import random
import shutil
import argparse
import math

# Macro defines
WORD_SIZE_BIT = 32
MEM_SIZE_WORD = 64
MEM_ADDR_SIZE = math.log(MEM_SIZE_WORD,2) + 2
WORD_PER_BLOCK = 4
CACHE_SIZE_WORD = 16
BLOCK_PER_CACHE = CACHE_SIZE_WORD/WORD_PER_BLOCK
WORD_PER_BLOCK_ADDR_SIZE = math.log(WORD_PER_BLOCK,2)
BLOCK_PER_CACHE_ADDR_SIZE = math.log(BLOCK_PER_CACHE,2)
BANDWIDTH_WRITE_DATA = 12
BANDWIDTH_WRITE_ADDRESS = 12
BANDWIDTH_READ_DATA = 12
BANDWIDTH_READ_ADDRESS = 12
BUS_DELAY = 4
MEM_DELAY = 100
MEM_DELAY_REG = 5
INSTR_NUM = 10

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

  reg [4:0] count;
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
    # Create specific cache lines
    specific_cache_lines = f'''
    rEnable[{i}] = 1'b{int(i%2 == 0)};
    wEnable[{i}] = 1'b{int(i%2 == 1)};
    cacheAddr[{i}] = {cacheAddrBin[i]};
    memData[{i}] = 'd{memData};'''
    module_content += specific_cache_lines
    if (i % 2 == 1):
        memory[int(cacheAddr[i]/4)] = memData
    elif (i % 2 == 0):
        readData.append(memory[i])
        readAddr.append(cacheAddr[i])
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
    if (hit) count = count + 1;
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

with open(writebuf_testdir + '/cpu.v', 'w') as file:
    file.write(module_content)

# move other files to baseline_testdir
if args.write_through:
    files_to_move = ['cache_write_through.v', 'data_mem.v', 'testbench.v', 'top.v', 'sys_defs.vh']
else:
    files_to_move = ['cache.v', 'data_mem.v', 'testbench.v', 'top.v', 'sys_defs.vh']
for file in files_to_move:
    shutil.copy(f'../baseline/{file}', f'{baseline_testdir}/{file}')

# move other files to writebuf_testdir
files_to_move = ['cache.v', 'data_mem.v', 'testbench.v', 'top.v', 'sys_defs.vh', 'sender.v', 'receiver.v']
for file in files_to_move:
    shutil.copy(f'../cache_with_sender_receiver/{file}', f'{writebuf_testdir}/{file}')
