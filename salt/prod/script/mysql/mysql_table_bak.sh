#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh
source /data/script/secret_vars.sh

host="172.16.3.18"
db="bluestore_core_db"
tables="courier user_address user_finance user_function user_info user_zone zone user_monthly_finance user_weekly_finance"

test -d $mysql_bak_dir || mkdir -p $mysql_bak_dir
mkdir $mysql_bak_dir/${db}_${ymd}
for table in $tables
do
    mysqldump --single-transaction --set-gtid-purged=OFF -h$host -u$mysql_user -p$mysql_pass $db $table > $mysql_bak_dir/${db}_${ymd}/${table}.sql
done
cd $mysql_bak_dir
tar -zcf ${db}_${ymd}.tgz ${db}_${ymd} --remove-files

# 删除n天前的备份
find $mysql_bak_dir -maxdepth 1 -type f -name "$db*" -mtime +10 -exec rm -f {} \;
