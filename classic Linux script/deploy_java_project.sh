#!/bin/env bash
#
# 时间: 2021-11-8
# 版本: 0.1
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：自动部署 java 项目到 tomcat中，java 不能直接部署需要先拉取代码、构建（jar、war）、部署
# java 部署需要 
# 脚本使用： ./deploy_java_project.sh tomcat_name

DATE=$(date +%F_%T)

TOMCAT_NAME=$1
TOMCAT_DIR=
ROOT=$TOMCAT_DIR/webapps/ROOT

BACKUP_DIR=
WORK_DIR=/tmp
PROJECT_NAME=

# 拉取代码于构建
cd $WORK_DIR
if [ ! -d $PROJECT_NAME ]; then
    git clone # 项目 https 连接
    cd $PROJECT_NAME
else
    cd $PROJECT_NAME
    git pull
fi

mvn clean package -Dmaven.test.skip=true
if [ $? -eq 0 ];then
    echo "maven build failure"
    exit 1
fi

# 部署
TOMCAT_PID=$(ps -ef | grep "$TOMCAT_NAME" | egrep -v "grep | $$"| awk 'NR==1{print $2}')
[ -n "$TOMCAT_PID" ] && kill -9 $TOMCAT_PID
[ -d $ROOT ] && mv $ROOT $BACKUP_DIR/${TOMCAT_NAME}_ROOT$DATE
unzip $WORK_DIR/$PROJECT_NAME/target/*.war -d $ROOT
$TOMCAT_DIR/bin/startup.sh

