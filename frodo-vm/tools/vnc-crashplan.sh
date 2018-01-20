#!/bin/sh

~/bin/vnc-x11.sh

export DISPLAY=:2

if [ `/usr/bin/pgrep -c -f CPDesktop` = 0 ]; then
   echo "Starting CrashPlanDesktop"
   CrashPlanDesktop
fi

