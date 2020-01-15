#!/bin/sh

DEBUG=0

hostname=`/bin/uname -n`

if [ "x${1}" = "x--real" ]; then
   realdvd=1
   dvd_dir=$(/bin/df /dev/sr0 | /bin/tail -n 1 | /bin/awk '{print $NF}')
   out_dir=`/bin/pwd`
else
   realdvd=
   dvd_dir=`/bin/pwd`
   out_dir="${dvd_dir}"
fi

case "${hostname}" in
thorin)
  BASE=/home/private
  HANDBRAKE=/usr/bin/HandBrakeCLI
#  RUN_QUEUE=/home/smp/home/script-backup/HandBrake/bin-scripts/queue-run.sh
  ;;
*)
  BASE=/share/homes/Steve
  LIBPATH=${BASE}/handbrake/usr/lib
  export LD_LIBRARY_PATH=${LIBPATH}

  HANDBRAKE=${BASE}/handbrake/usr/bin/HandBrakeCLI
#  RUN_QUEUE=${BASE}/bin/queue-run.sh
  ;;
esac

DATFILE='encode.dat'
VIDEOTS='VIDEO_TS'

if [ ! -f ${DATFILE} ]; then
   echo "${DATFILE}: Not present"
   exit 1
fi

if [ ! -d ${dvd_dir}/${VIDEOTS} ]; then
   echo "${VIDEOTS}: Not present"
   exit 1
fi

dir=`/usr/bin/dirname $0`
PATH=${dir}:${PATH}

time=`date +%s`
count=1

while IFS=, read -ra keys; do

  c=`echo ${keys} | grep ^#`
  if [ "x${c}" != "x" ]; then
     continue
  fi

  if [ ${#keys[@]} = 0 ]; then
     continue
  fi

  # Values to be separated by commas are represented by plus sign in fast-queue file

  track=
  audio=
  subtitle=
  chapters=
  outfile=
  source=
  quality=
  smaller=
  preset="HQ 576p25 Surround"
  encoder_level="--encoder-level 4.1"
  encoder_options=""

  for k in "${keys[@]}"; do

   IFS='=' read key value <<< "$k"

   if [ "x${key}" = "x" -o "x${value}" = "x" ]; then
      echo "Expecting key and value"
      exit 1
   fi

   value=`echo $value | /bin/sed -e 's/+/,/g'`

   case "${key}" in
   track)
    track=${value}
    ;;
   chapters)
    chapters=${value}
    ;;
   audio)
    audio=${value}
    ;;
   subtitle)
    subtitle=${value}
    ;;
   output)
    outfile=${value}
    ;;
   quality)
    quality=${value}
    ;;
   smaller)
    smaller=${value}
    ;;
   *)
    echo "${key}: Unknown key"
    exit 1
   esac
  done

  if [ "x${outfile}" = "x" ]; then
     echo "Expecting: output=<output-file>"
     exit
  fi

  if [ "x${track}" = "x" ]; then
     echo "Expecting: track=<track-num>"
     exit
  fi

  # Remove quotes and encode commas

  outfile="${outfile#\"}"
  outfile="${outfile%\"}"
##  outfile=`echo ${outfile} | /bin/sed -e 's/,/#@#/g'`

  source="${dvd_dir}/${VIDEOTS}"

  outpath="${out_dir}/${outfile}"

  ext="${outfile##*.}"

  if [ "x${ext}" != "xmp4" ]; then
     echo "Output files should be .mp4"
     exit 1
  fi

  if [ -e "${outpath}" ]; then
     echo "Output file already exists"
     exit 1
  fi

  if [ ! -f "${source}/VIDEO_TS.IFO" ]; then
     echo "Source must be a DVD"
     exit 1
  fi

  if [ "x${chapters}" != "x" ]; then
     chapters="-c ${chapters}"
  fi

  if [ "x${audio}" != "x" ]; then
     audio="-a ${audio}"
  fi

  if [ "x${subtitle}" != "x" -a "x${subtitle}" != "x0" ]; then
     subtitle="-s ${subtitle}"
  else
     subtitle=
  fi

  if [ "x${quality}" != "x" ]; then
     quality="-q ${quality}"
  fi

  if [ "x${smaller}" != "x" ]; then
     preset="Fast 576p25"
     encoder_level=""
     encoder_options="--ab 128"
  fi

  hbcmd="\${HANDBRAKE} -i \"${source}\" -Z \"${preset}\" ${quality} ${encoder_level} --non-anamorphic --modulus 2 --keep-display-aspect -m -t ${track} -o \"${outpath}\" ${subtitle} ${audio} ${encoder_options} ${chapters}"
  
  comment="Encode track ${track} => ${outfile}"

  echo "${hbcmd}" | add-queue.sh "${outpath}" "${comment}"

done < "${DATFILE}"

#c=`/bin/ps -ef | /bin/grep queue-run.sh | /bin/grep -v grep -c`
#
#if [ $c = 0 ]; then
#   echo "Starting queue run..."
#   ${RUN_QUEUE}
#fi

exit 0

