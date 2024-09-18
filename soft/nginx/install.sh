#!/bin/env bash
#
# aim: install singal nginx 1.20.1
# date: 9-29-2021
# nginx 官网下载连接地址 http://nginx.org/download/nginx-1.20.1.tar.gz
# version: 0.10
# author: li
# 功能：
# 1. 编译安装 nginx
# 2. 使用 systemd 管理 nginx
# 3. 配置 firewalld 服务
# 4. 适配多个操作系统： centos、debin、ubuntu
# 普通安装 --with-http_stub_status_module --with-http_ssl_module

pkg_dir=$(pwd)
decompression_dir=/data
pkg_install_dir=/data/nginx
pkg_install_name=nginx-1.27.1
port=80
user='nginx'
cpu_num=$(cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c | awk '{print $1}')

portNum=`ss -ntpl | grep ':'${port}' ' | wc -l`
if [[ $portNum -gt 0 ]];then
    echo "tcp port ${port} already use try to other port !!!"
    exit 1
fi

# 需要增加超时退出函数
function downloadpackage(){
    curl -L -O http://nginx.org/download/$1
}

if [[  ! -f  "${pkg_install_name}.tar.gz" ]] ; then
    echo "${pkg_install_name}.tar.gz package  is not exist"
    downloadpackage ${pkg_install_name}.tar.gz
    if [[  ! -f  "${pkg_install_name}.tar.gz" ]] ; then
        echo "install fail"
        exit
    fi
fi

## 安装 nginx 软件安装的依赖
printf "\n<<<<<<<< Installing dependent Software\n\n"

## 测试每一个安装包，没有下载的进行安装
yum_pack_name=(
    make
    cmake
    gcc
    gcc-c++
    pcre-devel
    zlib-devel
    openssl-devel
)

apt_pack_name=(
    make
    build-essential
    libpcre3 
    libpcre3-dev
    zlib1g-dev
    openssl
    libssl-dev
)

pacman_pack_name=(
    make
    gcc
    gcc-c++
    autoconf
    automake
    pcre-devel
    zlib-devel
    openssl-devel
)

function is_apt_package_installed() {
  local package_name="$1"
  dpkg -s "$package_name" >/dev/null 2>&1
  if [ $? -ne 0 ];then
    apt install -y $1
  fi
  echo "$1 installed !!!"
}

function is_pacman_package_installed() {
  local package_name="$1"
  pacman -Qi "$package_name" >/dev/null 2>&1
  if [ $? -ne 0 ];then
    pacman install -y $1
  fi
  echo "$1 installed !!!"
}

function is_yum_package_installed(){
  local package_name="$1"
  rpm -q "$package_name" >/dev/null 2>&1
  if [ $? -ne 0 ];then
    yum install -y $1
  fi
  echo "$1 installed !!!"
}

function is_package_installed(){
    case $1 in 
        apt )
            for tmp_pack_name in ${apt_pack_name[*]}; do
                is_apt_package_installed $tmp_pack_name
            done
        ;;
        pacman )
            for tmp_pack_name in ${pacman_pack_name[*]}; do
                is_apt_package_installed $tmp_pack_name
            done
        ;;
        yum )
            for tmp_pack_name in ${yum_pack_name[*]}; do
                is_apt_package_installed $tmp_pack_name
            done
        ;;
        *)
            echo "not support"
        ;;
    esac
}

function identify_package_manager() {
  # 优先尝试使用 lsb_release
  distro=$(lsb_release -is 2>/dev/null)
  if [ -n "$distro" ]; then
    case "$distro" in
      Ubuntu|Debian)
        echo "apt"
        ;;
      Fedora|CentOS|RHEL)
        echo "yum"
        ;;
      Arch)
        echo "pacman"
        ;;
      # 添加更多发行版和对应包管理器的判断
      *)
        echo "Unsupported distribution: $distro"
        ;;
    esac
    return
  fi

  # 如果 lsb_release 不存在，尝试从 /etc/os-release 获取信息
  distro_id=$(grep '^ID=' /etc/os-release | cut -d= -f2 |sed 's/"//g')
  case "$distro_id" in
    ubuntu|debian)
      echo "apt"
      ;;
    fedora|centos|rhel)
      echo "yum"
      ;;
    arch)
      echo "pacman"
      ;;
    # 添加更多发行版和对应包管理器的判断
    *)
      # 如果 /etc/os-release 中也没有找到，尝试其他方法
      # ...
      echo "Failed to identify package manager"
      ;;
  esac
}

is_package_installed $(identify_package_manager)

if [ ! -d "${pkg_install_dir}" ]; then
    mkdir -p ${pkg_install_dir}
fi

tar xzf ${pkg_install_name}.tar.gz -C ${decompression_dir}

printf "\n Are you want to use modules?\n"
prompt="input parameters: (y/n): "

while true; do
    read -p "$prompt" yn
    case $yn in
        [Yy]* )
            # 用户输入为 y 或 Y
            cp -r module ${decompression_dir}
            printf "\n<<<<<<<< decompression nginx \n"
            printf "\n there are sevrval modules for you:\n"
            printf "\n module location: ${decompression_dir}/module\n"
            ls ${decompression_dir}/module
            break;;
        [Nn]* )
            break;;
        * )
            # 用户输入不是 y、Y、n 或 N
            echo "无效的输入，请重新输入.";;
    esac
done

