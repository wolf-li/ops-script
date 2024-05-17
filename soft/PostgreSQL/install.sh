#!/bin/env bash
#
# 时间: 2024-04-28
# 版本: 0.1
# 作者: li
#
# 脚本名称：PostgreSQL 数据库单节点安装
# 支持 PostgreSQL 版本 16
# 脚本可以完成的任务：
# 脚本使用：./install.sh
# issue：
#  	uuid  // 缺少这个动态链接
#
## Since the symbol exists, it looks like the postgres ./configure script doesn't get the above library but the one in /usr/lib. You can use the following to configure postgres:
# Code:
# LDFLAGS=-L/usr/local/lib CPPFLAGS=-I/usr/local/include ./configure --with-ossp-uuid --other-options...

# note: 
#

service_name="postgresql-16.2"
suffix=".tar.gz"
package_name=$service_name$suffix
user="postgres"
port="5432"
decompression_dir="/data"
decompression_tmp_dir="/tmp"

pack_name=(
	make
	perl-ExtUtils-Embed 
	readline-devel 
	zlib-devel 
	pam-devel 
	libxml2-devel 
	libxslt-devel 
	openldap-devel 
	python-devel 
	gcc-c++ 
	openssl-devel 
	cmake
	libicu-devel
	libuuid-devel
	systemd-devel
)

function install_depend_software(){
	for pkg_name in ${pack_name[*]}; do
	    rpm -q $pkg_name &>/dev/null || yum install -y $pkg_name &>/dev/null
	    if [[ $? -ne 0 ]];then
	    	echo "$pkg_name install fail"
	    	exit 1	
	    fi
	done
}

function port_check(){
	if [[ $1 =~ ^[0-9]+$ ]];then
		portNum=`ss -ntpl | grep $1 | wc -l`
		if [[ $portNum -gt 0 ]];then
		    echo "tcp port $1 already use try to other port !!!"
		    exit 1
		fi
	else
		echo "$1 wrong port"
		exit 1
	fi
}

function file_exist_check(){
	if [[  ! -f  "$1" ]] ; then
	    echo "$1 file  is not exist !!! "
	    exit 1
	fi
}

function add_user(){
	if ! id -u $1 >/dev/null 2>&1;then 
	    useradd $1  
	fi
}

# $1 解压文件名
# $2 文件后缀
# $3 解压路径
function setup_package_file(){
	if [[ $# -eq 3 ]];then
		if [[ "$2" = ".tar.gz" ]];then
		    tar -xzf $1 -C $3
		elif [[ "$2" = ".zip" ]];then
		    unzip -d $3 $1
		else 
			echo "$2 not support"
			exit 1
		fi
		chown -R $user:$user $3
	else 
		echo "wrong input"
		exit 1
	fi
}

function compile_package(){
	cpu_num=$(cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c | awk '{print $1}')
	cd $1
	if [[ -f "configure" ]];then
	    ./configure --prefix=${decompression_dir}/${service_name}  --with-libraries=/lib64  --with-systemd --with-openssl
		make  -j $cpu_num ${decompression_dir}/${service_name}
		make install
		if [[ $? -ne 0 ]];then
			echo "compile fial"
			exit 1
		fi
		rm -rf $1
	else 
		echo "no configure file"
		exit 1
	fi
}

function init_package(){
	mkdir -p ${decompression_dir}/${service_name}/data
	chown -R $user: ${decompression_dir}/${service_name}
	su - $user -s /bin/bash -c '${decompression_dir}/${service_name}/bin/initdb -D ${decompression_dir}/${service_name}/data'
	# ${decompression_dir}/${service_name}/bin/pg_ctl -D ${decompression_dir}/${service_name}/data -l logfile start
	# ${decompression_dir}/${service_name}/bin/createdb test
	# ${decompression_dir}/${service_name}/bin/psql test
}


function config_system_var(){
cat <<EOF>> /etc/profile.d/postgres.sh
export PGHOME=${decompression_dir}/${service_name}
PATH=$PATH:$HOME/bin:$PGHOME/bin
EOF
source /etc/profile.d/postgres.sh
}

function service_systemd(){
cat <<EOF> /etc/systemd/system/${service_name}.service
[Unit]
Description=PostgreSQL database server
Documentation=man:postgres(1)
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=postgres
ExecStart=${decompression_dir}/${service_name}/bin/postgres -D ${decompression_dir}/${service_name}/data
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
KillSignal=SIGINT
TimeoutSec=infinity

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start ${service_name}
systemctl status ${service_name}
}

port_check $port
file_exist_check $package_name
install_depend_software
add_user $user
setup_package_file $package_name $suffix ${decompression_tmp_dir}
compile_package ${decompression_tmp_dir}/${service_name}
init_package
config_system_var
service_systemd
