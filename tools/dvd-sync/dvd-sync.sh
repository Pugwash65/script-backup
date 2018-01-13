#!/bin/bash

DST_DIR='/data/Multimedia/Videos/00_Raw_DVD'
SRC_DIR='/media/sf_Shared/dvd/'

dstdir=${DST_DIR}
srcdir=${SRC_DIR}

if [ ! -d "${dstdir}" ]; then
   echo "${dstdir}: Directory does not exist"
   exit 1
fi

echo ""
echo "Ready to sync ${srcdir} to ${dstdir}?"

echo ""
echo -n "Press any key to continue..."
read -n 1 -s
echo ""

time /usr/bin/rsync -av --progress "${srcdir}" "${dstdir}"

if [ $? != 0 ]; then
   echo "Sync failed"
   exit 1
fi

exit 0

