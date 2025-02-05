#!/usr/bin/env bash
# SCRIPT: restart.sh 
# AUTHOR: ...
# DATE: 2025-02-05T11:06:21
# REV: 1.0
# ARGUMENTS: [1:        ][2:		][3:		][4:        ]
#
# PURPOSE: Re-starts cpu limiter
#
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution
# set -e # Break on the first failure

pid_file=~/.cpu-limit.pid
touch ${pid_file}

pid=$(cat ${pid_file})
echo -n "OLD PID: '${pid}'"
./_stop.sh "${pid}" &>/dev/null && \
	echo -en "; Stopped.\n" || \
	echo -en "; couln't be stopped. Job might not exists anymore.\n"

log=/tmp/cpu-limiter.log
> $log
nohup ./limit-cpu-usage.sh >$log 2>&2 &
echo -n "$!" > ${pid_file}
echo "NEW PID: '$(cat ${pid_file})'"
