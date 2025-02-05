# CPU-limit

This goes through all process id's and limits all to 100% (1 processor), 
if they are using more than 100%.

Use `./restart.sh` to start or restart the job in background using nohup.
Also you can use `./stop.sh` to stop the job 

# Cronjob
In your cronjob change the directory to the path of this directory and run the script `./crop-script.sh`.:

```bash
*/30 * * * * cd <path>/cpu-limiter.d && ./cron-script.sh >/tmp/cron-cpu-limiter.log 2>&1
```
