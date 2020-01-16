#!/bin/sh

DEBUG=0

hostname=`/bin/uname -n`

case "${hostname}" in
thorin)
  BASE=/home/private
  HANDBRAKE=/usr/bin/HandBrakeCLI
  ;;
*)
  BASE=/share/homes/Steve
  LIBPATH=${BASE}/handbrake/usr/lib
  export LD_LIBRARY_PATH=${LIBPATH}

  HANDBRAKE=${BASE}/handbrake/usr/bin/HandBrakeCLI
  ;;
esac

source=$1
outfile=$2
subtitle=$3

if [ "x${source}" = "x" ]; then
   echo "Usage: <mkvfile> <mp4file> [subtitle_track]"
   exit 1
fi

if [ "x${outfile}" = "x" ]; then
   echo "Usage: <mkvfile> <mp4file> [subtitle_track]"
   exit 1
fi

dir=`/usr/bin/dirname $0`
PATH=${dir}:${PATH}

dvd_dir=`/bin/pwd`
source="${dvd_dir}/${source}"
outpath="${dvd_dir}/${outfile}"

if [ ! -e "${source}" ]; then
   echo "Source file does not exist"
   exit 1
fi

ext="${outfile##*.}"

if [ "x${ext}" != "xmp4" ]; then
   echo "Output files should be .mp4"
   exit 1
fi

if [ -e "${outpath}" ]; then
   echo "Output file already exists"
   exit 1
fi

if [ "x${subtitle}" != "x" -a "x${subtitle}" != "x0" ]; then
   subtitle="-s ${subtitle}"
else
   subtitle=
fi

preset="HQ 576p25 Surround"
encoder_level="--encoder-level 4.1"

hbcmd="\${HANDBRAKE} -i \"${source}\" -Z \"${preset}\" ${quality} ${encoder_level} --non-anamorphic --modulus 2 --keep-display-aspect -m -o \"${outpath}\" ${subtitle} ${audio} ${encoder_options} ${chapters}"
  
comment="Encode track ${track} => ${outfile}"

echo "${hbcmd}" | add-queue.sh "${outpath}" "${comment}"

exit 0

