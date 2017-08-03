#!/bin/sh
#
# Hooked from autorun.sh in Flash /dev/sdc3 - mount /dev/sd3c /tmp/config
#
# cp to /etc/config/autorun.sh
#

BASE=/share/homes/Steve

/bin/sh ${BASE}/bin/control-queue.sh start

exit $?
