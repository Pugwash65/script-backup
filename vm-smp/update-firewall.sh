#!/bin/bash

IPTABLES=/usr/sbin/iptables

${IPTABLES} -S | grep -- '--dport 4242' |
  while IFS= read line; do
    delcmd=`echo $line | /bin/sed -e s'/^-A/-D/'`
   ${IPTABLES} ${delcmd}
   if [ $? != 0 ]; then
      echo "FAILED: ${delcmd}"
      exit 1
   fi

done


addcmd="-I INPUT 4 -p tcp  -m state --state NEW -m tcp --dport 4242 --src dancing-monkey.no-ip.org -j ACCEPT"

${IPTABLES} ${addcmd}

if [ $? != 0 ]; then
   echo "FAILED: ${delcmd}"
   exit 1
fi

exit 0
