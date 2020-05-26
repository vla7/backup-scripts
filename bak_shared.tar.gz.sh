#!/bin/bash

PATH="/usr/local/bin:/bin:/usr/bin:/usr/sbin"
export PATH

acc=p497350                                     ############################## acc
bak_dir=/backup/`whoami`/$acc
shared_db_dir=/home/$acc/tmp/db

mkdir -p $bak_dir/files
mkdir -p $bak_dir/db

date=$(date '+%Y%m%d-%H.%M')
ssh -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com "tar zcvf - /home/$acc/www/" | cat > $bak_dir/files/${date}.tar.gz

ssh -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com -tt "mkdir -p $shared_db_dir"
while read l; do
        set -- $l
        line="$line;mysqldump $2 $3 $4 $6 > $shared_db_dir/$6.sql"
done < dblist_p497350.txt
line=`echo $line | sed 's/^;//g'`
ssh -n -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com -tt "$line"

date=$(date '+%Y%m%d-%H.%M')
ssh -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com "tar zcvf - $shared_db_dir/" | cat > $bak_dir/db/${date}.tar.gz

ssh -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com -tt "rm -rf $shared_db_dir"

rm -rf `ls -td $bak_dir/db/* | awk 'NR>3'`
rm -rf `ls -td $bak_dir/files/* | awk 'NR>3'`

