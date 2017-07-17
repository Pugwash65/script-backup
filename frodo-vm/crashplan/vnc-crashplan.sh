#!/bin/sh

PWFILE=${HOME}/.vnc/passwd

if [ ! -f ${PWFILE} ]; then
   x11vnc -storepasswd
fi

if [ `/usr/bin/pgrep -c Xvfb` = 0 ]; then
   echo "Starting Xvfb"
   Xvfb :2 -screen 0 1024x768x16 &
fi

export DISPLAY=:2

if [ `/usr/bin/pgrep -c -f CPDesktop` = 0 ]; then
   echo "Starting CrashPlanDesktop"
   CrashPlanDesktop
fi

if [ `/usr/bin/pgrep -c x11vnc` = 0 ]; then
   x11vnc -display :2 -bg -usepw
fi
