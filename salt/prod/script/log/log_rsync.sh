#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh

opts="-avz"
rsa="/root/.ssh/backup_rsa"
rsync_log=$log_bak_dir/log_rsync_${ymd}.log
ruser="backup"
rip=172.16.2.99
random_time=$(($RANDOM%1000))
remote_bak_dir="/data/remote_backup"

test -d $log_bak_dir || mkdir -p $log_bak_dir
# 防止多台同时同步造成io紧张
sleep $random_time

# rsync cmd.log日志
ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip "mkdir -p $bak_dir/cmd.log/$HOSTNAME"
rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /var/log/cmd.log* $ruser@$rip:$bak_dir/cmd.log/$HOSTNAME


# rsync nginx日志
[ -d /var/log/nginx ] && {
    ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip "mkdir -p $remote_bak_dir/logs/nginx/$HOSTNAME"
    rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /var/log/nginx/*.gz $ruser@$rip:$remote_bak_dir/logs/nginx/$HOSTNAME
}

# rsync tomcat日志
for project_dir in $(ls -1 /usr/local | grep tomcat)
do
    ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip "mkdir -p $remote_bak_dir/logs/$project_dir/$HOSTNAME"
    rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /usr/local/$project_dir/logs/catalina.out-*.gz $ruser@$rip:$remote_bak_dir/logs/$project_dir/$HOSTNAME
done

# rsync bluecloud日志
for project_dir in $(ls -1 /usr/local/bluecloud/logs)
do
    ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip "mkdir -p $remote_bak_dir/logs/$project_dir/$HOSTNAME"
    rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /usr/local/bluecloud/logs/$project_dir/applog.log.* $ruser@$rip:$remote_bak_dir/logs/$project_dir/$HOSTNAME
done


# 删除rsync日志
find $log_bak_dir -maxdepth 1 -type f -name "log_rsync_*" -mtime +15 -exec rm -f {} \;
