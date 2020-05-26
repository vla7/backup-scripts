#!/bin/bash
PATH="/usr/local/bin:/bin:/usr/bin:/usr/sbin"
export PATH

bak_acc=`whoami`
acc=123123
user="root"
host="1.1.1.1"
db="db1"
shared_db_dir="/var/www"
bak_dir="/backup/$bak_acc/$acc"

mkdir -p $bak_dir/files
mkdir -p $bak_dir/db

date=$(date '+%Y%m%d-%H.%M')

if [ "$1" == "db" ]; then
    rm -f $bak_dir/db/*.gz
    ssh -o StrictHostKeyChecking=no $user@$host -t "su -c 'pg_dump ${db}' postgres" | gzip -c -9 > $bak_dir/db/${db}.${date}.sql.gz
fi

if [ "$1" == "files" ]; then
    rm -rf `ls -td $bak_dir/files/* | awk 'NR>1'`
    ssh -o StrictHostKeyChecking=no $user@$host "tar zcvf - $shared_db_dir/" | cat > $bak_dir/files/${date}.tar.gz
fi

