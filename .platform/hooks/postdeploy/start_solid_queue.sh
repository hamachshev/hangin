#!/bin/bash

cd /var/app/current
sudo touch ./solid_queue_log.log
sudo chmod 666 ./solid_queue_log.log
./bin/jobs > ./solid_queue_log.log 2>&1 & disown
# Optionally, you can print the process ID for debugging or reference
echo "Jobs script is running in the background with PID $!"
exit 0