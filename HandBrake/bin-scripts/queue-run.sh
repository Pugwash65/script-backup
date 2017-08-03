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
CMDFILE=${SPOOL_DIR}/encode.sh

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

# Process every file in the queue dir

function run_queue() {
  for f in ${QUEUE_DIR}/*; do

    run_convert $f
  done

}

# Process a job file

function run_convert() {
  file=$1

  success=1

  # When Handbrake is run it clobbers the read loop
  # So add the commands to a script instead
  # But shouldn't matter as only one job per job file now

  /bin/cat > ${CMDFILE} <<EOT
#!bin/bash

QUEUE_LOG=${QUEUE_LOG}
HBCLI_LOG=${HBCLI_LOG}
DEBUG=${DEBUG}

EOT
  /bin/chmod 600 ${CMDFILE}

  while IFS=, read -r src dst title subtitle chapters; do
        outf=`basename "${dst}"`

	if [ "x${chapters}" != "x" ]; then
           chapters="-c ${chapters}"
        fi

        if [ "x${subtitle}" != "x" -a "x${subtitle}" != "x0" ]; then
           subtitle="-s ${subtitle}"
	else
	   subtitle=""
        fi

	/bin/cat >> ${CMDFILE} <<EOT

/bin/touch "${dst}"
/bin/chmod 644 "${dst}" 

now=\`/bin/date +"%D %T"\`

echo "\${now} - Encode track ${title} => ${outf}" >> ${QUEUE_LOG}
if [ \${DEBUG} = 0 ]; then
   ${HANDBRAKE} -i "${src}" -Z "High Profile" -m -t ${title} -o "${dst}" ${subtitle} ${chapters} > ${HBCLI_LOG} 2>&1
fi

now=\`/bin/date +"%D %T"\`

if [ \$? = 0 ]; then
  echo "\${now} - completed: ${outf}" >> ${QUEUE_LOG}
else
  echo "\${now} -    failed: ${outf}" >> ${QUEUE_LOG}
  exit 1
fi

EOT

  done <"$file"

  echo "exit 0" >> ${CMDFILE}

  sh ${CMDFILE}

  if [ $? = 0 ]; then
    /bin/mv ${file} ${DONE_DIR}
  else
     success=0
  fi
        
}

#
# Main
#

# Check for lockfile

if [ -f ${LOCKFILE} ]; then
   echo "Lockfile exists"
   exit 1
fi

# Create lock file

echo $$ > ${LOCKFILE}

# Zero queue log

#cp /dev/null ${QUEUE_LOG}

now=`/bin/date +"%D %T"`
echo "${now} - Starting Run" >> ${QUEUE_LOG}
echo "" >> ${QUEUE_LOG}

# Loop over queue dir in case a job was queued during current run

success=0
while [ "$(/bin/ls -A ${QUEUE_DIR})" ]; do
   run_queue
   if [ ${success} = 0 ]; then
      echo "Not checking again - previous error occurred"
      break
   fi
done

now=`/bin/date +"%D %T"`
echo "${now} - Ending Run" >> ${QUEUE_LOG}
echo "" >> ${QUEUE_LOG}

rm ${CMDFILE}
rm ${LOCKFILE}

exit 0
