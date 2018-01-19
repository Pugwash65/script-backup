#!/bin/bash

#DEFAULT_DIR='/data/Multimedia/Videos/00_Raw_DVD'
#DEFAULT_DIR='/media/sf_Shared/dvd'
DEFAULT_DIR='/media/sf_FullDisc'

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

dvddev=/dev/sr0
dvdcheck=`/bin/df | /bin/grep -c ${dvddev}`

if [ "x${dvdcheck}" = "x0" ]; then 
   echo "${dvddev}: Not mounted - check dvd passthrough"
   exit 1
fi

dvddir=`/bin/df ${dvddev} | /bin/tail -n 1 | /bin/sed -e 's/^\([^ ]* *\)\{5\}//'`
dvdname=`/bin/basename "${dvddir}"`

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

