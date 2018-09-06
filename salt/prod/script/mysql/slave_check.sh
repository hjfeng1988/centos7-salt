#!/bin/bash
# 导入公共变量
source /data/script/common_vars.sh
source /data/script/secret_vars.sh

ips="172.16.2.111 172.16.2.112"
port=3306
tmp_log=/tmp/slave_check.log
tmp_html=/tmp/slave_check.html
mail_py=/data/script/mail.py
mail_to="your@email.com"


function write2html()
{
    if [ ! -f $tmp_html ];then
        echo -e "<html>\n<body>" > $tmp_html
        echo "<h2>mysql主从状态</h2>" >> $tmp_html
        echo '<table border="1" style="border-collapse:collapse" cellpadding="10">' >> $tmp_html
        echo '  <tr>' >> $tmp_html
        echo "    <th>节点</th>" >> $tmp_html
        echo "    <th>mysql_alive</th>" >> $tmp_html
        echo "    <th>Slave_IO_Running</th>" >> $tmp_html
        echo "    <th>Slave_SQL_Running</th>" >> $tmp_html
        echo "    <th>Seconds_Behind_Master</th>" >> $tmp_html
        echo "    <th>异常持续时长</th>" >> $tmp_html
        echo "  </tr>" >> $tmp_html
    fi
    echo "  <tr style=\"background-color:$color\">" >> $tmp_html
    echo "    <td>$1</td>" >> $tmp_html
    echo "    <td>$2</td>" >> $tmp_html
    echo "    <td>$3</td>" >> $tmp_html
    echo "    <td>$4</td>" >> $tmp_html
    echo "    <td>$5</td>" >> $tmp_html
    echo "    <td>$6</td>" >> $tmp_html
    echo "  </tr>"  >> $tmp_html
}

test ! -e $tmp_log && echo "# 检测mysql主从状态临时文件" > $tmp_log
for ip in $ips
do
    grep -q $ip $tmp_log || {
        echo -e "$ip slave_is_error\t0" >> $tmp_log
        echo -e "$ip mysql_is_down\t0" >> $tmp_log
    } 
    check=($(mysql -h$ip -P$port -u$mysql_user -p$mysql_pass --connect-timeout=3 -e "show slave status\G" 2> /dev/null | awk '/Slave_IO_Running|Slave_SQL_Running|Seconds_Behind_Master/{print $2}'))
    if [ -n "$check" ];then
        color="#98FB98"
        error_num=$(awk "/$ip.*mysql/{print \$3}" $tmp_log)
        [[ $error_num -gt 2 ]] && {
            write2html $ip up
            subject="[报警恢复] mysql is up"
        }
        sed -ri "/$ip.*mysql/s/[^\t]+$/0/" $tmp_log
        if [[ ${check[0]} == "Yes" && ${check[1]} == "Yes" && ${check[2]} -lt 60 ]];then
            error_num=$(awk "/$ip.*slave/{print \$3}" $tmp_log)
            if [[ $error_num -gt 2 ]];then
                write2html $ip up ${check[0]} ${check[1]} ${check[2]} "$error_num分钟"
                subject="[报警恢复] slave is ok"
            elif [[ $hm == 1000 ]];then
                write2html $ip up ${check[0]} ${check[1]} ${check[2]} null
                subject="[每日正常] slave is ok"
            fi
            sed -ri "/$ip.*slave/s/[^\t]+$/0/" $tmp_log
        else
            color="#F08080"
            error_num=$(awk "/$ip.*slave/{print \$3}" $tmp_log)
            ((error_num++))
            sed -ri "/$ip.*slave/s/[^\t]+$/$error_num/" $tmp_log
            [[ $error_num -eq 3 || $((error_num%60)) -eq 0 ]] && {
                write2html $ip up ${check[0]} ${check[1]} ${check[2]} "$error_num分钟"
                subject="[报警触发] slave is error"
            }
        fi
    else
        color="#F08080"
        error_num=$(awk "/$ip.*mysql/{print \$3}" $tmp_log)
        ((error_num++))
        sed -ri "/$ip.*mysql/s/[^\t]+$/$error_num/" $tmp_log
        [[ $error_num -eq 2 || $error_num -eq 5 || $((error_num%60)) -eq 0 ]] && {
            write2html $ip down null null null "$error_num分钟"
            subject="[报警触发] mysql is down"
        }
    fi
done

if [ -f $tmp_html ];then
    echo "</table>" >> $tmp_html
    echo -e "</body>\n</html>" >> $tmp_html
    $mail_py $mail_to "$subject" $tmp_html
    rm -f $tmp_html
fi
