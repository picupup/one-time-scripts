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

# cpu limit in percentage
lim=99
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
 
  cpu=$(echo $cpu | tr -dc '[0-9,.]' | cut -d ',' -f 1 | cut -d '.' -f 1)
  pid=$(echo -n $pid | tr -dc '[0-9]')
  if test ${cpu} -gt ${lim}; then
   if test -z "$pid" -o pid_exists "$pid"; then
     continue
   fi
   echo "limiting $pid $cpu%"
   cpulimit -p $pid -l ${lim} &
   pids_list+=($pid)
  fi
  
 done
}

while true; do
 limit
 echo "[$(date +'%FT%T')] sleeping"
 sleep 5
done
