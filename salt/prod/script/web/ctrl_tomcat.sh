#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh

# 脚本用法
function usage(){
    echo "脚本用法：$0 -d /usr/local/tomcat_shanghu -a update"
    echo "-d:"
    echo "    /usr/local/tomcat_shanghu"
    echo "    /usr/local/tomcat_shanghu_job"
    echo "-a:"
    echo "    update   备份更新"
    echo "    rollback 备份回滚"
    echo "-t:"
    echo "    10 上下线睡眠时间，默认10秒"
    echo "--check_url:"
    echo "    \$check_url 服务检测地址"
    exit 1
}

# 下载
function download(){
    [ -d $update_dir/$project ] || mkdir -p $update_dir/$project
    cd $update_dir/$project

    if [ -f $update_dir/$project/ROOT.war ];then
        echo "使用本机的更新文件"
    else
        wget -Nq http://$ftp_server/$project/ROOT.war
        [ $? -ne 0 ] && { echo "下载失败，请重试";exit 1; }
    fi
}

# 下线
function offline(){
    echo "开始下线，等待${sleep_time:-10}秒"
    rm -f $project_dir/webapps/ROOT/online.html
    sleep ${sleep_time:-10}
}

# 备份
function backup(){
    [ -d $web_bak_dir ] || mkdir -p $web_bak_dir
    echo "项目备份至:$web_bak_dir/${project}_${ymd}_${hm}"
    mv $project_dir/webapps/ROOT $web_bak_dir/${project}_${ymd}_${hm}
}

# 更新
function update(){
    echo "${project}_${ymd}_${hm}" > $web_bak_dir/${project}_previous_version
    rm -f $project_dir/webapps/ROOT.war
    mv $update_dir/$project/ROOT.war $project_dir/webapps/
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
}

#tomcat服务检测
function service_check() {
    sleep 20
    for((i=1;i<10;i++))
    do
        sleep 5
        http_code=$(curl --connect-timeout 3 -m 5 -sI -o /dev/null -w %{http_code} ${check_url:-http://127.0.0.1:8081/server/express/getTempData.htm})
        if [ "$http_code" -eq 200 ];then
            echo "tomcat服务检测成功"
            break
        else
            echo "第$i次tomcat服务检测失败，等待重新检测"
            [ $i -ge 5 ] && { echo "tomcat服务检测失败次数过多，详情请查看tomcat日志";exit 1; }
        fi
    done
}

# 上线
function online(){
    echo "开始上线"
    touch $project_dir/webapps/ROOT/online.html
}

# 检测选项，参数赋值
ARGS=`getopt -o a:d:t: -l check_url: -n 'example.bash' -- "$@"`
[ $? -ne 0 ] && usage
eval set -- "$ARGS"
while true;do
    case "$1" in
        -d) project_dir=$2; shift 2;;
        -a) action=$2; shift 2;;
        -t) ! [[ $2 =~ ^[1-9][0-9]*$ ]] && { echo "$2不是可用数字";exit 1; }; sleep_time=$2; shift 2;;
        --check_url) check_url=$2; shift 2;;
        --) shift; break;;
        *) usage;;
    esac
done

# 判断-d参数
if [ -z "$project_dir" ];then
    echo "选项-d的参数为空"
    usage
else
    if [ ! -d "$project_dir/webapps" ];then
        echo "$project_dir下不存在webapps目录，不是有效的tomcat目录"
        exit 1
    fi
fi
project=$(basename $project_dir)

# 判断-a参数
case $action in
    update)
        download
        offline
        echo "停止tomcat..."
        systemctl stop $project
        backup
        update
        echo "启动tomcat..."
        systemctl start $project
        service_check
        online
        ;;
    rollback)
        offline
        echo "停止tomcat..."
        systemctl stop $project
        backup
        rollback
        echo "启动tomcat..."
        systemctl start $project
        service_check
        online
        ;;
    *)
        echo "未定义的action"
        usage
        ;;
esac
