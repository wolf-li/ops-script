#/bin/bash
# version : 0.3
# auth : wolf-li
# date : 2022-4-27
# script aim : install redis version 6x single node
# this is a example, your can install version 6.x.x

username=redis
software_name=redis-6.2.6.tar.gz   
pkg_install_dir=/data/redis-6.2.6
port=6379
password=$(tr -dc '_A-Z#\-+=a-z(0-9%^>)]{<|' </dev/urandom | head -c 15; echo)

function del_var(){
    unset username
    unset software_name
    unset pkg_install_dir
    unset port
    unset password
}

printf "Check whether the software package exists: "
if [[ ! -f ${software_name} ]];then
    echo -e "\033[31m ${software_name} not exist !!!\033[0m"
    exit 1
else
    echo -e "\033[32m pass\033[0m"
fi

printf "Check whether the port is used: "
portNum=`ss -ntpl | grep ${port} | wc -l`
if [[ $portNum -gt 0 ]];then
    echo -e "\033[31m tcp port ${port} already use try to other port !!!\033[0m"
    exit 1
else
    echo -e "\033[32m pass\033[0m"
fi

printf "Check whether the require software is installed: "
install=`which make gcc gcc++`
if [[ $? -eq 0 ]];then
    echo -e "\033[32m pass\033[0m"
else
    yum install -y make gcc gcc++
fi

read -p "input server name:" service_name 
if [[ ! $service_name ]];then
    service_name=redis
else
    service_name='redis-'+service_name 
fi


tar xzf ${software_name} -C /data
cd ${pkg_install_dir}
make MALLOC=libc
make PREFIX=${pkg_install_dir} install


mkdir -p /data/${service_name}/${port}/{data,logs}
cp ${pkg_install_dir}/redis.conf  /data/${service_name}/${port}/


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
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID 
RestartSec=5s
Restart=on-success

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload

systemctl start ${service_name}
sleep 15
systemctl status ${service_name} >/dev/null
if [[ $? -ne 0 ]];then
    printf " start redis wrong check the log !!!"
    exit 1
fi
systemctl enable ${service_name}

systemctl status ${service_name}

systemctl status firewalld >/dev/null
if [[ $? -eq 0 ]];then
cat << EOF >> /usr/lib/firewalld/services/redis.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>redis</short>
  <description>Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.</description>
  <port protocol="tcp" port="${port}"/>
</service>
EOF
sleep 3
firewall-cmd --add-service=redis --permanent
firewall-cmd --reload
fi

echo "redis password: $(grep requirepass /data/${service_name}/${port}/redis.conf | awk '{print $NF}')"
del_var
