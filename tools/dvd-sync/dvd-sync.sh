#!/bin/bash

DST_DIR='/data/Multimedia/Videos/00_Temp_DVD'
SRC_BASE='/media/sf_FullDisc'

if [ $# != 1 ]; then
   echo "Usage: dvd-sync.sh <DVD Folder>"
   exit 1
fi

dvd_dir=$1
dvd_folder=`/bin/basename ${dvd_dir}`

dstdir=${DST_DIR}
srcdir=${SRC_BASE}/${dvd_folder}

if [ ! -d "${srcdir}" ]; then
   echo "${srcdir}: Directory does not exist"
   exit 1
fi

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

time /usr/bin/rsync -av --delete --progress "${srcdir}" "${dstdir}"

if [ $? != 0 ]; then
   echo "Sync failed"
   exit 1
fi

exit 0

