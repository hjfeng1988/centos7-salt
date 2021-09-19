#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh

opts="-avz"
rsa="/root/.ssh/backup_rsa"
rsync_log=$log_bak_dir/web_rsync_${ymd}.log
ruser="backup"
rip=172.16.2.99
random_time=$(($RANDOM%1000))
remote_bak_dir="/data/remote_backup"

test -d $log_bak_dir || mkdir -p $log_bak_dir
# 防止多台同时同步造成io紧张
sleep $random_time

# rsync nginx配置
ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip "mkdir -p $remote_bak_dir/web/${HOSTNAME}"
rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log $web_bak_dir/nginx_conf_* $ruser@$rip:$remote_bak_dir/web/${HOSTNAME}

# 删除rsync日志
find $log_bak_dir -maxdepth 1 -type f -name "web_rsync_*" -mtime +15 -exec rm -f {} \;
