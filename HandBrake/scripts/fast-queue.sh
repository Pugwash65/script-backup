#!/bin/sh

DATFILE='encode.dat'
VIDEOTS='VIDEO_TS'
ADDENCODE=/share/homes/Steve/bin/add-encode.sh

if [ ! -f ${DATFILE} ]; then
   echo "${DATFILE}: Not present"
   exit 1
fi

if [ ! -d ${VIDEOTS} ]; then
   echo "${VIDEOTS}: Not present"
   exit 1
fi

dvd_dir=`/bin/pwd`

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

  ${ADDENCODE} "${dvd_dir}/${VIDEOTS}" "${dvd_dir}/${outfile}" ${track_num} ${subtitle_num} 
     
done < "${DATFILE}"
