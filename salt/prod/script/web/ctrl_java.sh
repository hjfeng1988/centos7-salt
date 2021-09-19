#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh

# 脚本用法
function usage(){
    echo "脚本用法：$0 -p project -a update"
    echo "-p:"
    echo "    module-partner"
    echo "    service-notification"
    echo "    bluestore-uaa"
    echo "-a:"
    echo "    update   更新"
    echo "    offline  下线"
    echo "    online   上线"
    echo "-t:"
    echo "    10       下线等待时长"
    exit 1
}

# 获取pid
function get_pid(){
    pid=$(ps -ef | grep java | grep "$project" | grep -v $0 | awk '{print $2}')
}

# 下载
function download(){
    [ -d $update_dir ] || mkdir -p $update_dir
    if [ -f $update_dir/$project-1.0.0.jar ];then
        echo "使用本机的更新文件"
    else
        echo "开始下载更新文件"
        wget -Nq -t2 --connect-timeout=5 http://$ftp_server/bluecloud/$project-1.0.0.jar -O $update_dir/$project-1.0.0.jar
        if [ $? -ne 0 ];then
            echo "下载失败，请重试"
            rm -f $update_dir/$project-1.0.0.jar
            exit 1
        fi
    fi
}

# 下线
function offline(){
    get_pid
    if [ -z "$pid" ];then
        echo "服务已经关闭了，跳过下线"
    elif [ $project == "bluestore-gateway" ];then
        port=$(netstat -nltp | awk "/$pid/{print \$4}" | awk -F: '{print $NF}')
        down_url="http://127.0.0.1:$port/deploy/status"
        curl -s -X DELETE $down_url
        echo "开始下线，等待${sleep_time:-10}秒"
        sleep ${sleep_time:-10}
    else
        port=$(netstat -nltp | awk "/$pid/{print \$4}" | awk -F: '{print $NF}')
        down_url="http://127.0.0.1:$port/actuator/service-registry"
        curl -s -X POST -H "Content-Type:application/json" -d '{"status":"DOWN"}' $down_url
        echo "开始下线，等待${sleep_time:-10}秒"
        sleep ${sleep_time:-10}
    fi
}

# 停止
function stop(){
    get_pid
    if [ -z "$pid" ];then
        echo "服务已经关闭了"
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

# 更新
function update(){
    rm -f lib/$project-1.0.0.jar
    mv $update_dir/$project-1.0.0.jar lib
    echo "更新完成"
}

# 启动
function start(){
    get_pid
    if [ -n "$pid" ];then
        echo "服务已经启动了"
    else
        echo "开始启动"
        mkdir -p logs/$project
        nohup java $JAVA_OPTS -jar lib/$project-1.0.0.jar $APPLICATION_OPTS &>> logs/$project/catalina.out &
    fi
}

# 服务检测
function check(){
    echo "等待服务检测"
    sleep 20
    for((i=1;i<10;i++))
    do
        sleep 5
        get_pid
        [ -z "$pid" ] && { echo "服务检测失败，详情查看日志";exit 1; }
        port=$(netstat -nltp | awk "/$pid/{print \$4}" | awk -F: '{print $NF}')
        [ -z "$port" ] && { echo "第$i次服务检测失败，服务还未监听端口";continue; }
        if [ $project == "bluestore-eureka" ];then
            echo "服务检测成功"
            break
        else
            check_url="http://127.0.0.1:$port/actuator/health"
            status=$(curl -s $check_url | python -m json.tool | tail -n2 | awk -F': ' '/status/{print $2}')
            if [ "$status" == '"UP"' ];then
                echo "服务检测成功"
                break
            else
                echo "第$i次服务检测失败，等待重新检测"
                if [ $i -ge 5 ];then
                    echo "服务检测失败次数过多，详情请查看日志或者以下内容"
                    curl -s $check_url | python -m json.tool
                    exit 1
                fi
            fi
        fi
    done
}

# 上线
function online(){
    echo "开始上线"
}

# 检测选项，参数赋值
ARGS=`getopt -o p:a:t: -n 'example.bash' -- "$@"`
[ $? -ne 0 ] && usage
eval set -- "$ARGS"
while true
do
    case "$1" in
        -p) project=$2; shift 2;;
        -a) action=$2; shift 2;;
        -t) ! [[ $2 =~ ^[1-9][0-9]*$ ]] && { echo "$2不是可用数字";exit 1; }; sleep_time=$2; shift 2;;
        --) shift; break;;
        *) usage;;
    esac
done

# 判断-p参数
if [ -z "$project" ];then
    echo "选项-p的参数不能为空"
    usage
else
    cd /usr/local/bluecloud
    if [ -f setenv-$project.sh ];then
        source setenv-$project.sh
    elif [ -f setenv.sh ];then
        source setenv.sh
    else
        echo "找不到setenv.sh"
        exit 1
    fi
fi

# 判断-a参数
case $action in
    update)
        download
        get_pid
        offline
        stop
        update
        start
        check
        online
        ;;
    offline)
        offline;;
    start)
        start;;
    stop)
        stop;;
    restart)
        stop
        start;;
    check)
        check;;
    *)
        echo "选项-a的参数未知"
        usage
        ;;
esac
