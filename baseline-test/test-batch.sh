#!/usr/bin/env bash

runs=$1
rm baseline_cycle.out
rm buffer_cycle.out
for (( i=0; i<runs; i++ )); do
  ./test.sh
  if [ $? -ne 0 ]; then
      echo break at i = $i
      mkdir -p failure
      cp -r temp-baseline failure
      cp -r temp-writebuf failure
      timestamp=$(date +"%Y%m%d%H%M%S")
      zip -r "failure-$timestamp.zip" failure
      mv "failure-$timestamp.zip" failures
      break
  fi
done

# calculate average
baseline_cycle=$(awk '{ total += $1; count++ } END { print total/count }' baseline_cycle.out)
buffer_cycle=$(awk '{ total += $1; count++ } END { print total/count }' buffer_cycle.out)
echo "baseline_cycle: $baseline_cycle"
echo "buffer_cycle: $buffer_cycle"
