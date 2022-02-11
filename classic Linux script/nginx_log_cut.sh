#!/bin/env bash
#
# 时间: 2021-11-5
# 版本: 0.1
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：nginx 日志切割（按天）
# 脚本使用： 配合 crontab 进行每天切割

LOG_DIR=
YESTERDAY_TIME=$(date -d "yesterday" +%F)
LOG_MONTH_DIR=$LOG_DIR/$(date +"%Y=%m")
LOG_FILE_LIST="access.log"

for LOG_FILE in $LOG_FILE_LIST;do
    [ ! -d $LOG_MONTH_DIR ] && mkdir -p $LOG_MONTH_DIR
    mv $LOG_DIR/$LOG_FILE $LOG_MONTH_DIR/${LOG_FILE}_${YESTERDAY_TIME}
done

kill -USER1 $(cat $(find / -name nginx.pid))