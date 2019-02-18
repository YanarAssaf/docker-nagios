#!/bin/bash
set -e
/usr/local/pnp4nagios/bin/npcd -d -f /usr/local/pnp4nagios/etc/npcd.cfg
rm -f /usr/local/pnp4nagios/share/install.php
/etc/init.d/nagios start
rm -rf /run/httpd/*
exec /usr/sbin/apachectl -D FOREGROUND
