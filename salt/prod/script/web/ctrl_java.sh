#!/bin/bash
# PATH变量
JAVA_HOME=/usr/local/jdk
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:$JAVA_HOME/bin

service=$1
action=$2

function usage(){
    echo "脚本用法: $0 service action"
    echo "    service:{module-partner|service-notification}"
    echo "    action:{start|stop|update}"
    exit 1
}

function get_pid(){
    pid=$(ps -ef | grep java | grep "$service" | grep -v $0 | awk '{print $2}')
}

function start(){
    get_pid
    if [ -n "$pid" ];then
        echo "$service已经启动了"
    else
        echo "开始启动"
        nohup java $JAVA_OPTS -jar lib/$service-1.0.0.jar $APPLICATION_OPTS --spring.config.location=conf/$service.yml --logging.config=conf/logback-spring.xml &>> logs/catalina-$service.log &
    fi
}

function stop(){
    get_pid
    if [ -z "$pid" ];then
        echo "$service已经关闭了";
    else
        kill $pid
        echo -n "开始关闭"
        while :
        do
            for((j=0;j<3;j++))
            do
                echo -n "."
                sleep 1
            done
            get_pid
            [ -z "$pid" ] && { echo "";echo "关闭成功";break; }
        done
    fi
}

function update(){
    rm -f lib/$service-1.0.0.jar
    mv /data/update/$service-1.0.0.jar lib
    echo "更新完成"
}

# 判断脚本参数个数
[ "$#" -lt 2 ] && { echo "脚本参数个数出错，至少2个";usage; }

cd /usr/local/bluecloud
if [ -f ${service}-setenv.sh ];then
    source ${service}-setenv.sh
elif [ -f setenv.sh ];then
    source setenv.sh
else
    echo "找不到setenv.sh"
    exit 1
fi

case $action in
    update)
        ! [ -f /data/update/$service-1.0.0.jar ] && { echo "更新包不存在";exit 1; }
        stop
        update
        start;;
    start)
        start;;
    stop)
        stop;;
    *)
        echo "未定义的action"
        usage
        ;;
esac
