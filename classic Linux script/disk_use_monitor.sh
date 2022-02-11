#!/bin/env bash
#
# 时间: 2021-10-29
# 版本: 0.1
# 作者: li
#
# 脚本名称：disk_use_monitor.sh
# 脚本灵感来源: 
# 脚本可以完成的任务：监控磁盘利用率，超过阈值自动报警
# 脚本使用：配合 cron 使用和 ssh 免密登录

HOST_INFO=host.info
for IP in $(awk '/^[^#]/{print $1}' $HOST_INFO);do
    USER=$(awk -v ip=$IP 'ip==$1{print $2}' $HOST_INFO)
    PORT=$(awk -v ip=$IP 'ip==$1(print $3)' $HOST_INFO)
    TMP_FILE=/tmp/disk.info
    ssh -p $PORT $USER@$IP 'df -h' >$TMP_FILE
    USER_RATE_LIST=$(awk 'BEGIN{OFS="="}/^\/dev/{print $NF,int($5)}' $TMP_FILE)
    for USER_RATE_LIST in $USER_RATE_LIST; do
        PART_NAME=${USER_RATE%=*}
        USE_RATE=${USE_RATE#*=}
        if [ $USE_RATE -ge 80 ];then
            # 这里可以添加 mail alert 
            echo "warning $PART_NAME Partition usage $USE_RATE%!"
        else
            echo YES
        fi
    done
done