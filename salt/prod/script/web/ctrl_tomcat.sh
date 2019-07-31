#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh

# 脚本用法
function usage(){
    echo "脚本用法：$0 -p tomcat_shanghu -a update"
    echo "-p:"
    echo "    tomcat_shanghu"
    echo "    tomcat_weixin"
    echo "    tomcat_life"
    echo "-a:"
    echo "    update   更新"
    echo "    offline  下线"
    echo "    online   上线"
    echo "-t:"
    echo "    10       下线睡眠时间"
    echo "-c:"
    echo "    http://127.0.0.1:port/deploy/status 服务检测地址"
    exit 1
}

# 下载
function download(){
    [ -d $update_dir/$project ] || mkdir -p $update_dir/$project
    if [ -f $update_dir/$project/ROOT.war ];then
        echo "使用本机的更新文件"
    else
        echo "开始下载更新文件"
        if [ $project == "shanghu-job" ];then
            wget -Nq -t2 --connect-timeout=5 http://$ftp_server/shanghu/ROOT.war -O $update_dir/$project/ROOT.war
        else
            wget -Nq -t2 --connect-timeout=5 http://$ftp_server/${project%[0-9]*}/ROOT.war -O $update_dir/$project/ROOT.war
        fi
        if [ $? -ne 0 ];then
            echo "下载失败，请重试"
            rm -f $update_dir/$project/ROOT.war
            exit 1
        fi
    fi
}

# 下线
function offline(){
    port=$(grep -oP '(?<=<Connector port=")\d+(?=" protocol="HTTP)' $project_dir/conf/server.xml)
    down_url="http://127.0.0.1:$port/deploy/status"
    curl -s -X DELETE $down_url
    echo "开始下线，等待${sleep_time:-10}秒"
    sleep ${sleep_time:-10}
}

# 更新
function update(){
    rm -rf $project_dir/webapps/ROOT*
    mv $update_dir/$project/ROOT.war $project_dir/webapps/
    echo "更新完成"
}

# 服务检测
function check(){
    echo "等待服务检测"
    sleep 20
    for((i=1;i<10;i++))
    do
        sleep 5
        port=$(grep -oP '(?<=<Connector port=")\d+(?=" protocol="HTTP)' $project_dir/conf/server.xml)
        check_url=${check_url:-http://127.0.0.1:$port/deploy/status}
        http_code=$(curl --connect-timeout 3 -m 5 -sI -o /dev/null -w %{http_code} $check_url)
        if [ "$http_code" -eq 200 ];then
            echo "服务检测成功"
            break
        else
            echo "第$i次服务检测失败，等待重新检测"
            if [ $i -ge 5 ];then
                echo "服务检测失败次数过多，详情请查看日志"
                exit 1
            fi
        fi 
    done
}

# 上线
function online(){
    echo "开始上线"
}

# 备份
function backup(){
    [ -d $web_bak_dir ] || mkdir -p $web_bak_dir
    echo "项目备份至:$web_bak_dir/${project}_${ymd}_${hm}"
    mv $project_dir/webapps/ROOT $web_bak_dir/${project}_${ymd}_${hm}
}

#回滚
function rollback(){
    if [ -e "$web_bak_dir/${project}_previous_version" ];then
        previous_version=$(cat $web_bak_dir/${project}_previous_version)
        if [ ! -d "$web_bak_dir/$previous_version" ];then
            echo "上一版本不存在"
            exit 1;
        fi
    else
        echo "记录上一版本的文件不存在"
        exit 1
    fi
    echo "项目回滚至上一版本:$web_bak_dir/$previous_version"
    cp -a $web_bak_dir/$previous_version $project_dir/webapps/ROOT
    chown -R tomcat:tomcat $project_dir/webapps/ROOT
}

# 检测选项，参数赋值
ARGS=`getopt -o p:a:c:t: -n 'example.bash' -- "$@"`
[ $? -ne 0 ] && usage
eval set -- "$ARGS"
while true;do
    case "$1" in
        -p) project=$2; shift 2;;
        -a) action=$2; shift 2;;
        -c) check_url=$2; shift 2;;
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
    project_dir=/usr/local/tomcat_$project
    if [ ! -d "$project_dir/webapps" ];then
        echo "$project_dir下不存在webapps目录，不是有效的tomcat目录"
        exit 1
    fi
fi

# 判断-a参数
case $action in
    update)
        download
        offline
        echo "停止tomcat..."
        systemctl stop tomcat_$project
        if [[ $project =~ shanghu ]];then
            backup
            echo "${project}_${ymd}_${hm}" > $web_bak_dir/${project}_previous_version
            find $web_bak_dir -maxdepth 1 -type d -mtime +3 -exec rm -rf {} \;
        fi
        update
        echo "启动tomcat..."
        systemctl start tomcat_$project
        check
        online
        ;;
    offline)
        offline;;
    online)
        online;;
    rollback)
        if [[ ! $project =~ tomcat_shanghu ]];then
            echo "只有tomcat_shanghu项目支持rollback"
            exit 1
        fi
        offline
        echo "停止tomcat..."
        systemctl stop $project
        backup
        rollback
        echo "启动tomcat..."
        systemctl start $project
        check
        online
        ;;
    *)
        echo "选项-a的参数未知"
        usage
        ;;
esac
