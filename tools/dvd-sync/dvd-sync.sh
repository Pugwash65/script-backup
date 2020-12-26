#!/bin/bash

hostname=`/bin/uname -n`

case ${hostname} in

darnel-hurst)
  SRC_BASE='/media/sf_FullDisc'
  DST_DIR='/data/Multimedia/Videos/00_Temp_DVD'
  ;;
thorin|thrain)
  SRC_BASE='/home/private/00_Temp_DVD'
  DST_DIR='Steve@frodo-vm:/data/Multimedia/Videos/00_Temp_DVD'
  ;;
*)
  echo "${hostname}: Unknown host"
  exit 1
esac


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

c=$(echo ${dstdir} | /bin/grep -c :)

if [ ${c} = 1 ]; then

   host=$(echo ${dstdir} | awk -F: '{print $1}')
   dir=$(echo ${dstdir} | awk -F: '{print $2}')

# FIX THIS
#   if [ ! -d "${dstdir}" ]; then
#      echo "${dstdir}: Directory does not exist"
#      exit 1
#   fi

   mp4=`ssh ${host} /bin/ls ${dir}/${dvd_folder} | grep -c mp4 2>/dev/null`
   if [ ${mp4} = 1 ]; then
      echo ""
      echo "${dstdir}/${dvd_folder}: Contains mp4 files"
      echo "Check what you are doing carefully"
      echo ""
      exit 1
   fi
else
   if [ ! -d "${dstdir}" ]; then
      echo "${dstdir}: Directory does not exist"
      exit 1
   fi

   mp4=`/bin/ls ${dstdir}/${dvd_folder}/*.mp4 2>/dev/null`
   if [ ! -z "${mp4}" ]; then
      echo ""
      echo "${dstdir}/${dvd_folder}: Contains mp4 files"
      echo "Check what you are doing carefully"
      echo ""
      exit 1
   fi
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

