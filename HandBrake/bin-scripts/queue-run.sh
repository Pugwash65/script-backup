#!/bin/sh

DEBUG=0

hostname=`/bin/uname -n`

case "${hostname}" in
thorin)
  BASE=/home/private
  export HANDBRAKE=/usr/bin/HandBrakeCLI
  ;;
*)
  BASE=/share/homes/Steve
  LIBPATH=${BASE}/handbrake/usr/lib
  export LD_LIBRARY_PATH=${LIBPATH}

  export HANDBRAKE=${BASE}/handbrake/usr/bin/HandBrakeCLI
  ;;
esac

export QUEUE_LOG=${BASE}/process.log
export HBCLI_LOG=${BASE}/hb-cli.log
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

  sh -x ${file} >${HBCLI_LOG} 2>&1
##  sh ${file} >${HBCLI_LOG} 2>&1

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

now=`/bin/date +"%D %T"`
echo "" >> ${QUEUE_LOG}
echo "${now} - Starting Run" >> ${QUEUE_LOG}

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

rm ${LOCKFILE}

exit 0
