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
ssh -o StrictHostKeyChecking=no -i $rsa $ruser@$rip mkdir -p $mysql_bak_dir/$HOSTNAME
# 防止多台同时同步造成io紧张
sleep $random_time
rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log $mysql_bak_dir/ $ruser@$rip:$mysql_bak_dir/$HOSTNAME

# 删除rsync日志
find $log_bak_dir -maxdepth 1 -type f -name "rsync_*" -mtime +15 -exec rm -f {} \;
