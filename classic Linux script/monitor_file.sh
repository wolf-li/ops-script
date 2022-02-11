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

MON_DIR=/opt
inotifywait -mqr --format %f -e create $MON_DIR | \
while read files; do
    rsync -avz /opt /tmp/opt
    echo "${date +'%F %T'} $files"
done