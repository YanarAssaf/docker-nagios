#!/bin/bash
set -e
/etc/init.d/nagios start
rm -rf /run/httpd/*
exec /usr/sbin/apachectl -D FOREGROUND
