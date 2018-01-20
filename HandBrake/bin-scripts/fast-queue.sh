#!/bin/sh

DATFILE='encode.dat'
VIDEOTS='VIDEO_TS'

BASE=/share/homes/Steve
RUN_QUEUE=${BASE}/bin/queue-run.sh
QUEUE=${BASE}/spool/queue

if [ ! -f ${DATFILE} ]; then
   echo "${DATFILE}: Not present"
   exit 1
fi

if [ ! -d ${VIDEOTS} ]; then
   echo "${VIDEOTS}: Not present"
   exit 1
fi

dvd_dir=`/bin/pwd`

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

  for k in "${keys[@]}"; do

   IFS='=' read key value <<< "$k"

   if [ "x${key}" = "x" -o "x${value}" = "x" ]; then
      echo "Expecting key and value"
      exit 1
   fi

   case "${key}" in
   track)
    track_num=${value}
    ;;
   chapters)
    chapters=${value}
    ;;
   audio)
    audio_num=${value}
    ;;
   subtitle)
    subtitle_num=${value}
    ;;
   output)
    outfile=${value}
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

  if [ "x${track_num}" = "x" ]; then
     echo "Expecting: track=<track-num>"
     exit
  fi

  # Remove quotes and encode commas

  outfile="${outfile#\"}"
  outfile="${outfile%\"}"
##  outfile=`echo ${outfile} | /bin/sed -e 's/,/#@#/g'`

  source="${dvd_dir}/${VIDEOTS}"

  outpath="${dvd_dir}/${outfile}"

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

  spool_file="${QUEUE}/${time}-${count}.cnv"

  let "count++"

  cp /dev/null ${spool_file}
  echo track=${track_num} >> ${spool_file}
  echo subtitle=${subtitle_num} >> ${spool_file}
  echo output=\"${outpath}\" >> ${spool_file}
  echo source=\"${source}\" >> ${spool_file}

  if [ "x${audio_num}" != "x" ]; then
     echo audio=${audio_num} >> ${spool_file}
  fi

  if [ "x${chapters}" != "x" ]; then
     echo chapters=${chapters} >> ${spool_file}
  fi

done < "${DATFILE}"

echo "Conversion queued"

c=`/bin/ps -ef | /bin/grep queue-run.sh | /bin/grep -v grep -c`

if [ $c = 0 ]; then
   echo "Starting queue run..."
   ${RUN_QUEUE}
fi

exit 0

