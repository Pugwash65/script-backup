#!/bin/bash

DEFAULT_DIR='/mnt/Videos/DVD Library/01 Raw DVD'

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

dvddir=`/bin/df /dev/sr0 | /bin/tail -n 1 | /bin/awk '{print $NF}'`
dvdname=`/bin/basename ${dvddir}`


echo ""
echo "Ready to copy ${dvdname} to ${dstdir}?"

echo ""
echo -n "Press any key to continue..."
read -n 1 -s
echo ""

/usr/bin/time /usr/bin/vobcopy -m -i "${dvddir}" -o "${dstdir}"

if [ $? != 0 ]; then
   echo "Copy failed"
   exit 1
fi

exit 0

