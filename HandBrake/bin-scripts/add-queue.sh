#!/bin/sh

hostname=`/bin/uname -n`

case "${hostname}" in
thorin)
  BASE=/home/private
  QUEUE=${BASE}/spool/queue
  RUN_QUEUE=/home/smp/home/script-backup/HandBrake/bin-scripts/queue-run.sh
  ;;
*)
  BASE=/share/homes/Steve
  QUEUE=${BASE}/spool/queue
  RUN_QUEUE=${BASE}/bin/queue-run.sh
  ;;
esac

if [ "x${1}" = "x" ]; then
   echo "Usage: add-queue.sh <outpath> [comment]"
   exit 1
else
   outpath="${1}"
fi

if [ "x${2}" = "x" ]; then
   comment="Encoding"
else
   comment="${2}"
fi

time=`date +%s`
count=1

while [ ${count} -lt 50 ]; do

   spool_file="${QUEUE}/${time}-${count}.cnv"

   let "count++"

   if [ ! -f ${spool_file} ]; then
      break
   fi
done

/bin/cat > ${spool_file} <<EOT
#!/bin/bash

OUTPATH="${outpath}"

if [ "x\${OUTPATH}" != "x" ]; then
   OUTFILE=\`/usr/bin/basename "\${OUTPATH}"\`

   /bin/touch "\${OUTPATH}"
   /bin/chmod 644 "\${OUTPATH}"
fi

if [ "x\${QUEUE_LOG}" != "x" ]; then
   now=\`/bin/date +"%D %T"\`
   echo "\${now} - ${comment}" >> \${QUEUE_LOG}
fi

EOT

/bin/cat >> ${spool_file}

/bin/cat >> ${spool_file} <<EOT

status=\$?

if [ "x\${QUEUE_LOG}" != "x" -a "x\${OUTFILE}" != "x" ]; then
   now=\`/bin/date +"%D %T"\`

   if [ \${status} = 0 ]; then
     echo "\${now} - Completed: \${OUTFILE}" >> \${QUEUE_LOG}
   else
     echo "\${now} -    Failed: \${OUTFILE}" >> \${QUEUE_LOG}
   fi
fi

exit \${status}

EOT

echo "Conversion queued"

c=`/bin/ps -ef | /bin/grep queue-run.sh | /bin/grep -v grep -c`

if [ $c = 0 ]; then
   echo "Starting queue run..."
   ${RUN_QUEUE}
fi

exit 0

