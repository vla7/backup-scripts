#!/bin/bash
www_exclude=/root/files_backup.exclude
isp_exclude=/root/isp_backup.exclude
bandwith_limit=4000
bk_path='/backup'
www='/var/www'
etc='/etc'
#isp='/usr/local/mgr5/etc'
isp='/usr/local/mgr5'
if [ -z "$1" ]; then
        tasks="srv1-www srv2-www srv1-etc srv2-etc srv1-isp srv2-isp"
else
        tasks="$1"
fi

for task in $tasks; do
        #determinate last bak dir
        last=`ls -td1 ${bk_path}/${task}* | head -1`
        #srv1
        serv=`echo "$task" | awk -F- '{print $1}'`
        #www
        p=`echo "$task" | awk -F- '{print $2}'`
        #/var/www
        path=${!p}
        #date
        date=$(date '+%Y%m%d-%H.%M')
        #new dir
        dir=$bk_path/$task-$date.mrb
#       echo $task $last $serv $path $dir;
        if [ "$p" == "www" ]; then
                exclude="--exclude-from=$www_exclude"
        elif [ "$p" == "isp" ]; then
                exclude="--exclude-from=$isp_exclude"
        else
                exclude=''
        fi

        echo "$date start backup $task" >> /root/files_backup.log
        echo "########## $date start backup $task ###########" >> /root/files_backup.$task.log
        rsync --super -ahivS --link-dest=$last --bwlimit=$bandwith_limit -e 'ssh' --rsync-path='nice -n19 ionice -c3 rsync' $exclude $serv:$path $dir >> /root/files_backup.$task.log
        echo -e "\n\n\n" >> /root/files_backup.$task.log
        echo -e "$(date '+%Y%m%d-%H.%M') end   backup $task\n\n" >> /root/files_backup.log
done


# remove old
if [ -z "$1" ]; then
        /root/backups_remover.sh
fi
