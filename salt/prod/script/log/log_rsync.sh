#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh

opts="-avz"
rsa="/root/.ssh/backup_rsa"
rsync_log=$log_bak_dir/log_rsync_${ymd}.log
ruser="backup"
rip=172.16.2.95
random_time=$(($RANDOM%1800))
remote_bak_dir="/data/landian-bak"
remote_log_bak_dir="$remote_bak_dir/logs"
test -d $log_bak_dir || mkdir -p $log_bak_dir
# 防止多台同时同步造成io紧张
sleep $random_time
# 这个判断不够准确，是否以backup用户挂载着
ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip "test -d $remote_bak_dir"
[ $? -ne 0 ] && {
    echo "Can't find remote_bak_dir"
    exit 1
}

# rsync nginx日志
[ -d /var/log/nginx ] && {
    ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip "mkdir -p $remote_log_bak_dir/$HOSTNAME/nginx"
    rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /var/log/nginx/*.gz $ruser@$rip:$remote_log_bak_dir/$HOSTNAME/nginx
}

# rsync tomcat日志
project_dirs=$(ls -l /usr/local | awk '/^d/&&$NF~/tomcat/{print $NF}')
for project_dir in $project_dirs
do
    ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip "mkdir -p $remote_log_bak_dir/$HOSTNAME/$project_dir"
    rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /usr/local/$project_dir/logs/catalina.out-*.gz $ruser@$rip:$remote_log_bak_dir/$HOSTNAME/$project_dir
done

# rsync bluecloud日志
[ -d /usr/local/bluecloud ] && {
    ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip "mkdir -p $remote_log_bak_dir/$HOSTNAME/bluecloud"
    rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /usr/local/bluecloud/logs/ $ruser@$rip:$remote_log_bak_dir/$HOSTNAME/bluecloud
}

# rsync mysql-bin日志
[ -d /var/lib/mysql ] && {
    ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip "mkdir -p $remote_log_bak_dir/$HOSTNAME"
    rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log /var/lib/mysql/mysql-bin.* $ruser@$rip:$remote_log_bak_dir/$HOSTNAME
}

# 删除rsync日志
find $log_bak_dir -maxdepth 1 -type f -name "log_rsync_*" -mtime +15 -exec rm -f {} \;
