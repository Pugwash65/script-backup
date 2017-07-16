#!/bin/sh

export LD_LIBRARY_PATH=/share/Multimedia/HB/deb/usr/lib/x86_64-linux-gnu

HANDBRAKE=/share/Multimedia/HB/deb/usr/bin/HandBrakeCLI

OUT=$1

if [ "x${OUT}" = "x" ]; then
   echo "Output file?"
   exit 1
fi


TITLE=1
SUBTITLE=1
CHAPTERS=
#CHAPTERS="-c 1-4"

${HANDBRAKE} -i VIDEO_TS -Z "High Profile" -t ${TITLE} -o ${OUT} -s ${SUBTITILE} -c ${CHAPTERS}

exit $?

