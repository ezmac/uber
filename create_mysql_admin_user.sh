#!/bin/bash

if [ -f /.mysql_admin_created ]; then
	echo "MySQL 'admin' user already created!"
	exit 0
fi
mkdir -p /var/lib/mysql
chown mysql:mysql /var/lib/mysql -R
chmod ug+rwx /var/lib/mysql/ -R

/usr/bin/mysql_install_db --user=mysql -ldata=/data/debug/mysql/
chown mysql:mysql /var/lib/mysql -R
chmod ug+rwx /var/lib/mysql/ -R
/usr/bin/mysqld_safe --defaults-file=/etc/mysql/my.cnf & #> /dev/null 2>&1 &

sleep 5
PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"
mysql -uroot -e "select * from information_schema.tables where 1"
mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "CREATE USER 'web_user'@'%' IDENTIFIED BY 'web'"

mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;"
mysql -uroot -e "GRANT ALL  ON *.* TO web_user@'%';"
mysql -uroot -e "GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'pma'@'localhost'  IDENTIFIED BY 'pmapass';"

mysql -uroot -e "flush privileges;"
mysqladmin -uroot shutdown

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"
#cat /var/lib/mysql/*.err
echo "You can log into phpmyadmin with credentials admin:$PASS">>/data/config/credentials.txt

cd /tmp/&& cp /usr/share/doc/phpmyadmin/examples/create_tables.sql.gz . && gzip -d create_tables.sql.gz && mysql -u root <create_tables.sql


touch /.mysql_admin_created
