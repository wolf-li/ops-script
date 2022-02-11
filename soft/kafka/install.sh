#!/bin/env bash
#
# aim: install singal kafka 2.8.1
# date: 10-13-2021
# kafka 镜像下载地址下载连接地址 https://repo.huaweicloud.com/apache/kafka/2.8.0/kafka_2.12-2.8.0.tgz
# 安装包内有 windows 文件，需要剔除
# version: 0.1
# author: li

set -e

pkg_dir=$(pwd)
decompression_dir=/data
pkg_install_dir=/data/kafka
user_name=kafka

printf "\n<<<<<< install jdk \n"
tar xzf jdk-8u301-linux-x64.tar.gz -C ${decompression_dir}
tar xzf kafka_2.12-2.8.0.tgz -C ${decompression_dir}
echo "export JAVA_HOME=${decompression_dir}/jdk1.8.0_301
export JRE_HOME=${decompression_dir}/jdk1.8.0_301/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >> /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh
java -version

printf "\n<<<<<< change KAFKA config \n"
mv ${decompression_dir}/kafka_2.12-2.8.0/ ${pkg_install_dir}
echo "KAFKA=${pkg_install_dir}
PATH=\$PATH:\$KAFKA/bin
export KAFKA PATH" >> /etc/profile.d/kafka.sh
source /etc/profile.d/kafka.sh

mkdir ${pkg_install_dir}/logs

useradd ${user_name} -s /sbin/nologin   
chown -R ${user_name}:${user_name} ${pkg_install_dir}

sed -i "s#log.dirs=/tmp/kafka-logs#log.dirs=${pkg_install_dir}/logs#" ${pkg_install_dir}/config/server.properties
host_ip=$(ip a| grep "global"| awk '{print $2}'| awk -F / '{print $1}' )
if [ ! -n "${host_ip}" ];then 
        host_ip=$(ip a| grep "global e"| awk '{print $2}'| awk -F / '{print $1}')
fi
sed -i "s,#listeners=PLAINTEXT://:9092,listeners=PLAINTEXT://${host_ip}:9092," ${pkg_install_dir}/config/server.properties
sed -i "s,broker.id=0,broker.id=$(ip a| grep "global"| awk '{print $2}'| awk -F / '{print $1}' | cut -d'.' -f4)," ${pkg_install_dir}/config/server.properties

zk_connection=""
read -p "<<<<<< you use the inside zk ?[Y/N]: " option
if [ "$option" = "Y" ];then
    zk_connection="127.0.0.1:2181"
    nohup bash ${pkg_install_dir}/bin/zookeeper-server-start.sh ${pkg_install_dir}/config/zookeeper.properties & 
elif [ "$option" = "N" ];then
    read -p "<<<<<< input the host IP and port or hostname and port (like localhost:2181): " input
    zk_connection=${input}
else
    printf " Input wrong, exit."
    bash uninstall.sh
    exit 1
fi

sed -i "s,zookeeper.connect=localhost:2181,zookeeper.connect=${zk_connection}," ${pkg_install_dir}/config/server.properties

if [ -f nohup.out ];then 
    rm -f nohup.out
fi

availabel_memory=$(free -m | sed -n '2p'| awk '{print $2-$3}')
if [ ${availabel_memory} -lt 1024 ];then
    printf "<<<<<< the machine memory is not engouth for install kafka ! at least 1GB"
    destroy_arg
    exit 1
else
    let "availabel_memory=availabel_memory/1024" 
    sed -i "s/export KAFKA_HEAP_OPTS=\"-Xmx1G -Xms1G\"/export KAFKA_HEAP_OPTS=\"-Xmx${availabel_memory}G -Xms${availabel_memory}G\"/"  ${pkg_install_dir}/bin/kafka-server-start.sh

    printf "\n<<<<<< start kafka using systemctl \n"
    
    echo "    [Unit]
    # 服务描述
    Description=kafka.service
    Requires=network.service
    After=network.target

    [Service]
    User=kafka
    Group=kafka
    Environment=JAVA_HOME=${decompression_dir}/jdk1.8.0_301
    ExecStart=${pkg_install_dir}/bin/kafka-server-start.sh ${pkg_install_dir}/config/server.properties
    ExecStop=${pkg_install_dir}/bin/kafka-server-stop.sh
    KillMode=none
    Restart=on-failure
    RestartSec=on-failure

    [Install]
    WantedBy=multi-user.target" > /etc/systemd/system/kafka.service

    systemctl daemon-reload
    systemctl start kafka
    systemctl enable kafka

    sleep 20
    printf "\n<<<<<< show kafka service status \n"
    systemctl status kafka

    # printf "\n<<<<<< show kafka node status \n"

fi