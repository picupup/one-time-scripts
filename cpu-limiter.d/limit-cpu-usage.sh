#!/usr/bin/env bash
# SCRIPT: limit-cpu-usage.sh 
# AUTHOR: ...
# DATE: 2025-02-05T11:06:21
# REV: 1.0
# ARGUMENTS: [1:        ][2:		][3:		][4:        ]
#
# PURPOSE: limits cpu usage for all process using more than 100 %cpu
#
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution
# set -e # Break on the first failure

pids_list=()

function pid_exists () {
  for pid in "${pids_list[@]}"; do
    if [ "$pid" = "$1" ]; then
      return 0
    fi
  done
  return 1
}

function limit () {
 ps -aeo %cpu,pid | tail -n +2 | sort -k1 -nr | head | while read cpu pid; do
  # f = filter
  cpu=$(echo $cpu | tr -dc '[0-9,.]' | cut -d ',' -f 1 | cut -d '.' -f 1)
  if [ ${cpu} -gt 100 ]; then
   if [ pid_exists $pid ]; then
     continue
   fi
   echo "limiting $pid $cpu%"
   cpulimit -p $pid -l 100 &
   pids_list+=($pid)
  fi
 done
}

while true; do
 limit
 echo "[$(date +'%FT%T')] sleeping"
 sleep 5
done
