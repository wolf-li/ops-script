#!/bin/env bash
#
# aim: uninstall singal rocketmq
# date: 10-24-2021
# rocketmq 镜像网站下载连接 https://repo.huaweicloud.com/apache/rocketmq/4.9.0/rocketmq-all-4.9.0-bin-release.zip
# version: 0.1
# author: li

decompression_dir=/data
pkg_install_dir=/data/rocketmq

printf "\n<<<<<< stop rocketmq service \n"
systemctl stop rmq_namesrv.service
systemctl stop rmq_broker.service
systemctl disable rmq_namesrv.service
systemctl disable rmq_broker.service
rm -f /etc/systemd/system/rmq_broker.service
rm -f /etc/systemd/system/rmq_namesrv.service
systemctl daemon-reload

printf "\n<<<<< remove file \n"
rm -rf ${pkg_install_dir}
rm -rf ${decompression_dir}/jdk1.8.0_301
rm -rf /etc/profile.d/{jdk.sh,rocketmq.sh}
source /etc/profile

sleep 5
printf "\n<<<<< remove service user \n"
egrep "^rocketmq" /etc/group >& /dev/null
if [ $? -eq 0 ];then
        userdel -r rocketmq
fi

printf "\n<<<<< uninstall completed\n"
