#!/bin/env bash
#
# aim: install singal fastdfs 5.11
# date: 
# 镜像下载地址下载连接地址 
# fastdfs-5.11.tar.gz
# [gitee](https://gitee.com/fastdfs100/fastdfs/repository/archive/refs/tags/V5.11.tar.gz)
# [github](https://github.com/happyfish100/fastdfs/archive/refs/tags/V5.11.tar.gz)
#
# libfastcommon-1.0.36.tar.gz
# [gitee](https://gitee.com/fastdfs100/libfastcommon/repository/archive/V1.0.35)
# [github](https://github.com/happyfish100/libfastcommon/archive/refs/tags/V1.0.36.tar.gz)
#
# version: 0.1
# author: li

set -e

pkg_dir=$(pwd)
decompression_dir=/data
pkg_install_dir=/data/fastdfs

printf "\n<<<<<< install Rely on the software \n"
prepack_name=(
    make
    cmake
    gcc
    gcc-c++
    unzip
    perl
    # libevent
    # libevent-devel
)

for pkg_name in ${prepack_name[*]}; do
    yum list installed | grep -E $pkg_name
    if [ $? != 0 ];then
        yum install $pkg_name -y
    fi
done

if [ ! -d "${pkg_install_dir}" ]; then
    mkdir -p ${pkg_install_dir}
fi

tar xfz libfastcommon*.tar.gz -C ${decompression_dir}
cd /data/libfastcommon*
./make.sh clean && ./make.sh && ./make.sh install

ln -s /usr/lib64/libfastcommon.so /usr/local/lib/libfastcommon.so
ln -s /usr/lib64/libfdfsclient.so /usr/local/lib/libfdfsclient.so
ln -s /usr/lib64/libfdfsclient.so /usr/lib/libfdfsclient.so

mkdir ${pkg_install_dir}/{tracker,storage,storagedata}
cd -
tar xfz fastdfs*.tar.gz -C ${decompression_dir}
cd ${decompression_dir}/fastdfs-5.11
./make.sh clean && ./make.sh && ./make.sh install

printf "\n<<<<<< change fastdfs config \n"
cd /etc/fdfs
cp client.conf.sample client.conf
cp storage.conf.sample storage.conf
cp tracker.conf.sample tracker.conf

sed -i "s:base_path=/home/yuqing/fastdfs:base_path=${pkg_install_dir}/tracker:" /etc/fdfs/tracker.conf
sed -i "s:base_path=/home/yuqing/fastdfs:base_path=${pkg_install_dir}/storage:" /etc/fdfs/storage.conf
sed -i "s:store_path0=/home/yuqing/fastdfs:store_path0=${pkg_install_dir}/storagedata:" /etc/fdfs/storage.conf

host_ip=''
read -p ">>>>> use the local host as the server ?[Y/N]: " option
if [ "$option" = "Y" ];then
    host_ip=$(ip a| grep "global"| awk '{print $2}'| awk -F / '{print $1}' )
    if [ ! -n "${host_ip}" ];then 
            host_ip=$(ip a| grep "global "| awk '{print $2}'| awk -F / '{print $1}')
    fi
elif [ "$option" = "N" ];then
    read -p ">>>>>> input the server ip: " ip
    host_ip=$ip
else
    printf " Input wrong, exit."
    bash ${pkg_dir}/uninstall.sh
    exit 1
fi
sed -i "s/tracker_server=192.168.209.121:22122/tracker_server=${host_ip}:22122/" /etc/fdfs/storage.conf

printf "\n<<<<<< start fastdfs using systemctl \n"
cat << EOF > /etc/systemd/system/fastdfs-tracker.service 
[Unit]
Description=The FastDFS File server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/data/fastdfs/tracker/data/fdfs_trackerd.pid
ExecStart=/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf start
ExecStop=/usr/bin/fdfs_trackerd /etc/fdfs/tracker.conf stop
Restart=on-failure
RestartSec=60s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start fastdfs-tracker.service

cat << EOF > /etc/systemd/system/fastdfs-storage.service
[Unit]
Description=The FastDFS File server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStartPost=/bin/sleep 3 
PIDFile=/data/fastdfs/storage/data/fdfs_storaged.pid
ExecStart=/usr/bin/fdfs_storaged /etc/fdfs/storage.conf start
ExecStop=/usr/bin/fdfs_storaged /etc/fdfs/storage.conf stop
# ExecRestart=/usr/bin/fdfs_storaged /etc/fdfs/storage.conf restart
Restart=on-failure
RestartSec=60s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start fastdfs-storage.service


printf "\n<<<<<< show fastdfs service status \n"
ss -tulnp |grep fdfs
systemctl status fastdfs-tracker.service 
systemctl status fastdfs-storage.service

printf "\n<<<<<< show fastdfs node status \n"
/usr/bin/fdfs_monitor /etc/fdfs/storage.conf list
