#!/bin/env bash
#
# aim: uninstall singal redis 3.2
# date: 
# 镜像下载地址下载连接地址 
# version: 0.1
# author: li

decompression_dir=/data
pkg_install_dir=/data/redis

printf "\n<<<<<< stop redis service \n"
systemctl list-unit-files | grep redis &>/dev/null
if [ $? -eq 0 ];then
    systemctl stop redis
    systemctl disable redis
    if [ -f /etc/systemd/system/kafka.service ];then
        rm -f /etc/systemd/system/kafka.service
    fi
    systemctl daemon-reload
fi
pgrep redis | xargs kill -9 &>/dev/null
printf "\n<<<<< remove file \n"
if [ -f /etc/profile.d/redis.sh ];then
    rm -rf /etc/profile.d/redis.sh
    source /etc/profile
fi

rm -rf ${pkg_install_dir}
rm -rf ${decompression_dir}/redis-3.2.8


printf "\n<<<<< remove service user \n"


printf "\n<<<<< uninstall completed\n"
