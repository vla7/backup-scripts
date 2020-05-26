#!/bin/bash
PATH="/usr/local/bin:/bin:/usr/bin:/usr/sbin"
export PATH

acc=123123
bak_dir=/backup/`whoami`/$acc
shared_db_dir=/home/$acc/tmp/db
remove_older_than=2B

mkdir -p $bak_dir/files
mkdir -p $bak_dir/db
#mkdir -p $bak_dir/mail

/usr/bin/rdiff-backup -v4 --remove-older-than --force $remove_older_than $bak_dir/files
/usr/bin/rdiff-backup --ssh-no-compression -v4 $acc@$acc.ftp.site.com::/home/$acc/www/ $bak_dir/files/

ssh -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com -tt "mkdir -p $shared_db_dir"

while read l; do
        set -- $l
        line="$line;mysqldump $2 $3 $4 $6 > $shared_db_dir/$6.sql"
done < dblist.txt
line=`echo $line | sed 's/^;//g'`
ssh -n -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com -tt "$line"

/usr/bin/rdiff-backup -v4 --remove-older-than --force $remove_older_than $bak_dir/db
/usr/bin/rdiff-backup --ssh-no-compression -v4 $acc@$acc.ftp.site.com::$shared_db_dir/ $bak_dir/db/

ssh -o StrictHostKeyChecking=no $acc@$acc.ftp.site.com -tt "rm -rf $shared_db_dir"

