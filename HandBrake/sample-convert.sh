#!/bin/sh

export LD_LIBRARY_PATH=/share/Multimedia/HB/usr/lib

HANDBRAKE=/share/Multimedia/HB/usr/bin/HandBrakeCLI

OUT=$1

if [ "x${OUT}" = "x" ]; then
   echo "Output file?"
   exit 1
fi

if [ "x${2}" != "x" ]; then
   TITLE=${2}
else
   TITLE=1
fi

if [ "x${3}" != "x" ]; then
   SUBTITLE=${3}
else
   SUBTITLE=1
fi

if [ "x${4}" != "x" ]; then
   CHAPTERS="-c ${4}"
else
   CHAPTERS=
fi

${HANDBRAKE} -i VIDEO_TS -Z "High Profile" -t ${TITLE} -o ${OUT} -s ${SUBTITLE} ${CHAPTERS}

exit $?

