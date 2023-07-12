#!/bin/bash
echo "Starting squid"
rm -rf /opt/squid/var/run/squid.pid
/opt/squid/sbin/squid --foreground -z
/opt/squid/sbin/squid --foreground -YCd 2
echo "Squid ended"