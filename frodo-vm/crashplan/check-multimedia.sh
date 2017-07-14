#!/bin/sh
#
# Install: /usr/local/lib/check-multimedia.sh
#

DIR=/data/Multimedia
TARGET=192.168.1.8:/Multimedia

/bin/ls ${DIR} >/dev/null 2>&1

t=`/bin/df ${DIR} | /bin/tail -n +2 | /bin/awk '{print $1}'`

if [ "${t}" = ${TARGET} ]; then
   exit 0
else
   echo "${TARGET}: Not mounted - check autofs"
   exit 1
fi
