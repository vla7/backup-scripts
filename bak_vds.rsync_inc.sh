#!/bin/bash
PATH="/usr/local/bin:/bin:/usr/bin:/usr/sbin"
export PATH

ACC=123123
SRV=1.1.1.1
DATADIR=/var/www/user/data/www
BKDIR=/backup/`whoami`/$ACC
USER=root
DATE=$(date '+%Y%m%d-%H.%M')

mkdir -p $BKDIR
mkdir -p $BKDIR/db/
mkdir -p $BKDIR/files/
mkdir -p $BKDIR/db/$DATE
mkdir -p $BKDIR/files/$DATE

#db
last=`ls -td1 $BKDIR/db/* | head -1`
ssh -o StrictHostKeyChecking=no $USER@$SRV -tt 'mkdir /tmp/dbbak; mysql -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|test)" | while read DB; do mysqldump $DB > /tmp/dbbak/$DB.sql; done'
rsync -av --link-dest=$last --rsync-path='nice -n19 ionice -c3 rsync' -e "ssh -o StrictHostKeyChecking=no" $USER@$SRV:/tmp/dbbak/ $BKDIR/db/$DATE/
ssh -o StrictHostKeyChecking=no $USER@$SRV -tt 'rm -rf /tmp/dbbak'
#ssh -o StrictHostKeyChecking=no $USER@$SRV -tt "mkdir /tmp/dbbak; mysqldump -u$u -p$p $db > /tmp/dbbak/${db}.${DATE}.sql;"

# files
last=`ls -td1 $BKDIR/files/* | head -1`
rsync -av --link-dest=$last --rsync-path='nice -n19 ionice -c3 rsync' -e "ssh -o StrictHostKeyChecking=no" $USER@$SRV:$DATADIR/ $BKDIR/files/$DATE/

#remove more than 3
rm -rf `ls -td1 ${BKDIR}/db/* | sort -rn | awk 'NR>3'`
rm -rf `ls -td1 ${BKDIR}/files/* | sort -rn | awk 'NR>3'`
