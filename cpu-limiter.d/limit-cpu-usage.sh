#!/usr/bin/env bash
# SCRIPT: limit-cpu-usage.sh 
# AUTHOR: ...
# DATE: 2025-02-05T11:06:21
# REV: 1.0
# ARGUMENTS: [1: percentage of cpu limit ][2: sleep time between each check in seconds ][3:		][4:        ]
#
# PURPOSE: If a process cpu usage exceeds the limit it will set the limit using the `cpulimit` command
#
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution
# set -e # Break on the first failure

pids_list=()

# cpu limit in percentage
lim=${1:-90}
sleep_time=${2:-3} # In seconds

echo "Lim: '${lim}%'; Delay: ${sleep_time}"
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
   if [ -z "$pid" ] || pid_exists "$pid"; then
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
 sleep ${sleep_time:-5}
done
