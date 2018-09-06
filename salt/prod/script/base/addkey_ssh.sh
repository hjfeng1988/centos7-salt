#!/bin/bash
# Dete:2018/04/14
# Description:添加用户公钥到~/.ssh/authorized_keys

# 打印红色字体
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

user="$1"
group="$2"
user_sshkey="${user}_sshkey"

hjfeng_sshkey="ssh-rsa AAAAB3NzaC1yc2EAAA..."

# 判断脚本传参，打印脚本用法
[[ "$#" -ne 2 ]] && {
    echo_red "Wrong number of argvs"
    echo_red "Usage: $0 {hjfeng|lzl...} {admin|super|tomcat|ftp}"
    exit 1
}

# 检查用户是否在上文的提供范围内
[[ -z ${!user_sshkey} ]] && {
    echo_red "Warning:Undefine user"
    exit 1
}

# 限定group组只能为super|ftp|tomcat|admin
[[ ! "$group" =~ ^(admin|super|tomcat|ftp)$ ]] && {
    echo_red "Warning:Undefine group"
    exit 1
}

# 限制admin只能添加hjfeng
[[ "$group" == "admin" && ! "$user" =~ ^(hjfeng|lzl)$ ]] && {
    echo_red "Warning:Only user of hjfeng|lzl can add in group of admin" 
    exit 1
}

# 保证/etc/sudoers有以下内容
#Cmnd_Alias DELEGATING = /usr/sbin/visudo, /bin/chown, /bin/chmod, /bin/chgrp
#%admin        ALL=(ALL)        NOPASSWD: ALL
#%super        ALL=(ALL)        NOPASSWD: ALL,!DELEGATING

# 检查用户组是否已存在
getent group $group &> /dev/null || {
    echo_red "Warning:group $group does not exists on system"
    exit 1
}

# 检查用户是否已存在
if id $user &> /dev/null;then
    usermod $user -g $group
else
    useradd $user -g $group
fi

# 添加公钥
mkdir -p /home/$user/.ssh
echo "${!user_sshkey}" > /home/$user/.ssh/authorized_keys
chown -R $user:$group /home/$user/.ssh
chmod 700 /home/$user/.ssh
echo_green "addkey $user sucess!"
