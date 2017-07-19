#!/bin/sh

DEBUG=0

BASE=/share/homes/Steve
export LD_LIBRARY_PATH=${BASE}/handbrake/usr/lib

HANDBRAKE=${BASE}/handbrake/usr/bin/HandBrakeCLI

QUEUE_LOG=${BASE}/process.log
HBCLI_LOG=${BASE}/hb-cli.log
SPOOL_DIR=${BASE}/spool
QUEUE_DIR=${SPOOL_DIR}/queue
DONE_DIR=${SPOOL_DIR}/completed
LOCKFILE=${SPOOL_DIR}/run.lock

# Re-run in the background

if [ "x${1}" != 'x-bg' ]; then
   $0 -bg $* > /dev/null 2>&1 &
   exit
fi


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

  success=1

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

	if [ ${DEBUG} = 1 ]; then
	   sleep 2
	else
           ${HANDBRAKE} -i "${src}" -Z "High Profile" -m -t ${title} -o "${dst}" ${subtitle} ${chapters} > ${HBCLI_LOG} 2>&1
	fi

	if [ $? = 0 ]; then
	  echo "completed: ${dst}" >> ${QUEUE_LOG}
	else
	  echo "   failed: ${dst}" >> ${QUEUE_LOG}
	  success=0
	fi
        
  done <"$file"

  if [ ${success} = 1 ]; then
    /bin/mv ${file} ${DONE_DIR}
  fi
        
}

if [ -f ${LOCKFILE} ]; then
   echo "Lockfile exists"
   exit 1
fi

echo $$ > ${LOCKFILE}

while [ "$(/bin/ls -A ${QUEUE_DIR})" ]; do
   run_queue
   if [ ${success} = 0 ]; then
      echo "Not checking again - previous error occurred"
      break
   fi
done

rm ${LOCKFILE}

exit 0
