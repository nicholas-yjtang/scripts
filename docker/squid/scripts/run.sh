#!/bin/bash
echo "Starting squid"
/opt/squid/sbin/squid --foreground -d 2
echo "Squid ended"