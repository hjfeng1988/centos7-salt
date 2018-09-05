#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh
source /data/script/secret_vars.sh

dbs=$(mysql -u$mysql_user -p$mysql_pass -Nse "show databases;" | grep -Ev "information_schema|performance_schema|mysql|te?mp|bluestore_core_log")

test -d $mysql_bak_dir || mkdir -p $mysql_bak_dir
for db in $dbs
do
	mysqldump -u$mysql_user -p$mysql_pass $db > $mysql_bak_dir/${db}_$ymd.sql
    find $mysql_bak_dir -maxdepth 1 -type f -name "$db*" -mtime +15 -exec rm -f {} \;
done
