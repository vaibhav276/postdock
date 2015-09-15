#!/bin/bash
sudo touch $PGROOT/logfile
sudo chown docker:docker $PGROOT/logfile
pg_ctl -D $PGROOT/data -l $PGROOT/logfile start
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope #enable attaching from debugger

# Just stay alive!
while true;
   do sleep 1;
done;
