#!/bin/env bash
#
# aim: uninstall singal nacos 2.2.3
# date: 7-27-2023
# version: 0.1
# auther: li

if [ "$(id -u)" -ne 0 ]; then
    echo "Not root user, exit."
    exit 1
fi

decompression_dir=/data
pkg_install_dir=/data/nacos
username=nacos

printf "\n<<<<<< stop $username service \n"
systemctl stop $username
systemctl disable $username

systemctl status firewalld &>/dev/null
if [ $? -eq 0 ]; then
firewall-cmd --remove-service=$username --permanent
rm -f /etc/firewalld/services/$username.xml
systemctl restart firewalld
fi

systemctl status $username &>/dev/null
if [ $? -eq 0 ]; then
    if [ -f /etc/systemd/system/$username.service ];then
        rm -f /etc/systemd/system/$username.service
    fi
    systemctl daemon-reload
fi

rm -f /etc/profile.d/jdk.sh
source /etc/profile

printf "\n<<<<< remove file \n"
rm -rf ${pkg_install_dir}
rm -rf ${decompression_dir}/jdk1.8.0_301

printf "\n<<<<< remove user $username \n"
egrep "^$username" /etc/group >& /dev/null
if [ $? -eq 0 ];then
        userdel -r $username
fi
printf "<<<<< uninstall completed\n"

unset decompression_dir
unset pkg_install_dir
