#!/bin/env bash
#
# aim: install singal zookeeper 3.7.0
# date: 10-13-2021
# zookeeper 镜像下载地址下载连接地址 https://repo.huaweicloud.com/apache/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz
# version: 0.1
# author: li

set -e

pkg_dir=$(pwd)
decompression_dir=/data
pkg_install_dir=/data/zookeeper

printf "\n<<<<<< install jdk \n"
tar xzf jdk-8u301-linux-x64.tar.gz -C ${decompression_dir}
tar xzf apache-zookeeper-3.7.0-bin.tar.gz -C ${decompression_dir}
echo "export JAVA_HOME=${decompression_dir}/jdk1.8.0_301
export JRE_HOME=${decompression_dir}/jdk1.8.0_301/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >> /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh
java -version

printf "\n<<<<<< change zookeeper config \n"
echo "ZOOKEEPER=${pkg_install_dir}
PATH=\$PATH:\$ZOOKEEPER/bin
export ZOOKEEPER PATH" >> /etc/profile.d/zk.sh
source /etc/profile.d/zk.sh

mv ${decompression_dir}/apache-zookeeper-3.7.0-bin/ ${pkg_install_dir}

cp ${pkg_install_dir}/conf/zoo_sample.cfg ${pkg_install_dir}/conf/zoo.cfg
sed -i "s:dataDir=/tmp/zookeeper:dataDir=${pkg_install_dir}/data:" ${pkg_install_dir}/conf/zoo.cfg

useradd zk -s /sbin/nologin
mkdir ${pkg_install_dir}/data
chown -R zk:zk ${pkg_install_dir}

printf "\n<<<<<< start zookeeper using systemctl \n"
cat <<EOF > /etc/systemd/system/zookeeper.service
[Unit]
# 服务描述
Description=zk.service
Requires=network.service
After=network.target

[Service]
User=zk
Group=zk
Environment=JAVA_HOME=${decompression_dir}/jdk1.8.0_301
ExecStart=${pkg_install_dir}/bin/zkServer.sh start
ExecStop=${pkg_install_dir}/bin/zkServer.sh stop
ExecReload=${pkg_install_dir}/bin/zkServer.sh restart
PIDFile=${pkg_install_dir}/data/zookeeper_server.pid
KillMode=none
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start zookeeper
systemctl enable zookeeper

sleep 20
printf "\n<<<<<< show zk service status \n"
systemctl status zookeeper

printf "\n<<<<<< show zk node status \n"
zkServer.sh status


# 注：
# systemd 中配置的服务重启，kill 发送信号可以 如果是 zkServer.sh stop 则服务不能拉起