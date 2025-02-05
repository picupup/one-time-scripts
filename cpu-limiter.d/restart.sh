#!/usr/bin/env bash
# SCRIPT: restart.sh 
# AUTHOR: ...
# DATE: 2025-02-05T11:06:21
# REV: 1.0
# ARGUMENTS: [1:        ][2:		][3:		][4:        ]
#
# PURPOSE: restarts cpu limiter
#
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution
# set -e # Break on the first failure

pid_file=~/.cpu-limit.pid
touch ${pid_file}

function stop {
        local l_pid
        l_pid=${1}
        pkill -TERM -P "${l_pid}"
        kill -9 "${l_pid}"
}

pid=${pid_file}
echo -n "OLD PID: '${pid}'"
stop "${pid}" &>/dev/null && \
	echo -en "; Stopped.\n" || \
	echo -en "; couln't be stopped. Job might not exists anymore.\n"

nohup ./limit-cpu-usage.sh &>/tmp/limit-cpu.txt &
echo -n "$!" > ${pid_file}
echo "NEW PID: '$(cat ${pid_file})'"
