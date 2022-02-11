#!/bin/env bash
#
# aim: uninstall singal elasticsearch
# date: 10-13-2021
# version: 0.2
# author: li

decompression_dir=/data
pkg_install_dir=/data/elasticsearch

printf "\n<<<<< stop elasticsearch service \n"
systemctl stop elasticsearch.service
systemctl disable elasticsearch.service
if [ -f /etc/systemd/system/elasticsearch.service ];then
        rm -f /etc/systemd/system/elasticsearch.service
fi
systemctl daemon-reload
rm -f /etc/profile.d/jdk.sh
rm -f /etc/profile.d/es.sh
source /etc/profile

printf "\n<<<<< remove service from firewall\n"
firewall-cmd --permanent --remove-service=elasticsearch
firewall-cmd --reload

printf "\n<<<<< remove file \n"
rm -rf ${pkg_install_dir}
rm -rf ${decompression_dir}/jdk1.8.0_301

sed -i "s/* soft nofile 65536//g"  /etc/security/limits.conf
sed -i "s/* hard nofile 65536//g"  /etc/security/limits.conf
sed -i "s/* soft memlock unlimited//g"  /etc/security/limits.conf
sed -i "s/* hard memlock unlimited//g"  /etc/security/limits.conf

sed -i "s/vm.max_map_count=262144//g" /etc/sysctl.conf

sysctl -p

egrep "^es" /etc/group >& /dev/null
if [ $? -eq 0 ];then
        userdel -r es
fi
printf "<<<<< uninstall completed\n"

unset decompression_dir
unset pkg_install_dir