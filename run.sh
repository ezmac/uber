#!/bin/bash
ls /etc
echo "This is your debug section"
ls /etc/supervisor/
mkdir -p /data/debug/mysql/mysql/
ls /data -R
chown mysql:mysql /data/debug/mysql/mysql
chmod u+x /provision/provision.sh && /bin/bash /provision/provision.sh
chown :users /data/ -R




service samba start
exec supervisord -n -c /data/config/supervisor/supervisord.conf &
/bin/bash

