#!/bin/env bash
#
# 时间: 2021-11-8
# 版本: 0.1
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：
# 脚本使用： 


DATE=$(date +%F_%T)

nginx_dir=

BACKUP_DIR=
WORK_DIR=
PROJECT_NAME=

# 拉取代码
cd $WORK_DIR
if [ ! -d $PROJECT_NAME ];then
    git clone # https url
    cd  $PROJECT_NAME
else
    cd  $PROJECT_NAME
    git pull
fi

# 部署
if [ ! -d $nginx_dir ];then
    mkdir -p $nginx_dir
else
    rsync -avz --exclude=.git $WORK_DIR/$PROJECT_NAME $nginx_dir
fi
