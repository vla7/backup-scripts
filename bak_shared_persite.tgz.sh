#!/bin/bash

PATH="/usr/local/bin:/bin:/usr/bin:/usr/sbin"
export PATH

acc=123123
d=$(date '+%Y_%m')
bak_dir=/backup/`whoami`/$d/$acc
shared_db_dir=/home/$acc/tmp/db
mkdir -p $bak_dir/files
mkdir -p $bak_dir/db

list=`ssh -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com -tt "ls -1 /home/$acc/www/" | tr -d '\r'`
for site in $list; do
        date=$(date '+%Y%m%d-%H.%M')
        ssh -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com "tar zcvf - /home/$acc/www/$site" | cat > $bak_dir/files/${site}.${date}.tar.gz
done

ssh -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com -tt "mkdir -p $shared_db_dir"
while read l; do
        set -- $l
        line="$line;mysqldump $2 $3 $4 $6 > $shared_db_dir/$6.sql"
done < dblist_${acc}.txt
line=`echo $line | sed 's/^;//g'`
ssh -n -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com -tt "$line"

date=$(date '+%Y%m%d-%H.%M')
ssh -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com "tar zcvf - $shared_db_dir/" | cat > $bak_dir/db/${date}.tar.gz
ssh -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com -tt "rm -rf $shared_db_dir"

rm -rf $(ls -td1 /backup/`whoami`/* | grep -P '\d{4}_\d{2}' | awk 'NR>3')

