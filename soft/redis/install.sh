#!/bin/env bash
#
# aim: install singal redis 3.2.8
# date: 
# 镜像下载地址下载连接地址 
# version: 0.2
# author: li

set -e

pkg_dir=$(pwd)
decompression_dir=/data
pkg_install_dir=/data/redis
data_dir=${pkg_install_dir}/data
pid_file=${pkg_install_dir}/redis.pid
log_file=${pkg_install_dir}/redis.log
user_name=redis

printf "\n<<<<<< install Rely on the software \n"
pack_name=(
    make
    cmake
    gcc
    gcc-c++
)

for pkg_name in ${pack_name[*]}; do
    rpm -q $pkg_name &>/dev/null || yum install -y $pkg_name
done

useradd ${user_name} -s /sbin/nologin   
chown -R ${user_name}:${user_name} ${pkg_install_dir}
tar xzf redis-3.2.8.tar.gz -C /data
cd /data/redis-3.2.8

make MALLOC=libc
make && make test
if [ $? -eq 0 ];then
    make install
else
    exit 1
fi

make PREFIX=${pkg_install_dir} install

echo "PATH=\$PATH:${pkg_install_dir}/bin" > /etc/profile.d/redis.sh  
source /etc/profile.d/redis.sh 
if [ ! -e ${data_dir} ];then
    mkdir -p ${data_dir}
fi

printf "\n<<<<<< change [software] config \n"
cp ${decompression_dir}/redis-3.2.8/redis.conf ${pkg_install_dir}

host_ip=$(ip a| grep "global"| awk '{print $2}'| awk -F / '{print $1}' )
if [ ! -n "${host_ip}" ];then 
        host_ip=$(ip a| grep "global "| awk '{print $2}'| awk -F / '{print $1}')
fi

sed -i "s/bind 127.0.0.1/bind ${host_ip}/" ${pkg_install_dir}/redis.conf
sed -i "s/daemonize no/daemonize yes/" ${pkg_install_dir}/redis.conf
sed -i "s/appendonly no/appendonly yes/" ${pkg_install_dir}/redis.conf
sed -i "s#pidfile /var/run/redis_6379.pid#pidfile ${pid_file}#" ${pkg_install_dir}/redis.conf
sed -i "s#logfile \"\"#logfile \"$log_file\"#" ${pkg_install_dir}/redis.conf
sed -i "s#dir ./#dir $data_dir#" ${pkg_install_dir}/redis.conf

printf "\n<<<<<< start [software] using systemctl \n"
cat <<EOF > /etc/systemd/system/redis.service    
[Unit]
Description=redis service
Wants=network.target

[Service]
User=redis
Group=redis
Type=forking
PIDFile=${pid_file}
ExecStart=${pkg_install_dir}/bin/redis-server ${pkg_install_dir}/redis.conf
ExecStop=/bin/kill -s QUIT $MAINPID 
RestartSec=5s
Restart=on-success

[Install]
WantedBy=multi-user.target
EOF

printf "\n<<<<<< show [software] service status \n"
systemctl daemon-reload
systemctl start redis
# systemctl enable redis
systemctl status redis

printf "\n<<<<<< add firewalld rule \n"
firewall-cmd --permanent --add-service=redis


unset decompression_dir
unset pkg_dir
unset decompression_dir
unset pkg_install_dir
unset data_dir
unset pid_file
unset log_file
unset user_name