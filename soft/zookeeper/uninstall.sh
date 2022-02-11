#!/bin/env bash
#
# aim: uninstall singal zookeeper 3.7.0
# date: 10-13-2021
# version: 0.2
# auther: li

decompression_dir=/data
pkg_install_dir=/data/zookeeper

printf "\n<<<<<< stop zookeeper service \n"
systemctl stop zookeeper
systemctl disable zookeeper

if [ -f /etc/systemd/system/zookeeper.service ];then
        rm -f /etc/systemd/system/zookeeper.service
fi
systemctl daemon-reload
rm -f /etc/profile.d/jdk.sh
rm -f /etc/profile.d/zk.sh
source /etc/profile

printf "\n<<<<< remove file \n"
rm -rf ${pkg_install_dir}
rm -rf ${decompression_dir}/jdk1.8.0_301

printf "\n<<<<< remove user zk \n"
egrep "^zk" /etc/group >& /dev/null
if [ $? -eq 0 ];then
        userdel -r zk
fi
printf "<<<<< uninstall completed\n"

unset decompression_dir
unset pkg_install_dir