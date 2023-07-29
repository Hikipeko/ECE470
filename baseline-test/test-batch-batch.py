#!/usr/bin/env python3

# automate testing process for all parameters & benchmarks

import subprocess

runs = 40
block_caches = [(2,8),(4,8),(2,16),(4,16),(8,16)]
benchmarks = [('mcf', 0.306, 0.086), ('lbm', 0.263, 0.085), \
              ('soplex', 0.389, 0.075), ('milc', 0.373, 0.107), \
                ('oment', 0.342, 0.179), ('bwaves', 0.465, 0.085), \
                    ('gcc', 0.256, 0.131), ('libquantum', 0.144, 0.05), \
                        ('sphinx', 0.304, 0.03), ('gems', 0.451, 0.1)]


def calculate_average(numbers):
    total = sum(numbers)
    return total / len(numbers)


# clear file
total = len(block_caches) * (benchmarks)
i = 0

with open("final_result.txt", 'w') as out_file:
    for b_c in block_caches:
        for bm in benchmarks:
            script = f"./test-batch.sh {runs} {b_c[0]} {b_c[1]} {bm[1]} {bm[2]}"
            result = subprocess.run(script, shell=True, capture_output=True, text=True, check=True)
            if result.returncode == 0:
                # append result to a file
                baseline_cycle = None
                buffer_cycle = None
                with open("baseline_cycle.out", 'r') as ifile1:
                    numbers = [int(line.strip()) for line in ifile1]
                    baseline_cycle = calculate_average(numbers)
                with open("buffer_cycle.out", 'r') as ifile2:
                    numbers = [int(line.strip()) for line in ifile2]
                    buffer_cycle = calculate_average(numbers)
                to_write = f"(block, cache):\t{b_c}, benchmark:\t{bm}\tbaseline_cycle:\t{baseline_cycle:.2f}\tbuffer_cycle:\t{buffer_cycle:.2f}\tspeed_up:{baseline_cycle/buffer_cycle:.2f}\n"
                out_file.write(to_write)
                print(to_write)
            else:
                print("Shell script failed. Error message:")
                print(result.stderr)

