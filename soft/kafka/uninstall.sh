#!/bin/env bash
#
# aim: uninstall singal kafka 2.8.1
# date: 10-13-2021
# version: 0.1
# auther: li

decompression_dir=/data
pkg_install_dir=/data/kafka

printf "\n<<<<<< stop kafka service \n"
systemctl stop kafka
systemctl disable kafka
grep zookeeper.connect=127.0.0.1:2181 ${pkg_install_dir}/config/server.properties
if [ $? -eq 0 ];then
        kill -9 $(ps -eo pid,command | grep "QuorumPeer" | grep -v grep | awk '{print $1}' )
fi

if [ -f /etc/systemd/system/kafka.service ];then
        rm -f /etc/systemd/system/kafka.service
fi

systemctl daemon-reload
rm -f /etc/profile.d/jdk.sh
rm -f /etc/profile.d/kafka.sh
source /etc/profile

printf "\n<<<<< remove file \n"
rm -rf ${pkg_install_dir}
rm -rf ${decompression_dir}/jdk1.8.0_301

sleep 20
printf "\n<<<<< remove user kafka \n"
egrep "^kafka" /etc/group >& /dev/null
if [ $? -eq 0 ];then
        userdel -r kafka
fi

printf "<<<<< uninstall completed\n"

unset decompression_dir
unset pkg_install_dir