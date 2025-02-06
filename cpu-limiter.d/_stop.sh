#!/usr/bin/env bash
# SCRIPT: stop.sh
# AUTHOR: ...
# DATE: 2025-02-05T11:06:21
# REV: 1.0
# ARGUMENTS: [1: Process id   ][2:		][3:		][4:        ]
#
# PURPOSE: This stops the provided process id without any log
#
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution
# set -e # Break on the first failure

pid="${1:-""}"
if test -n "${pid}"; then
	pkill -TERM -P "${pid}" &>/dev/null
	kill -9 "${pid}" &>/dev/null
	pkill -f cpulimit
fi

