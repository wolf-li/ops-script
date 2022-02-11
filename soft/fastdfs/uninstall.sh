#!/bin/env bash
#
# aim: uninstall singal fastdfs 5.11
# date: 
# 镜像下载地址下载连接地址 
# version: 0.1
# author: li

decompression_dir=/data
pkg_install_dir=/data/fastdfs

printf "\n<<<<<< stop fastdfs service \n"
systemctl stop fastdfs-tracker.service
systemctl stop fastdfs-storage.service
sleep 5
rm -f /etc/systemd/system/fastdfs-storage.service
rm -f /etc/systemd/system/fastdfs-tracker.service 
systemctl daemon-reload

printf "\n<<<<< remove file \n"
rm -f /usr/lib64/{libfastcommon.so,libfdfsclient.so,libfdfsclient.so} 
rm -f /usr/local/lib/{libfastcommon.so,libfdfsclient.so,libfdfsclient.so}
find / -name fdfs* | xargs -i rm -rf {}
rm -rf ${pkg_install_dir}
rm -rf ${decompression_dir}/{fastdfs-5.11,libfastcommon-1.0.36}
find / -name libfdfsclient*| xargs -i rm -rf {}
printf "\n<<<<< remove service user \n"


printf "\n<<<<< uninstall completed\n"
