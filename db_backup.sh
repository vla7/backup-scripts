#!/bin/bash
PATH="/usr/local/bin:/bin:/usr/bin:/usr/sbin"
export PATH

user="root"
bakdir="/backup"
servers="srv1 srv2"
tmp_dumps_path="/var/lib/mysql/mysqldumps"
rdiff=/usr/bin/rdiff-backup
#remove_older_than=31D
remove_older_than=3M

mkdir -p $bakdir/db/

for serv in $servers
do
        mkdir -p $bakdir/db/$serv

        echo "Removing old backups $serv..."
        echo "$rdiff --remove-older-than $remove_older_than --force $bakdir/db/$serv/"
        $rdiff --remove-older-than $remove_older_than --force $bakdir/db/$serv/

        echo "Dumping $serv..."
        ssh -o StrictHostKeyChecking=no $user@$serv -tt "mkdir $tmp_dumps_path;\
        mysql -e 'SHOW DATABASES' | egrep -v '(information_schema|performance_schema)' | while read DB; do nice -n 15 ionice -c 3 mysqldump --skip-dump-date --skip-lock-tables \$DB > $tmp_dumps_path/\$DB.sql; done"

        echo "Syncing $serv..."
        $rdiff -v4 --ssh-no-compression --print-statistics $user@$serv::$tmp_dumps_path/ $bakdir/db/$serv/
        ssh -o StrictHostKeyChecking=no $user@$serv -tt "rm -rf $tmp_dumps_path"
