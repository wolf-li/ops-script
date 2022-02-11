#!/bin/env bash
#
# aim: install singal rocketmq
# date: 10-24-2021
# rocketmq 镜像网站下载连接 https://repo.huaweicloud.com/apache/rocketmq/4.9.0/rocketmq-all-4.9.0-bin-release.zip
# version: 0.1
# author: li

set -e

pkg_dir=$(pwd)
decompression_dir=/data
pkg_install_dir=/data/rocketmq
user=rocketmq

printf "\n<<<<<< install Rely on the software \n"
printf "\n<<<<<< install jdk \n"
tar xzf jdk-8u301-linux-x64.tar.gz -C ${decompression_dir}
echo "export JAVA_HOME=${decompression_dir}/jdk1.8.0_301
export JRE_HOME=${decompression_dir}/jdk1.8.0_301/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >> /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh
java -version

unzip rocketmq-all-4.9.0-bin-release.zip -d ${decompression_dir} &> /dev/null
mv ${decompression_dir}/rocketmq-all-4.9.0-bin-release ${pkg_install_dir}
echo "ROCKETMQ=${pkg_install_dir}
PATH=\$PATH:\$ROCKETMQ/bin
export ROCKETMQ PATH" >> /etc/profile.d/rocketmq.sh
source /etc/profile.d/rocketmq.sh

# 删除多余的二进制文件
# rm -f ${pkg_install_dir}/bin/*.cmd

printf "\n<<<<<< change rocketmq config \n"
mkdir ${pkg_install_dir}/{logs,data}

host_ip=$(ip a| grep "global"| awk '{print $2}'| awk -F / '{print $1}')
if [ ! -n "${host_ip}" ];then 
        host_ip=$(ip a| grep "global e"| awk '{print $2}'| awk -F / '{print $1}')
fi
echo "namesrvAddr=${host_ip}:9876" >> ${pkg_install_dir}/conf/broker.conf
echo "brokerIP1=${host_ip}" >> ${pkg_install_dir}/conf/broker.conf
echo "storePathRootDir=${pkg_install_dir}/data" >> ${pkg_install_dir}/conf/broker.conf
echo "storePathCommitLog=${pkg_install_dir}/logs" >> ${pkg_install_dir}/conf/broker.conf

# nameserver : broker JVM内存比 1 ：2
mem=$(free -m | sed -n '2p'| awk '{print int(($2-$3)*0.85/6)}')
nameserver_mem=`expr $mem \* 2`

broker_mem=`expr $mem \* 4`

sed -i  "s/-server -Xms4g -Xmx4g -Xmn2g/-server -Xms${nameserver_mem}m -Xmx${nameserver_mem}m -Xmn${mem}m/"  ${pkg_install_dir}/bin/runserver.sh
sed -i  "s/-server -Xms8g -Xmx8g -Xmn4g/-server -Xms${broker_mem}m -Xmx${broker_mem}m -Xmn${mem}m/"  ${pkg_install_dir}/bin/runbroker.sh

useradd ${user} -s /sbin/nologin  
chown -R ${user}:${user} ${pkg_install_dir}

printf "\n<<<<<< start rocketmq using systemctl \n"
# rmq_namesrv.service
cat >> /etc/systemd/system/rmq_namesrv.service << EOF
[Unit]
# 服务描述
Description=rmq_namesrv
Requires=network.service
After=network.target

[Service]
User=rocketmq
Group=rocketmq
StartLimitBurst=2
StartLimitInterval=30
Environment=JAVA_HOME=${decompression_dir}/jdk1.8.0_301
ExecStart=${pkg_install_dir}/bin/mqnamesrv
ExecStop=${pkg_install_dir}/bin/mqshutdown namesrv
KillMode=none
Restart=on-failure
# time to sleep before restarting the service
RestartSec=30s

[Install]
WantedBy=multi-user.target
EOF

# rmq_broker.service
cat >> /etc/systemd/system/rmq_broker.service << EOF
[Unit]
# 服务描述
Description=rmq_broker
Requires=network.service
After=network.target

[Service]
User=rocketmq
Group=rocketmq
StartLimitBurst=2
StartLimitInterval=30
Environment=JAVA_HOME=${decompression_dir}/jdk1.8.0_301
ExecStart=${pkg_install_dir}/bin/mqbroker
ExecStop=${pkg_install_dir}/bin/mqshutdown broker
KillMode=none
Restart=on-failure
# time to sleep before restarting the service
RestartSec=30s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start rmq_namesrv.service
systemctl start rmq_broker.service

sleep 20
printf "\n<<<<<< show rocketmq service status \n"
systemctl status rmq_namesrv.service
systemctl status rmq_broker.service

printf "\n<<<<<< show rocketmq node status \n"


printf "\n<<<<< install rocketmq completed\n"

unset user
unset mem
unset nameserver_mem
unset broker_mem
unset pkg_dir
unset decompression_dir
unset pkg_install_dir