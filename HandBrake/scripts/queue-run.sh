#!/bin/sh

BASE=/share/homes/Steve
export LD_LIBRARY_PATH=${BASE}/handbrake/usr/lib

HANDBRAKE=${BASE}/handbrake/usr/bin/HandBrakeCLI

SPOOL_DIR=${BASE}/spool
DONE_DIR=${BASE}/completed

function run_queue() {
  for f in ${SPOOL_DIR}/*; do

     run_convert $f
  done

}

function run_convert() {
  file=$1

  while IFS=, read -r src dst title subtitle chapters; do
	echo $src
	echo $dst
	if [ "x${chapters}" != "x" ]; then
           chapters="-c ${chapters}"
        fi

        if [ "x${subtitle}" != "x" ]; then
           subtitle="-s ${subtitle}"
        fi

        echo ${HANDBRAKE} -i ${src} -Z "High Profile" -t ${title} -o ${dst} ${subtitle} ${chapters}

  done <"$file"

 /bin/mv ${file} ${DONE_DIR}
}


while true; do
  if [ `/bin/ls -A ${SPOOL_DIR}` ]; then
     run_queue
  else
#     sleep 300
     sleep 2
  fi
done

