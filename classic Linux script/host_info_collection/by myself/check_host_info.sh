#!/bin/env bash
#
# 时间: 2022-2-11
# 版本: 0.1
# 作者: li
#
# 脚本名称：
# 脚本灵感来源:
# 脚本可以完成的任务: 检查服务器资源使用情况
# 脚本使用： ./check_host_info.sh

# host.info format
# IP username passwd port
# resive command from outside
# 脚本问题：
# 1. 若无妨登录服务器脚本会卡住
# 2. 登录查看泰国繁琐
# 3. 产出日志需要归档

date=`date +%Y%m%d`
outfile=${date}_check_host_info

OLD_INFO=old_info

echo "服务器IP 总内存 已使用内存 内存使用率 系统盘总容量 系统盘使用量 系统盘使用率 数据盘总容量 数据盘使用量 数据盘使用率" > $outfile
for IP in $(awk '/^[^#]/{print $1}' $OLD_INFO); do
 USER=$(awk -v I=$IP 'I==$1{print $2}' $OLD_INFO)
 PASS=$(awk -v I=$IP 'I==$1{print $3}' $OLD_INFO)

 sshpass -p $PASS ssh $USER@$IP bash < ./host_info.sh >> $outfile
done