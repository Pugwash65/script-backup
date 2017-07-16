#!/bin/sh

usage() {

  prog=`basename $0`
  echo "${prog} <VIDEO_TS Path> <Output file> <Title #> <Subtitle #> <Chapters a-b>"
  exit 1
}

BASE=/share/homes/Steve
SPOOL=${BASE}/spool

SOURCE_DIR=${1}

if [ "x${SOURCE_DIR}" = "x" ]; then
   usage
fi

OUTPUT_FILE=${2}

if [ "x${OUTPUT_FILE}" = "x" ]; then
   usage
fi

if [ "x${3}" != "x" ]; then
   TITLE=${3}
else
   TITLE=1
fi

if [ "x${4}" != "x" ]; then
   SUBTITLE=${4}
else
   SUBTITLE=
fi

if [ "x${5}" != "x" ]; then
   CHAPTERS="-c ${5}"
else
   CHAPTERS=
fi

ext="${OUTPUT_FILE##*.}"
if [ "x${ext}" != "xmp4" ]; then
   echo "Output file should be .mp4"
   exit 1
fi

if [ -e ${OUTPUT_FILE} ]; then
   echo "Output file already exists"
   exit 1
fi

if [ ! -f "${SOURCE_DIR}/VIDEO_TS.IFO" ]; then
   echo "Source may not be a DVD"
  exit 1
fi

time=`date +%s`
spool_file="${SPOOL}/${time}.cnv"

echo ${SOURCE_DIR},${OUTPUT_FILE},${TITLE},${SUBTITLE},${CHAPTERS} > ${spool_file}

echo "Conversion queued"

exit 0

