#!/bin/bash
# PATH变量
JAVA_HOME=/usr/local/jdk
MYSQL_HOME=/usr/local/mysql
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:$JAVA_HOME/bin:$MYSQL_HOME/bin

# 时间变量
ymd=$(date +%Y%m%d)
hm=$(date +%H%M)
day_of_week=$(date +%u)

# 数据目录变量
web_dir=/data/web
log_dir=/data/logs
mysql_dir=/data/mysql
update_dir=/data/update
script_dir=/data/script

# 备份目录变量
bak_dir=/data/backup
web_bak_dir=$bak_dir/web
log_bak_dir=$bak_dir/logs
mysql_bak_dir=$bak_dir/mysql

ftp_server=ftp.your.cn

# 字体打印红色
function echo_red()
{
    echo -ne "\033[1;31m"
    echo -n "$1"
    echo -e "\033[0m"
}
# 打印绿色字体
function echo_green()
{
    echo -ne "\033[1;32m"
    echo -n "$1"
    echo -e "\033[0m"
}
