#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh
source /data/script/secret_vars.sh

instances="172.16.3.103 172.16.3.104"
for instance in $instances
do
    dbs=$(mysql -h$instance -u$mysql_user -p$mysql_pass -Nse "show databases;" | grep -Ev "information_schema|mysql|performance_schema|sys|te?mp|zabbix")

    test -d $mysql_bak_dir || mkdir -p $mysql_bak_dir
    for db in $dbs
    do
        mysqldump --single-transaction --set-gtid-purged=OFF -h$instance -u$mysql_user -p$mysql_pass $db | gzip > $mysql_bak_dir/${db}_$ymd.sql.gz
        # 删除n天前的备份
        find $mysql_bak_dir -maxdepth 1 -type f -name "$db*" -mtime +7 -exec rm -f {} \;
    done
done
