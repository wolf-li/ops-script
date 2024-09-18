#!/bin/env bash
# version : 0.4
# auth : wolf-li
# date : 2022-4-27
# script aim : install redis single node 6.2.7
# 

if [ "$(id -u)" -ne 0 ]; then
    echo "Not root user, exit."
    exit 1
fi

username=redis
suffix=.tar.gz
software_version=redis-6.2.6
software_name=$software_version$suffix
pkg_install_dir=/data/$software_version
port=6379
cpu_num=$(cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c | awk '{print $1}')

function downloadpackage(){
    curl -L -k --tlsv1 -O https://github.com/redis/redis-hashes
    grep "hash $1" redis-hashes| sed 's/<[^>]*>//g'| tail -n 1 > tmp
    downloadurl=$(grep -oE "http.*" tmp)
    checksum=$(awk '{print $4}' tmp)
    checksumtype=$(awk '{print $4}' tmp)
    wget $downloadurl
    if [[ ! -f ${software_name} ]];then
        echo "download ${software_name}  fail !!!"
        exit 1
    fi
    if [[ $checksumtype == "sha1" ]];then
        if [[ $(sha1sum $1) != $checksum ]];then
            echo "checksum fail"
            exit 1
        fi
    fi
    if [[ $checksumtype == "sha224" ]];then
        if [[ $(sha224sum $1) != $checksum ]];then
            echo "checksum fail"
            exit 1
        fi
    fi
    if [[ $checksumtype == "sha256" ]];then
        if [[ $(sha256sum $1) != $checksum ]];then
            echo "checksum fail"
            exit 1
        fi
    fi
    if [[ $checksumtype == "sha384" ]];then
        if [[ $(sha384sum $1) != $checksum ]];then
            echo "checksum fail"
            exit 1
        fi
    fi
    if [[ $checksumtype == "sha512" ]];then
        if [[ $(sha512sum $1) != $checksum ]];then
            echo "checksum fail"
            exit 1
        fi
    fi
    rm -f  redis-hashes tmp
}

if [[ ! -f ${software_name} ]];then
    echo "${software_name} not exist !!!"
    downloadpackage ${software_version}
fi

portNum=`ss -ntpl | grep ${port} | wc -l`
if [[ $portNum -gt 0 ]];then
    echo "tcp port ${port} already use try to other port !!!"
    exit 1
fi

read -p "input server name:(redis-xxx, default: redis)" service_name 
if [[ ! $service_name ]];then
    service_name=redis
else
    service_name='redis-'$service_name 
fi

if [[ ! -d $pkg_install_dir ]];then
    mkdir $pkg_install_dir
fi

tar xzf ${software_name} -C /data
yum install -y make gcc gcc++

cd ${pkg_install_dir}
make MALLOC=libc -j $cpu_num 
make PREFIX=${pkg_install_dir} install

ls /data/${software_version}/bin/ | xargs -i ln -s /data/${software_version}/bin/{} /usr/bin/{}

password=$(tr -dc '_A-Z#\-+=a-z(0-9%^>)]{<|' </dev/urandom | head -c 15; echo)
mkdir -p /data/${service_name}/${port}/{data,logs}
cp ${pkg_install_dir}/redis.conf  /data/${service_name}/${port}/
ll ${pkg_install_dir}/bin/ | awk '{print $NF}'| uniq | tail -n +2 | xargs -i ln -s ${pkg_install_dir}/bin/{} /usr/bin

cat << EOF > /data/${service_name}/${port}/redis.conf
##########################################基础参数配置############################################
bind $(hostname -I | awk '{print $1}')
protected-mode yes
#端口0代表完全禁用非TLS端口
port ${port}
unixsocket /data/${service_name}/${port}/redis.sock
unixsocketperm 700
timeout 0
tcp-keepalive 300
daemonize yes
supervised no
pidfile /data/${service_name}/${port}/redis_${port}.pid
loglevel notice
logfile /data/${service_name}/${port}/logs/redis_${port}.log
databases 16
always-show-logo yes
################################## 安全认证 ###################################
##配置认证密码
requirepass ${password}
################################# 持久化配置 #################################
#RDB 快照持久化
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /data/${service_name}/${port}/data
#AOF 持久化
appendonly no
appendfilename appendonly.aof
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
aof-rewrite-incremental-fsync yes
################################## 连接配置 ##################################
maxclients 10000
############################# 懒惰的释放 ####################################
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
################################ LUA时间限制 ###############################
lua-time-limit 5000
############################### 慢日志  ################################
slowlog-log-slower-than 10000
slowlog-max-len 128
#rejson.so
######################### 高级设置 #########################
activerehashing yes
#缓存空间限制
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 1024mb 256mb 300
client-output-buffer-limit pubsub 32mb 8mb 60
client-query-buffer-limit 1gb
#加快写入rdb 和aof
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
EOF
if ! id -u ${username} >/dev/null 2>&1;then 
    useradd -M ${username}  -M -s /bin/false
fi
chown -R ${username}:${username} /data/redis*

cat << EOF >  /etc/systemd/system/${service_name}.service
[Unit]
Description=redis service
Wants=network.target

[Service]
User=${username}
Group=${username}
Type=forking
ExecStart=${pkg_install_dir}/bin/redis-server /data/${service_name}/${port}/redis.conf
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s QUIT \$MAINPID 
RestartSec=30s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload

systemctl start ${service_name}
sleep 15
systemctl status ${service_name} --no-pager &> /dev/null
if [[ $? -ne 0 ]];then
    printf " start redis wrong check the log !!!"
    exit 1
fi
systemctl enable ${service_name}

systemctl status ${service_name} --no-pager
# ls /data/$software_version/bin/ | xargs -i ln -s /data/$software_version/bin/{} /usr/bin/{}

systemctl status firewalld >/dev/null
if [[ $? -eq 0 ]];then
# cat << EOF >> /usr/lib/firewalld/services/redis.xml
# <?xml version="1.0" encoding="utf-8"?>
# <service>
#   <short>$service_name</short>
#   <description>Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.</description>
#   <port protocol="tcp" port="$port"/>
# </service>
# EOF
sed -i "s,<port protocol="tcp" port="6379"/>,<port protocol="tcp" port="$port"/>,g" /usr/lib/firewalld/services/redis.xml
sleep 3
firewall-cmd --add-service=redis --permanent
firewall-cmd --reload
fi

echo "redis password: $(grep requirepass /data/${service_name}/${port}/redis.conf | awk '{print $NF}')"
