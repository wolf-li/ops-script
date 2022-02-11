#!/bin/env bash
#
# aim: install singal nginx 1.20.1
# date: 9-29-2021
# nginx 官网下载连接地址 http://nginx.org/download/nginx-1.20.1.tar.gz
# version: 0.5
# author: li

pkg_dir=$(pwd)
decompression_dir=/data
pkg_install_dir=/data/nginx

## 安装 nginx 软件安装的依赖
printf "\n<<<<<<<< Installing dependent Software\n\n"

## 测试每一个安装包，没有下载的进行安装
pack_name=(
    make
    cmake
    gcc
    gcc-c++
    pcre-devel
    zlib-devel
    openssl-devel
)

for pkg_name in ${pack_name[*]}; do
    rpm -q $pkg_name &>/dev/null || yum install -y $pkg_name
done

if [ ! -d "${pkg_install_dir}" ]; then
    mkdir -p ${pkg_install_dir}
fi

tar xzf nginx-1.20.1.tar.gz -C ${decompression_dir}
cp -r module ${decompression_dir}
## 编译安装
cd ${decompression_dir}/nginx-1.20.1

printf "\n<<<<<<<< decompression nginx \n"
printf "\n there are sevrval modules for you:\n"
ls ${decompression_dir}/module
printf "\n module location: ${decompression_dir}/module\n"
read -p "input parameters: " parameter
./configure --prefix=${pkg_install_dir} ${parameter}
make && make install


echo "PATH=\$PATH:/data/nginx/sbin" > /etc/profile.d/nginx.sh
source /etc/profile.d/nginx.sh

## 创建 service 文件，利用 systemd 控制 nginx
cat <<EOF > /etc/systemd/system/nginx.service
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
ExecStartPost=/bin/sleep 0.1
PIDFile=${pkg_install_dir}/logs/nginx.pid
ExecStartPre=${pkg_install_dir}/sbin/nginx -t
ExecStart=${pkg_install_dir}/sbin/nginx
ExecReload=${pkg_install_dir}/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start nginx.service
systemctl enable nginx.service

printf "\n<<<<<<<< install nginx end\n"
printf "<<<<<<<< nginx service status: \n\n"
systemctl status nginx

## 启动 nginx 测试服务是否正常
printf "\n<<<<<<<< test web service is fine\n\n"
curl -I 127.0.0.1

unset decompression_dir
unset pkg_install_di
unset pack_name

# rm -rf ${pkg_dir}

# 备注普通用户可以启用 nginx ，不过因为 linux 启用 1024以内的端口要 root 用户，可以通过给 nginx 二进制文件添加 root 权限使用端口使用下面的命令即可
# chown root /usr/local/nginx/sbin/nginx
# chmod u+s /usr/local/nginx/sbin/nginx


