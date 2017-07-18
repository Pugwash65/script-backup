#!/bin/sh

BASE=/share/homes/Steve
export LD_LIBRARY_PATH=${BASE}/handbrake/usr/lib

HANDBRAKE=${BASE}/handbrake/usr/bin/HandBrakeCLI

QUEUE_LOG=${BASE}/process.log
HBCLI_LOG=${BASE}/hb-cli.log
SPOOL_DIR=${BASE}/spool
QUEUE_DIR=${SPOOL_DIR}/queue
DONE_DIR=${SPOOL_DIR}/completed
LOCKFILE=${SPOOL_DIR}/run.lock

trap catch_int int

function catch_int() {
  echo Quit...
  rm ${LOCKFILE}
  exit 1
}

function run_queue() {
  for f in ${QUEUE_DIR}/*; do

     run_convert $f
  done

}

function run_convert() {
  file=$1

  while IFS=, read -r src dst title subtitle chapters; do
        outf=`basename "${dst}"`
	echo "${src} => ${outf}"

	if [ "x${chapters}" != "x" ]; then
           chapters="-c ${chapters}"
        fi

        if [ "x${subtitle}" != "x" ]; then
           subtitle="-s ${subtitle}"
        fi

	touch "${dst}"
	chmod 644 "${dst}"
        ${HANDBRAKE} -i "${src}" -Z "High Profile" -m -t ${title} -o "${dst}" ${subtitle} ${chapters} > ${HBCLI_LOG} 2>&1

	if [ $? = 0 ]; then
 	  /bin/mv ${file} ${DONE_DIR}
	  echo "completed: ${dst}" >> ${QUEUE_LOG}
	else
	  echo "   failed: ${dst}" >> ${QUEUE_LOG}
	  exit 1
	fi
        
  done <"$file"

}

if [ -f ${LOCKFILE} ]; then
   echo "Lockfile exists"
   exit 1
fi

echo $$ > ${LOCKFILE}

if [ "$(/bin/ls -A ${QUEUE_DIR})" ]; then
   run_queue
fi

rm ${LOCKFILE}

exit 0
