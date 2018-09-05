#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh
source /data/script/secret_vars.sh

project=$1
action=$2
update_file=$3
project_dir=/usr/local/tomcat_$project
project_data_dir=$web_dir/tomcat_$project/${update_file%%.*}
project_data_link_dir=$project_dir/webapps/ROOT


# 脚本用法
function usage(){
    echo_red "脚本用法：$0 project atcion"
    echo "       project:{shanghu|weixin|jidian|...}"
    echo "       action:{start|stop|restart|stauts}"
    echo_red "全量更新用法：$0 project update update_file"
    echo "       update_file:{ROOT_20170110_001.zip|ROOT_20170110_002.zip|...}"
    echo "       更新并重启服务"
    echo_red "增量更新用法：$0 project inc_update update_file"
    echo "       update_file:{ROOT_20170110_001.zip|ROOT_20170110_002.zip|...}"
    echo "       只更新不重启服务"
    exit 1
}

# 更新时，脚本传参检测
function check_file(){
    # 判断update_file前缀
    [[ "${update_file%%.*}" =~ ^ROOT_[0-9]{8}_[0-9]{3}$ ]] || {
        echo_red "$update_file 日期版本号出错，格式必须如下："
        echo_red "ROOT_20170303_001"
        exit 1
    }
    
    # 判断update_file后缀
    [ "${update_file##*.}" != "zip" ] && {
        echo_red "$update_file 文件名后缀出错，格式必须如下："
        echo_red ".zip"
        exit 1
    }
    
    # 判断版本是否存在
    [[ "$action" == "update" && -d $project_data_dir ]] && {
        echo_red "$project_data_dir 版本已存在，不能更新."
        exit 1
    }
}

# 下载更新文件
function download(){    
    # 下载update_file
    [ -d $update_dir ] || mkdir -p $update_dir
    cd $update_dir    
    http_code=$(curl -sI http://$http_user:$http_pass@$ftp_server/${project%%_*}/$update_file | awk 'NR==1{print $2}')
    if [ $http_code -eq 200 ];then
        wget -N http://$http_user:$http_pass@$ftp_server:/${project%%_*}/$update_file
        [ $? -ne 0 ] && {
            echo_red "下载失败，请重试."
            exit 1
        }
    else
        if [ -e $update_file ];then
            echo "更新将使用本机文件：$update_dir/$update_file"
        else
            echo_red "请确保更新包已完整上传至FTP服务器${project%%_*}目录下"
            exit 1
        fi
    fi
    
    # 判断update_file压缩后的首目录名
    unzip -l $update_file | awk 'NR==4{print $NF}' | grep -q "^ROOT/$" || {
        echo_red "$update_file 文件解压后首目录出错，格式必须如下："
        echo_red "ROOT/"
        exit 1
    }
}

# 全量更新
function update(){
    # 解压新版本
    [ -d $web_dir/tomcat_$project ] || mkdir -p $web_dir/tomcat_$project
    unzip -q $update_dir/$update_file -d $web_dir/tomcat_$project
    mv $web_dir/tomcat_$project/ROOT $project_data_dir
    
    # 商户项目段落
    if [ "$project" == "shanghu" ];then
        \cp $project_data_link_dir/WEB-INF/classes/application.properties $project_data_dir/WEB-INF/classes/
    elif [ "$project" == "weixin" ];then
        echo "todo"
    fi
    
    # 修改软链接
    if [ -L $project_data_link_dir ];then
        rm $project_data_link_dir -f
    else
        mv $project_data_link_dir $web_dir/tomcat_$project/ROOT_${ymd}_${hm}
    fi
    ln -s $project_data_dir $project_data_link_dir
    echo_green "全量更新已完成."
}

# 增量更新、备份
function inc_update(){
    # 获取要更新的文件列表
    temp_file=$update_dir/file_list
    unzip -l $update_dir/$update_file | head -n-2 | awk 'NR>3&&/[^/]$/{print $NF}' > $temp_file
    
    # 增量更新前，备份文件
    [ -d $web_bak_dir ] || mkdir -p $web_bak_dir
    cd $project_dir/webapps
    tar zcf $web_bak_dir/inc_update_${project}_${ymd}_${hm}.tgz -T $temp_file --ignore-failed-read |& head -n3
    echo_green "备份文件在：$web_bak_dir/inc_update_${project}_${ymd}_${hm}.tgz"
    rm -f $temp_file
    
    # 增量更新
    unzip -qo $update_dir/$update_file -d $project_dir/webapps
    echo_green "增量更新已完成."
}

# 判断参数个数
[ "$#" -lt 2 ] && { echo_red "脚本参数个数出错，至少2个.";usage;}

# 判断项目目录是否存在
[ ! -d $project_dir ] && { echo_red "$project_dir 目录不存在，请检查.";exit 1;}

# 判断action变量
case $action in
    start)
        systemctl start tomcat;;
    stop)
        systemctl stop tomcat;;
    restart)
        systemctl restart tomcat;;
    status)
        systemctl status tomcat;;
    update)
        # 若action为update,参数只能3个
        [ "$#" -ne 3 ] && {
            echo_red "脚本参数个数出错，全量更新时只能是3个."
            usage
        }
        check_file
        download
        # 确定是否更新
        read -p "确认更新请输入yes，其他值退出:" flag
        [ "$flag" != "yes" ] && {
            echo_red "输入的不是yes"
            exit 1
        }
        systemctl stop tomcat
        update
        systemctl start tomcat
        ;;
    inc_update)
        # 若action为inc_update,参数只能3个
        [ "$#" -ne 3 ] && {
            echo_red "脚本参数个数出错，增量更新时只能是3个."
            usage
        }
        check_file
        download
        inc_update
        ;;
    *)
        echo_red "未定义的action"
        usage
        ;;
esac
