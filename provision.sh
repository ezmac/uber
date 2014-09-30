#!/bin/bash

# Repeatable actions up here
mkdir -p /data/www/
mkdir -p /data/debug/
mkdir -p /data/logs/
mkdir -p /data/config/
mkdir -p /tmp/nginx/cache/

chown :sambashare /data/www/ /data/logs/ /data/config/ /data/phpmyadmin/ -R
chmod g+rw /data/www/ /data/logs/ /data/config/ /data/phpmyadmin/ -R

source /provision/config.environment

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
echo "root:$PASS"|chpasswd










# this if ensures that the code below does not run more than once per machine.
# The code below removes all the config files that come with ubuntu and replaces it with the uber configus
if [[ -f /data/config/debug/.provisioned ]]; then
  exit 0
else 
  mkdir -p /data/config/debug/
  touch /data/config/debug/.provisioned
fi
chown :users /data/ -R



# set up samba server so that files can be easily accessed from windows
# Samba will share out the data directory only.  Data directory will contain:
# - config with a folder for every server config file needed.
# - www to store app projects
# - logs with application directorys to give read access to all log files.
#   - also gives syslog and others like that.

rm -rf /etc/samba/
mv /provision/config/samba /data/config/
ln -s /data/config/samba/ /etc/

#groupadd sambashare && chown mysql:sambashare /data/ -R

#chmod 1770 /data -R
useradd samba_user

echo "$PASS"
echo "$PASS
$PASS
"|pdbedit -a -u samba_user

echo "$PASS
$PASS
"|smbpasswd -s samba_user

#set up apache server with www folder in data directory.
# - this will depend on sites-available behing written to use /data.

rm -rf /etc/apache2/sites-available
rm -rf /etc/apache2/sites-enabled
rm -rf /etc/apache2/apache2.conf
rm -rf /etc/apache2/envvars
rm -rf /etc/apache2/magic
rm -rf /etc/apache2/ports.conf

mv /provision/config/apache2/ /data/config/
ln -s /data/config/apache2/* /etc/apache2
mkdir -p /data/www/





#set up nginx to sit in front of apache just in case it is needed.  Generally, no caching.

rm -rf /etc/nginx/
mv /provision/config/nginx /data/config/
ln -s /data/config/nginx/ /etc/
mkdir -p /var/run/nginx

#set up php and pma

rm /etc/phpmyadmin/config.inc.php

mv /provision/config/php5/ /data/config/
mv /provision/config/phpmyadmin /data/config/

ln -s /data/config/php5/apache2/ /etc/php5/apache2/
ln -s /data/config/phpmyadmin/* /etc/phpmyadmin/
ln -s /data/config/phpmyadmin/config.inc.php /etc/phpmyadmin/
sed -i 's/localhost/127.0.0.1/g' /etc/phpmyadmin/config.inc.php
mkdir -p /data/phpmyadmin/upload
mkdir -p /data/phpmyadmin/save


#set up mysql
mv /provision/config/mysql/ /data/config/
rm -rf /etc/mysql/
ln -s /data/config/mysql/ /etc/
mkdir -p /data/debug/mysql/mysql/

rm -rf /var/lib/mysql/
ln -s /data/debug/mysql/ /var/lib/
chown -R mysql:mysql /var/lib/mysql/
chown -R mysql:mysql /data/debug/mysql/
chmod ug+rwx /var/lib/mysql -R
chmod ug+rwx /data/debug/mysql -R
chown -R mysql:mysql /data/debug/mysql/
chmod ug+rwx /data/debug/mysql/ -R
chown -R mysql:mysql /data/debug/mysql/mysql/
chmod ug+rwx /data/debug/mysql/mysql/ -R
chmod u+x /provision/create_mysql_admin_user.sh && /provision/create_mysql_admin_user.sh

#set up supervisord
rm -rf /etc/supervisor/
mv /provision/config/supervisor/ /data/config/
ls /data/config/
ln -s /data/config/supervisor /etc/
ls /etc/supervisor/
echo "supervisord.conf should be above"





#set up ssh

chmod 600 /root/.ssh/ -R

# System config
mkdir -p /var/spool/incron/services/
cp /provision/config/incron.root /etc/incron.d/services
echo "root">>/etc/incron.allow
service incron restart


# work around for sshd in ubuntu 14.04 # https://github.com/docker/docker/issues/5663
sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config


echo "fs.file-max = 500000">> /etc/sysctl.conf

echo "www-data soft nofile 500000">> /etc/security/limits.conf
echo "www-data hard nofile 500000">> /etc/security/limits.conf
#set up incron...
