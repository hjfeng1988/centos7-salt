#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh
source /data/script/secret_vars.sh

dbs=$(mysql -u$mysql_user -p$mysql_pass -Nse "show databases;" | grep -Ev "information_schema|mysql|performance_schema|sys|te?mp|bluestore_core_log")


test -d $mysql_bak_dir || mkdir -p $mysql_bak_dir
for db in $dbs
do
    mysqldump --set-gtid-purged=OFF --single-transaction -u$mysql_user -p$mysql_pass $db | gzip > $mysql_bak_dir/${db}_$ymd.sql.gz
    # 删除n天前的备份
    find $mysql_bak_dir -maxdepth 1 -type f -name "$db*" -mtime +10 -exec rm -f {} \;
done