## 编译安装
cd ${decompression_dir}/${pkg_install_name}
printf "\n<<<<<<<< decompression nginx \n"
echo "you can use: --with-http_stub_status_module --with-http_ssl_module --with-pcre  --with-http_v2_module "
read -p "input parameters: " parameter
./configure --prefix=${pkg_install_dir} ${parameter}
make -j $cpu_num && make install

## 覆盖原来的配置文件
cat << EOF > ${pkg_install_dir}/conf/nginx.conf
user nginx;
worker_processes auto;
pid     logs/nginx.pid;

events {
        worker_connections 768;
        # multi_accept on;
}

http {

        ##
        # Basic Settings
        ##

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        # server_tokens off;

        # server_names_hash_bucket_size 64;
        # server_name_in_redirect off;

        include mime.types;
        default_type application/octet-stream;

        ##
        # SSL Settings
        ##

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        ##
        # Logging Settings
        ##

        access_log logs/access.log;
        error_log logs/error.log;

        ##
        # Gzip Settings
        ##

        gzip on;

        # gzip_vary on;
        # gzip_proxied any;
        # gzip_comp_level 6;
        # gzip_buffers 16 8k;
        # gzip_http_version 1.1;
        # gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

        ##
        # Virtual Host Configs
        ##

        include ${pkg_install_dir}/conf.d/*.conf;
}
EOF

if [[ ! -d  ${pkg_install_dir}/conf.d ]];then mkdir ${pkg_install_dir}/conf.d; fi
if [[ ! -d  ${pkg_install_dir}/logs ]];then mkdir ${pkg_install_dir}/logs; fi

cat << EOF > ${pkg_install_dir}/conf.d/default.conf
##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# https://www.nginx.com/resources/wiki/start/
# https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/
# https://wiki.debian.org/Nginx/DirectoryStructure
#
# In most cases, administrators will remove this file from sites-enabled/ and
# leave it as reference inside of sites-available where it will continue to be
# updated by the nginx packaging team.
#
# This file will automatically load configuration files provided by other
# applications, such as Drupal or Wordpress. These applications will be made
# available underneath a path with that package name, such as /drupal8.
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

# Default server configuration
#
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        # SSL configuration
        #
        # listen 443 ssl default_server;
        # listen [::]:443 ssl default_server;
        #
        # Note: You should disable gzip for SSL traffic.
        # See: https://bugs.debian.org/773332
        #
        # Read up on ssl_ciphers to ensure a secure configuration.
        # See: https://bugs.debian.org/765782
        #
        # Self signed certs generated by the ssl-cert package
        # Don't use them in a production server!
        #
        # include snippets/snakeoil.conf;

        root ${pkg_install_dir}/html;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files \$uri \$uri/ =404;
        }

        # pass PHP scripts to FastCGI server
        #
        #location ~ \.php$ {
        #       include snippets/fastcgi-php.conf;
        #
        #       # With php-fpm (or other unix sockets):
        #       fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        #       # With php-cgi (or other tcp sockets):
        #       fastcgi_pass 127.0.0.1:9000;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #       deny all;
        #}
}
EOF

ln -s ${pkg_install_dir}/sbin/nginx /usr/sbin/nginx

## 添加日志轮转
cat << EOF > /etc/logrotate.d/nginx
${pkg_install_dir}/logs/*.log {
        daily
            dateext
        missingok
        rotate 52
        compress
        notifempty
        copytruncate
        create 640 app app
        sharedscripts
        postrotate
                if [ -f ${pkg_install_dir}/logs/nginx.pid ]; then
                        kill -USR1 `cat ${pkg_install_dir}/logs/nginx.pid`
                fi
        endscript
}
EOF

## 创建 service 文件，利用 systemd 控制 nginx
cat <<EOF >  /usr/lib/systemd/system/nginx.service
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
User=root
Group=nginx
Type=forking
ExecStartPost=/bin/sleep 0.1
PIDFile=${pkg_install_dir}/logs/nginx.pid
ExecStartPre=${pkg_install_dir}/sbin/nginx -t
ExecStart=${pkg_install_dir}/sbin/nginx
ExecReload=${pkg_install_dir}/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
RestartSec=30s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

function create_service_user(){
    if ! id -u $1 >/dev/null 2>&1;then
        useradd -M $1  -M -s /bin/false
    fi
    chown -R $1:$1 ${pkg_install_dir}
}

create_service_user $user


systemctl daemon-reload
systemctl start nginx.service
systemctl enable nginx.service

printf "\n<<<<<<<< install nginx end\n"
printf "<<<<<<<< nginx service status: \n\n"
systemctl status nginx --no-pager

## 启动 nginx 测试服务是否正常
printf "\n<<<<<<<< test web service is fine\n\n"
curl -I 127.0.0.1:$port

unset decompression_dir
unset pkg_install_di
unset pack_name



# 备注普通用户可以启用 nginx ，不过因为 linux 启用 1024以内的端口要 root 用户，可以通过给 nginx 二进制文件添加 root 权限使用端口使用下面的命令即可
# 方法1：
# chown root /usr/local/nginx/sbin/nginx
# chmod u+s /usr/local/nginx/sbin/nginx
# 方法2：
# 使用非80端口启动程序，然后再用iptables做一个端口转发。
# 方法3：
# setcap cap_net_bind_service =+ep /usr/local/nginx/sbin/nginx
#
# setcap cap_net_bind_service=+ep /data/nginx/sbin/nginx


# rm -rf $(pwd)/*
