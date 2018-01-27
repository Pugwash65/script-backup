#!/bin/bash

hostname=`/bin/uname -n`

case ${hostname} in

frodo-vm)
  DEFAULT_DIR='/data/Multimedia/Videos/00_Temp_DVD'
  DVDDEV=/dev/sr1
  /bin/ls /misc/cd > /dev/null
  if [ $? != 0 ]; then
     echo "Unable to automount DVD"
     exit 1
  fi
  ;;
darnel-hurst)
  #DEFAULT_DIR='/media/sf_Shared/dvd'
  DEFAULT_DIR='/media/sf_FullDisc'
  DVDDEV=/dev/sr0
  ;;
thorin)
  DEFAULT_DIR='/data/private/00_Temp_DVD'
  DVDDEV=/dev/sr0
  ;;
*)
  echo "${hostname}: Unknown host"
  exit 1
esac

case "$#" in
0)
   dstdir=${DEFAULT_DIR}
   ;;
1)
   dstdir=${1}	
   ;;
*)
   echo "Usage: [output-dir]"
   exit 1
esac

if [ ! -d "${dstdir}" ]; then
   echo "${dstdir}: Directory does not exist"
   exit 1
fi

dvdcheck=`/bin/df | /bin/grep -c ${DVDDEV}`

if [ "x${dvdcheck}" = "x0" ]; then 
   echo "${DVDDEV}: Not mounted - check dvd passthrough"
   exit 1
fi

dvddir=`/bin/df ${DVDDEV} | /bin/tail -n 1 | /bin/sed -e 's/^\([^ ]* *\)\{5\}//'`

#dvdname=`/bin/basename "${dvddir}"`

dvdinfo=`/usr/sbin/blkid ${DVDDEV}`
if [ "x${dvdinfo}" = "x" ]; then
   echo "Unable to find DVD label"
   exit 1
fi

dvdname=`echo ${dvdinfo} | /bin/awk '{print $3}' | /bin/awk -F= '{print $2}'`

if [ "x${dvdname}" = "x" ]; then
   echo "Unable to extract DVD name"
   exit 1
fi

echo ""
echo "Ready to copy ${dvdname} to ${dstdir}?"

echo ""
echo -n "Press any key to continue..."
read -n 1 -s
echo ""

time /usr/bin/vobcopy -m -i "${dvddir}" -o "${dstdir}"

if [ $? != 0 ]; then
   echo "Copy failed"
   exit 1
fi

exit 0

