#!/bin/bash
#!/bin/bash

PATH="/usr/local/bin:/bin:/usr/bin:/usr/sbin"
export PATH

ACC=123123
SRV=1.1.1.1
DATADIR=/home/bitrix/www
BKDIR=/backup/`whoami`/$ACC
USER=root
RDIFF=/usr/bin/rdiff-backup

mkdir -p $BKDIR
mkdir -p $BKDIR/db/
mkdir -p $BKDIR/files/
#mkdir -p $BKDIR/mail/

#MySQL dump
ssh -o StrictHostKeyChecking=no $USER@$SRV -tt 'mkdir /tmp/dbbak;\
 mysql -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|test)" | while read DB; do mysqldump $DB > /tmp/dbbak/$DB.sql; done'
$RDIFF --ssh-no-compression --print-statistics $USER@$SRV::/tmp/dbbak/ $BKDIR/db/
ssh -o StrictHostKeyChecking=no $USER@$SRV -tt 'rm -rf /tmp/dbbak'

#one_db by tcp
#mkdir ${BKDIR}/tmpdb
#mysqldump -h####### -u######## -p############### DDDDBBBBB > ${BKDIR}/tmpdb/DDDDBBBBB.sql
#$RDIFF --print-statistics ${BKDIR}/tmpdb/ $BKDIR/db/
#rm -rf ${BKDIR}/tmpdb/

# start incremental backup
$RDIFF --ssh-no-compression --exclude-globbing-filelist ./exclude.list --print-statistics $USER@$SRV::$DATADIR/ $BKDIR/files/


$RDIFF --remove-older-than 2B --force -v5 $BKDIR/files
$RDIFF --remove-older-than 2B --force -v5 $BKDIR/db
#$RDIFF --remove-older-than 3D --force -v5 $BKDIR/mail

#cat /opt/exclude.list
#/home/bitrix/www/bitrix/backup
#/home/bitrix/www/bitrix/cache
#/home/bitrix/www/bitrix/managed_cache
#/home/bitrix/www/bitrix/stack_cache
#/home/bitrix/www/upload/resize_cache
#/home/bitrix/www/upload/tmp
#/home/bitrix/www/bitrix/updates
#/home/bitrix/www/bitrix/html_pages
#/home/bitrix/www/bitrix/managed_cache2
#/home/bitrix/www/bitrix/cache2
