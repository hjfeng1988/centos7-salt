#!/bin/bash
# Filename:jstack.sh
# Description:This script use to find some information of java therad when cpu run high load

read run_user java_pid <<< $(ps axo user:20,pid,pcpu,pmem,cmd --sort=pcpu | grep [j]ava | awk 'END{print $1,$2}')
if [[ -z $java_pid ]];then
    echo "There is no java process running"
    exit
else
    java_tid=$(ps H -o tid,THREAD --sort=pcpu -p $java_pid | awk 'END{print $1}')
    hex_tid=$(echo $java_tid | awk '{printf("0x%x\n",$0)}')
fi

echo -e "\033[31mtop 3 cpu's PID:\033[0m"
ps axo user:20,pid,ppid,pcpu,pmem,cmd --sort=-pcpu | head -n4

echo -e "\033[31mtop 10 cpu's tid of pid:\033[0m$java_pid"
ps H -o tid,THREAD --sort=-pcpu -p $java_pid | head -n11

echo -e "\033[31mstack of tid:\033[0m$java_tid"
if [[ $run_user == $USER ]];then
    cmd="/usr/local/jdk/bin/jstack"
else
    cmd="sudo -u $run_user /usr/local/jdk/bin/jstack"
fi
$cmd $java_pid | sed -n "/$hex_tid/,/^$/p"
