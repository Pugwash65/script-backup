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

export LD_LIBRARY_PATH=${LIBPATH}

QUEUE_LOG=${QUEUE_LOG}
HBCLI_LOG=${HBCLI_LOG}
DEBUG=${DEBUG}
EOT

  /bin/chmod 600 ${CMDFILE}

  subtitle=""
  audio=""

  while IFS=\= read -r key value ; do

     if [ "x${key}" = "xtrack" ]; then
        track=${value}
     fi

     if [ "x${key}" = "xchapters" ]; then
        chapters="-c ${value}"
     fi

     if [ "x${key}" = "xaudio" ]; then
        audio="-a ${value}"
     fi

     if [ "x${key}" = "xsubtitle" -a "x${value}" != "x0" ]; then
        subtitle="-s ${value}"
     fi

     if [ "x${key}" = "xoutput" ]; then
        output="${value}"
     fi

     if [ "x${key}" = "xsource" ]; then
        source="${value}"
     fi
  done <"$file"

  outf=`basename "${output}"`
  outf="${outf%\"}"

  /bin/cat >> ${CMDFILE} <<EOT

/bin/touch ${output}
/bin/chmod 644 ${output}

now=\`/bin/date +"%D %T"\`

echo "\${now} - Encode track ${track} => ${outf}" >> ${QUEUE_LOG}

if [ \${DEBUG} = 0 ]; then
  ${HANDBRAKE} -i ${source} -Z "High Profile" -m -t ${track} -o ${output} ${subtitle} ${audio} ${chapters} > ${HBCLI_LOG} 2>&1
fi

now=\`/bin/date +"%D %T"\`

if [ \$? = 0 ]; then
  echo "\${now} - completed: ${outf}" >> ${QUEUE_LOG}
else
  echo "\${now} -    failed: ${outf}" >> ${QUEUE_LOG}
  exit 1
fi

EOT

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
