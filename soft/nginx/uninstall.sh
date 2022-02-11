#!/bin/env bash
#
# aim: uninstall singal nginx 1.20.1
# date: 9-29-2021
# nginx 官网下载连接地址 http://nginx.org/download/nginx-1.20.1.tar.gz
# version: 0.2
# author: li

pkg_dir=$(pwd)
decompression_dir=/data
pkg_install_dir=/data/nginx

printf "\n<<<<<< stop nginx service \n"
systemctl stop nginx
systemctl disable nginx

if [ -f /etc/systemd/system/nginx.service ];then
        rm -f /etc/systemd/system/nginx.service
fi
systemctl daemon-reload

printf "\n<<<<< remove file \n"
rm -f /etc/profile.d/nginx.sh
source /etc/profile
rm -rf ${decompression_dir}/nginx-1.20.1
rm -rf ${pkg_install_dir}

# yum remove make cmake gcc gcc-c++ pcre-devel zlib-devel openssl openssl-devel -y

printf "<<<<< uninstall completed\n"

unset decompression_dir
unset pkg_install_dir