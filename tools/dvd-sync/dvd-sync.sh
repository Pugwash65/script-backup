#!/bin/bash

hostname=`/bin/uname -n`

case ${hostname} in

darnel-hurst)
  SRC_BASE='/media/sf_FullDisc'
  ;;
thorin)
  SRC_BASE='/home/private/00_Temp_DVD'
  ;;
*)
  echo "${hostname}: Unknown host"
  exit 1
esac

DST_DIR='/data/Multimedia/Videos/00_Temp_DVD'

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

if [ ! -d "${srcdir}/VIDEO_TS" ]; then
   echo "${srcdir}: VIDEO_TS Directory does not exist"
   echo "Check what you are doing carefully"
   exit 1
fi

mp4=`/bin/ls ${dstdir}/${dvd_folder}/*.mp4 2>/dev/null`
if [ ! -z "${mp4}" ]; then
   echo "${dstdir}/${dvd_folder}: Contains mp4 files"
   echo "Check what you are doing carefully"
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

time /usr/bin/rsync -av --delete --exclude .@__thumb --progress "${srcdir}" "${dstdir}"

if [ $? != 0 ]; then
   echo "Sync failed"
   exit 1
fi

exit 0

