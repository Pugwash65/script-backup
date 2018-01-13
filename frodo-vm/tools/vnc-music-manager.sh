#!/bin/sh

~/bin/vnc-x11.sh

export DISPLAY=:2

if [ `/usr/bin/pgrep -c -f google-musicmanager` = 0 ]; then
   echo "Starting Music Manager"
   google-musicmanager &
   # Run it again to start GUI from Window Manager Apps->Other
fi

echo "Set the DISPLAY...the start google-musicmanager again"
echo ""
echo "export DISPLAY=:2"
echo ""
