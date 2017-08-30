#!/bin/sh
#
# Install: /usr/local/lib/duplicati-service.sh
#

export TMPDIR=/var/tmp

case "$1" in
   start)
      /usr/bin/duplicati-server --webservice-interface=any --tempdir=${TMPDIR}
   ;;
   stop)
     /usr/bin/pkill -f DuplicatiServer
   ;;
   reload)
     /usr/bin/pkill -f DuplicatiServer
     c=`/usr/bin/pgrep -f DuplicatiServer`
     if [ "x${c}" != "x" ]; then
        echo "Failed to kill server"
        exit 1
     fi
     /usr/bin/duplicati-server --webservice-interface=any --tempdir=${TMPDIR}
   ;;
   *)
    echo "$1: Unknown argument"
    exit 1
esac

exit $?

