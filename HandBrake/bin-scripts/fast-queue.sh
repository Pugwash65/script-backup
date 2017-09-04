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

while IFS=, read -r track subtitle output; do

  if [ "x${track}" = "x" -o "x${subtitle}" = "x" -o "x${output}" = "x" ]; then
     continue
  fi

  # Extract Track

  IFS='=' read key track_num <<< "$track"

  if [ "${key}" != "track" ]; then
     echo "Expecting: track=<track-number>"
     exit
  fi

  # Extract Subtitle

  IFS='=' read key subtitle_num <<< "$subtitle"

  if [ "${key}" != "subtitle" ]; then
     echo "Expecting: subtitle=<subtitle-number>"
     exit
  fi
     
  # Extract Output

  IFS='=' read key outfile <<< "$output"

  if [ "${key}" != "output" ]; then
     echo "Expecting: output=<output-file>"
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

  cat > $spool_file <<EOT
track=${track_num}
subtitle=${subtitle_num}
output="${outpath}"
source="${source}"
EOT

done < "${DATFILE}"

echo "Conversion queued"

c=`/bin/ps -ef | /bin/grep queue-run.sh | /bin/grep -v grep -c`

if [ $c = 0 ]; then
   echo "Starting queue run..."
   ${RUN_QUEUE}
fi

exit 0

