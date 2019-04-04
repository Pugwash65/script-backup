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

dst="${file}-kindle.${ext}"

${HANDBRAKE} -i "${src}" -Z "Very Fast 480p30" -m -o "${dst}" -s 1

exit $?
