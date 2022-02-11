#!/bin/env bash
#
# aim: install singal elasticsearch 5.8.9
# date: 10-13-2021
# elasticsearch 镜像下载地址下载连接地址 https://repo.huaweicloud.com/elasticsearch/6.8.5/elasticsearch-6.8.5.tar.gz
# version: 0.2
# author: li

set -e

pkg_dir=$(pwd)
decompression_dir=/data
pkg_install_dir=/data/elasticsearch

destroy_arg()
{
    unset decompression_dir
    unset pkg_install_dir
}

if [ ! -d "${decompression_dir}" ]; then
    mkdir -p ${decompression_dir}
fi

printf "\n<<<<<< install jdk \n"
tar xzf jdk-8u301-linux-x64.tar.gz -C ${decompression_dir}
tar xzf elasticsearch-6.8.5.tar.gz -C ${decompression_dir}
echo "export JAVA_HOME=${decompression_dir}/jdk1.8.0_301
export JRE_HOME=${decompression_dir}/jdk1.8.0_301/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >> /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh
java -version


mv ${decompression_dir}/elasticsearch-6.8.5/ ${pkg_install_dir}
mkdir ${pkg_install_dir}/data

useradd es -s /sbin/nologin
chown -R es:es ${pkg_install_dir}

cp ${pkg_install_dir}/config/elasticsearch.yml ${pkg_install_dir}/config/elasticsearch_default.yml

#######   配置文件需要进行适当修改
cat << EOF > /data/elasticsearch/config/elasticsearch.yml
#索引数据的存储路径
path.data: ${pkg_install_dir}/data
#日志文件的存储路径
path.logs: ${pkg_install_dir}/logs
#设置为true来锁住内存。因为内存交换到磁盘对服务器性能来说是致命的，当jvm开始swapping时es的效率会降低，所以要保证它不swap
bootstrap.memory_lock: true
#绑定的ip地址 (可以填写本机ip或 0.0.0.0)
network.host: 0.0.0.0
#设置对外服务的http端口，默认为9200
http.port: 9200
#设置节点间交互的tcp端口,默认是9300
transport.tcp.port: 9300
#Elasticsearch将绑定到可用的环回地址，并将扫描端口9300到9305以尝试连接到运行在同一台服务器上的其他节点。
#这提供了自动集群体验，而无需进行任何配置。数组设置或逗号分隔的设置。每个值的形式应该是host:port或host
#（如果没有设置，port默认设置会transport.profiles.default.port 回落到transport.tcp.port）。

indices.fielddata.cache.size: 40%
EOF

echo "ELASTICSEARCH=${pkg_install_dir}
PATH=\$PATH:\$ELASTICSEARCH/bin
export ELASTICSEARCH PATH" >> /etc/profile.d/es.sh
source /etc/profile.d/es.sh

cat << EOF >> /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft memlock unlimited
* hard memlock unlimited
EOF

cat << EOF >> /etc/sysctl.conf
vm.max_map_count=262144
EOF

sysctl -p

#su -

## 添加补丁
rm -f ${pkg_install_dir}/modules/ingest-geoip/jackson-databind-2.8.11.3.jar
cp jackson-databind-2.10.4.jar ${pkg_install_dir}/modules/ingest-geoip/
chmod 777  ${pkg_install_dir}/modules/ingest-geoip/jackson-databind-2.10.4.jar


#### service 配置文件
cat << EOF > /etc/systemd/system/elasticsearch.service
[Unit]
Description=ElasticSearch
Requires=network.service
After=network.service

[Service]
User=es
Group=es
LimitNOFILE=65536
LimitMEMLOCK=infinity
Environment=JAVA_HOME=${decompression_dir}/jdk1.8.0_301
ExecStart=${pkg_install_dir}/bin/elasticsearch
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
SuccessExitStatus=143
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF


## es jvm 调优
availabel_memory=$(free -m | sed -n '2p'| awk '{print $2-$3}')
if [ ${availabel_memory} -lt 1024 ];then
    printf "<<<<<< the machine memory is not engouth for install elasticsearch ! at least 1GB"
    destroy_arg
    exit 1
else
    let "availabel_memory=availabel_memory/1024"
    sed -i "s/-Xms1g/-Xms${availabel_memory}g/g" ${pkg_install_dir}/config/jvm.options
    sed -i "s/-Xmx1g/-Xmx${availabel_memory}g/g" ${pkg_install_dir}/config/jvm.options

    unset availabel_memory
    systemctl daemon-reload
    systemctl start elasticsearch.service
    systemctl enable elasticsearch.service

    add_firewall()
    {
        printf "\n<<<<< add service to firewalld\n"
        firewall-cmd --permanent --add-service=elasticsearch
        printf "\n<<<<< reload firewalld\n"
        firewall-cmd --reload
    }

    systemctl |grep firewall|grep active
    if [ $? -eq 0 ];then
        add_firewall
    else
        systemctl start firewall
        add_firewall
    fi

    sleep 30

    printf "\n<<<<<< elasticsearch status \n"
    systemctl status elasticsearch.service

    sleep 30

    printf "\n<<<<<< elasticsearch node status \n"
    host_ip=$(ip a| grep "global e"| awk '{print $2}'| awk -F / '{print $1}')
    if [ ! -n "${host_ip}" ];then 
        host_ip=$(ip a| grep "global "| awk '{print $2}'| awk -F / '{print $1}')
    fi
    curl -XGET "${host_ip}:9200/_cat/nodes?pretty&v"
    unset host_ip
    destroy_arg
fi