#!/bin/env bash
#
# 时间: 2021-11-10
# 版本: 0.1
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：
# 脚本使用： 

DATE=$(date +%dd/%b/%Y:%H:%M)
UNNORMAL_IP=$(cat access.log | grep $DATE | awk '{a[$1]++}END{for(i in a)if(a[i]>100)print i}')
for IP in $UNNORMAL_IP; do
    if [ $(iptables -vnL | grep -c "$IP") -eq 0 ];then
        iptables -I INPUT -s $IP -j DROP
        echo "$(date +'%F_%T') $IP" >> /tmp/drop.ip
    fi
done

