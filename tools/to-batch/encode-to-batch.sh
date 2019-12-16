#!/bin/sh

HANDBRAKE="C:\Program Files\Handbrake\HandBrakeCLI.exe"
WINBASE="D:\\Media\\DVD Library\\FullDisc\\"

hostname=`/bin/uname -n`

case "${hostname}" in
thorin)
  BASE=/home/private
  ;;
*)
  BASE=/share/homes/Steve
  ;;
esac

OUTFILE='handbrake.bat'

DATFILE='encode.dat'
VIDEOTS='VIDEO_TS'

if [ ! -f ${DATFILE} ]; then
   echo "${DATFILE}: Not present"
   exit 1
fi

if [ ! -d ${VIDEOTS} ]; then
   echo "${VIDEOTS}: Not present"
   exit 1
fi

dvd_dir=`/bin/pwd`
dvd_name=`/bin/basename ${dvd_dir}`

time=`date +%s`

cp /dev/null ${OUTFILE}

while IFS=, read -ra keys; do

  c=`echo ${keys} | grep ^#`
  if [ "x${c}" != "x" ]; then
     continue
  fi

  if [ ${#keys[@]} = 0 ]; then
     continue
  fi

  # Values to be separated by commas are represented by plus sign in fast-queue file

  for k in "${keys[@]}"; do

   IFS='=' read key value <<< "$k"

   if [ "x${key}" = "x" -o "x${value}" = "x" ]; then
      echo "Expecting key and value"
      exit 1
   fi

   value=`echo $value | /bin/sed -e 's/+/,/g'`

   case "${key}" in
   track)
    track_num=${value}
    ;;
   chapters)
    chapters="-c ${value}"
    ;;
   audio)
    audio="-a ${value}"
    ;;
   subtitle)
    subtitle="-s ${value}"
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

#  outfile="${outfile%\"}"
#  outfile="${outfile#\"}"

  outfile=`echo ${outfile} | /bin/sed -e 's/[\r"]//g' `

  windir="\"${WINBASE}${dvd_name}\\${VIDEOTS}\""
  winpath="\"${WINBASE}${dvd_name}\\${outfile}\""

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

  cmd="\"${HANDBRAKE}\" -i ${windir} -Z \"HQ 576p25 Surround\""
  cmd="${cmd} --encoder-level 4.1 --non-anamorphic --modulus 2"
  cmd="${cmd} -m -t ${track_num} -o ${winpath} ${subtitle} ${audio} ${chapters}"

  echo $cmd >> ${OUTFILE}
  echo "" >> ${OUTFILE}

done < "${DATFILE}"

unix2dos ${OUTFILE}

echo "Batch file created"

exit 0

