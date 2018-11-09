#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh
source /data/script/secret_vars.sh

db=yourdb
tables="courier user_address user_finance user_function user_info user_zone zone"

test -d $mysql_bak_dir || mkdir -p $mysql_bak_dir
mkdir $mysql_bak_dir/${db}_${ymd}_${hm}

for table in $tables
do
    mysqldump -u$mysql_user -p$mysql_pass $db $table > $mysql_bak_dir/${db}_${ymd}_${hm}/${table}.sql
done

find $mysql_bak_dir -maxdepth 1 -type d -name "$db*" -mtime +30 -exec rm -rf {} \;
