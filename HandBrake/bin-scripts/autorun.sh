#!/bin/sh
#
# Hooked from autorun.sh in Flash /dev/sdc6 - mount /dev/sdc6 /tmp/config
#
# mount $(/sbin/hal_app --get_boot_pd port_id=0)6 /tmp/config
#
# cp to /etc/config/autorun.sh
#

BASE=/share/CACHEDEV1_DATA/homes/Steve

date >> /tmp/autorun.log
echo "Start queue" >> /tmp/autorun.log

( sleep 120; /bin/sh ${BASE}/bin/control-queue.sh start ) &

echo "Status: $?" >> /tmp/autorun.log

exit $?
