#!/bin/bash
PATH="/usr/local/bin:/bin:/usr/bin:/usr/sbin"
export PATH

ACC=p123123
SRV=1.1.1.1
DATADIR=/var/www/
BKDIR=/backup/`whoami`/$ACC/$1
USER=root
DATE=$(date '+%Y%m%d-%H.%M')

mkdir -p $BKDIR
mkdir -p $BKDIR/db/
mkdir -p $BKDIR/files/

#db
ssh -o StrictHostKeyChecking=no $USER@$SRV -tt 'mkdir /tmp/dbbak; mysql -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|test)" | while read DB; do mysqldump $DB > /tmp/dbbak/$DB.sql; done'
ssh -o StrictHostKeyChecking=no $USER@$SRV "tar zcvf - /tmp/dbbak/" | cat > $BKDIR/db/$DATE.tar.gz
ssh -o StrictHostKeyChecking=no $USER@$SRV -tt 'rm -rf /tmp/dbbak/'

# files
ssh -o StrictHostKeyChecking=no $USER@$SRV "tar zcvf - $DATADIR" | cat > $BKDIR/files/$DATE.tar.gz

#remove more than 3
rm -rf `ls -t1 ${BKDIR}/db/* | sort -rn | awk 'NR>1'`
rm -rf `ls -t1 ${BKDIR}/files/* | sort -rn | awk 'NR>1'`

