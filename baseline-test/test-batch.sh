#!/usr/bin/env zsh

runs=$1

for (( i=0; i<runs; i++ )); do
  ./test.sh
  if [ $? -ne 0 ]; then
      echo break at i = $i
      mkdir failure
      cp -r temp-baseline failure
      cp -r temp-writebuf failure
      timestamp=$(date +"%Y%m%d%H%M%S")
      zip -r "failure-$timestamp.zip" failure
      mv "failure-$timestamp.zip" failures
      break
  fi
done
