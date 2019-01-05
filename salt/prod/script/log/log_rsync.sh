#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh

opts="-avz"
rsa="/root/.ssh/backup_rsa"
rsync_log=$log_bak_dir/rsync_${ymd}.log
ruser="backup"
rip=172.16.2.95
random_time=$(($RANDOM%1800))

test -d $log_bak_dir || mkdir -p $log_bak_dir
ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip mkdir -p $log_bak_dir/$HOSTNAME
# 防止多台同时同步造成io紧张
sleep $random_time

# rsync nginx日志
[ -d /var/log/nginx ] && {
    rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /var/log/nginx/*.gz $ruser@$rip:$log_bak_dir/$HOSTNAME/nginx
}

# rsync tomcat日志
project_dirs=$(ls -1 /usr/local | grep tomcat)
for project_dir in $project_dirs
do
    if [[ $project_dir =~ tomcat_shanghu ]];then
        rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /usr/local/$project_dir/logs/catalina.out-*.gz $ruser@$rip:$log_bak_dir/$HOSTNAME/$project_dir
    else
        rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /usr/local/$project_dir/logs/*.gz $ruser@$rip:$log_bak_dir/$HOSTNAME/$project_dir
    fi
done

# rsync mysql-bin日志
[ -d /var/lib/mysql ] && {
    rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /var/lib/mysql/mysql-bin.* $ruser@$rip:$log_bak_dir/$HOSTNAME
}

# 删除rsync日志
find $log_bak_dir -maxdepth 1 -type f -name "rsync_*" -mtime +15 -exec rm -f {} \;
