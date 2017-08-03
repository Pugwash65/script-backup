#!/bin/sh
#
# Hooked from autorun.sh in Flash /dev/sdc3 - mount /dev/sd3c /tmp/config
#
# cp to /etc/config/autorun.sh
#

BASE=/share/homes/Steve
QUEUE_RUN=${BASE}/bin/queue-run.sh
LOCKFILE=${BASE}/spool/run.lock

/bin/echo -n "Starting Handbrake queue: "
/bin/rm ${LOCKFILE}
/usr/bin/sudu -u Steve ${QUEUE_RUN}

exit $?
