#!/bin/sh
/usr/sbin/mysqld &
sleep 10
echo "Creating argus db and users"
echo "create database  argus_accedian;" | mysql
echo "Granting permissions to argus user"
echo "GRANT ALL on argus_accedian.* to  'argus'@'%' IDENTIFIED BY 'argus';FLUSH PRIVILEGES" | mysql
echo "Importing argus database ..."
mysql -uroot  argus_accedian  <  /tmp/argus_accedian.sql
echo "Importing argus database finished "

mysqladmin shutdown
echo "Starting MySQL Server"
/usr/sbin/mysqld

