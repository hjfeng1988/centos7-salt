#!/bin/bash
# Filename:jstack.sh
# Description:This script use to find some information of java therad when cpu run high load

read run_user java_pid <<< $(ps aux | grep java | grep -v grep | sort -nk3 | tail -n1 | awk '{print $1,$2}')
if [[ -z $java_pid ]];then
    echo "There is no java process running"
    exit
else
    hex_tid=$(ps H -o THREAD,tid,time --sort=-%cpu -p $java_pid | awk 'NR==2{printf("0x%x\n",$8)}')
fi

echo -e "\033[31mtop 1 cpu's PID:\033[0m"
echo "$java_pid"
echo -e "\033[31mtop 10 cpu's tid of pid:\033[0m"
ps H -o THREAD,tid,time --sort=-%cpu -p $java_pid | head -n10
echo -e "\033[31mtop 1 cpu's stack of pid:\033[0m"
if [[ $run_user == "root" ]];then
    /usr/local/jdk/bin/jstack $java_pid | sed -n "/$hex_tid/,/^$/p"
else
    sudo -u $run_user /usr/local/jdk/bin/jstack $java_pid | sed -n "/$hex_tid/,/^$/p"
fi
