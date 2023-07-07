#!/usr/bin/env python3
import os
import random
import shutil
import argparse

parser = argparse.ArgumentParser(description='Process command line arguments.')
parser.add_argument('--write-back', action='store_true', help='Use write-back cache')
parser.add_argument('--write-through', action='store_true', help='Use write-through cache')
args = parser.parse_args()

# Generate random cache addresses
cacheAddr = ['10\'b00' + ''.join(random.choice('01') for _ in range(8)) for _ in range(10)]
# cacheAddr = [cacheAddr[i] + '_' + cacheAddr[i+1] + '_' + cacheAddr[i+4] + '_' + cacheAddr[i+5] for i in range(0, 10, 2)]

# Generate module content
module_content = f'''module cpu (
    input clock,
    input reset,
    input [31:0] rData,
    input hit,
    output [9:0] Address,
    output [31:0] Write_Data,
    output wire read,
    output wire write
);

  reg [3:0] count;
  reg rEnable[9:0];
  reg wEnable[9:0];
  reg [9:0] cacheAddr[9:0];
  reg [31:0] memData[9:0];

  initial begin
'''
# Generate initial block content
for i in range(0, 10):
    # Generate random memData
    memData = random.randint(0, 999)
    # Create specific cache lines
    specific_cache_lines = f'''
    rEnable[{i}] = 1'b{int(i%2 == 0)};
    wEnable[{i}] = 1'b{int(i%2 == 1)};
    cacheAddr[{i}] = {cacheAddr[i]};
    memData[{i}] = 'd{memData};'''
    module_content += specific_cache_lines

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
