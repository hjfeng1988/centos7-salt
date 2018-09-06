#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh

opts="-avz"
rsa="/root/.ssh/backup_rsa"
rsync_log=$log_bak_dir/rsync_${ymd}.log
data_file=$(ls -1 $mysql_bak_dir | grep "$ymd.sql")
ruser="backup"
rip=172.16.2.99
random_time=$(($RANDOM%1800))

test -d $log_bak_dir || mkdir -p $log_bak_dir
# rsync同步
[ -n "$data_file" ] && {
	# 防止多台同时同步造成io紧张
    sleep $random_time
    cd $mysql_bak_dir
    rsync $opts -e "ssh -o StrictHostKeyChecking=no -i $rsa" --log-file=$rsync_log $data_file $ruser@$rip:$mysql_bak_dir
}

# 删除rsync日志
find $log_bak_dir -type f -name "rsync_*" -mtime +15 -exec rm -f {} \;
