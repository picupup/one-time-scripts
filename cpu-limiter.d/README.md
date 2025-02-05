# CPU-Limit

This script iterates through all process IDs and limits them to 100% CPU usage (one processor) if they exceed this threshold.

Use `./restart.sh` to start or restart the job in the background using `nohup`.  
You can also use `./stop.sh` to stop the job.

# Cron Job

To set up a cron job, change the working directory to this script's location and run `./cron-script.sh`:

```bash
*/30 * * * * cd <path>/cpu-limiter.d && ./cron-script.sh >/tmp/cron-cpu-limiter.log 2>&1
