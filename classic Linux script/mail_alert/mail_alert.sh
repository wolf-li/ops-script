#!/bin/env bash
#
# 时间: 10-25-2021
# 版本: 0.1
# 作者: li
#
# 脚本名称：mail_alert.sh 
# 脚本灵感来源: http://www.ruanyifeng.com/blog/2018/03/systemd-timer.html
# 脚本可以完成的任务：
#   使用 systemd 对服务进行控制，出现问题使用邮件进行告警
# 脚本使用：
# 
mail_list=(
    [e-mail]
    [e-mail]
    [e-mail]
    ....
)

service=$1
now=$(date +%Y-%m-%d' '%H:%M)
host_ip=$(ip a| grep "global"| awk '{print $2}'| awk -F / '{print $1}' )
if [ ! -n "${host_ip}" ];then 
        host_ip=$(ip a| grep "global e"| awk '{print $2}'| awk -F / '{print $1}')
fi

systemctl status ${service} | /usr/bin/mailx -v -s "[$host_ip] [$now] [${service}] failure notification" ${mail_list[*]}

