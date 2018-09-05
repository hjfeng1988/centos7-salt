#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh

test -d $web_bak_dir || mkdir -p $web_bak_dir
# 备份nginx配置文件
[ -d /usr/local/nginx ] && {
    cd /usr/local/nginx
    tar zcf $web_bak_dir/nginx_conf_${HOSTNAME}_${ymd}.tgz conf
}

# 删除过期备份
find $web_bak_dir -maxdepth 1 -type f \( -name "full_*" -o -name "nginx_conf_*" \) -mtime +14 -exec rm -f {} \;
