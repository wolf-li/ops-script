#!/bin/env bash
#
# 时间: 【年-月-日】
# 版本: 0.1
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：简单处理 nginx 日志
# 访问最多的 IP
# 访问最多的页面
# 访问页面的状态码数量
# 根据时间段来查看 IP
# uv 用户访问次数（天）
# pv 总页面访问次数（天）
# 脚本使用： ./nginx_log_analyse.sh

LOG_FILE=$1
start_time=$2
end_time=$3
echo "account most visited IP"
awk '{a[$1]++}END{print "PV:",length(a);for(v in a)print v,a[v]}' $LOG_FILE | sort -k2 -nr | head
echo "-----------------------"
echo "Today a certain period of time is the most frequently visited IP"
grep "$(date +%d/%b/%Y):[$start_time-$end_time]" $LOG_FILE | awk '{print $1}' | sort | uniq -c | sort -nr | wc -l
echo "-----------------------"
echo "account most visited page"
awk '{a[$7]++}END{print "UV:",length(a);for(v in a){if(a[v]>10)print v,a[v]}' $LOG_FILE | sort -k2 -nr
echo "-----------------------"
echo "account most visited page http_code"
awk '{a[$7" "$9]++}END{for(v in a){if(a[v]>5)print v,a[v]}}' $LOG_FILE | sort -k3 -nr







