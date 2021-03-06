#!/bin/sh
#
# description: Starts and stops the snmp agent deamon
#
#

RETVAL=0

BASE=/share/homes/Steve
QUEUE_RUN=${BASE}/bin/queue-run.sh
LOCKFILE=${BASE}/spool/run.lock

start()
{
	/bin/echo -n "Starting Handbrake queue: "
	[ -f ${LOCKFILE} ] && /bin/rm ${LOCKFILE}
        /usr/bin/sudo -u Steve ${QUEUE_RUN}
	RETVAL=$?
	echo " OK"
}

stop()
{
	/bin/echo -n "Shutting Handbrake queue: "
	killall queue-run 2>/dev/null
	killall HandBrakeCLI 2>/dev/null
	/bin/rm -f ${LOCKFILE}

	RETVAL=$?
	echo " OK"
}

restart()
{
	stop
	sleep 1
	start

}

case "$1" in
	start)
			start
			;;
	stop)
			stop
			;;
	restart)
			stop
			start
			;;
esac

exit $RETVAL
