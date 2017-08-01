#!/bin/sh

DEBUG=0

BASE=/share/homes/Steve
export LD_LIBRARY_PATH=${BASE}/handbrake/usr/lib

HANDBRAKE=${BASE}/handbrake/usr/bin/HandBrakeCLI

if [ "x${1}" = "x" ]; then
   echo "Usage: <src-mp4>"
   exit 1
fi

src=${1}
ext="${src##*.}"
file="${src%.*}"

dst="${file}-encode.${ext}"

${HANDBRAKE} -i "${src}" -Z "High Profile" -m -o "${dst}" --non-anamorphic --keep-display-aspect -s 1

exit $?
