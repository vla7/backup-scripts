#!/bin/bash
PATH="/usr/local/bin:/bin:/usr/bin:/usr/sbin"
export PATH

ACC=123123
SRV=1.1.1.1
MYSQLROOT=''
DATADIR=/home/admin/web
BKDIR=/backup/`whoami`/$ACC
USER=root
RDIFF=/usr/bin/rdiff-backup

mkdir -p $BKDIR
mkdir -p $BKDIR/db/
mkdir -p $BKDIR/files/

#MySQL dump
if [ -z "$MYSQLROOT" ];then
    ssh -o StrictHostKeyChecking=no $USER@$SRV -tt 'mkdir /tmp/dbbak; mysql -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|test)" | while read DB; do mysqldump $DB > /tmp/dbbak/$DB.sql; done'
else
    ssh -o StrictHostKeyChecking=no $USER@$SRV -tt "mkdir /tmp/dbbak;  mysql -uroot -p$mysqlroot -e \"SHOW DATABASES;\" | grep -Ev \"(Database|information_schema|performance_schema|test)\" | while read DB; do mysqldump -uroot -p$mysqlroot \$DB > /tmp/dbbak/\$DB.sql; done"
$RDIFF --ssh-no-compression --print-statistics $USER@$SRV::/tmp/dbbak/ $BKDIR/db/
fi
ssh -o StrictHostKeyChecking=no $USER@$SRV -tt 'rm -rf /tmp/dbbak'

# start incremental backup
$RDIFF --ssh-no-compression --print-statistics $USER@$SRV::$DATADIR/ $BKDIR/files/

#clear old
$RDIFF --remove-older-than 15D --force -v5 $BKDIR/files
$RDIFF --remove-older-than 15D --force -v5 $BKDIR/db

