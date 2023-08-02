#!/bin/bash
#
# aim: install singal nacos 2.2.3
# date: 7-27-2023
# nacos 下载地址：https://github.com/alibaba/nacos/releases
# enviroment: CentOS 7, 银河麒麟v10
# version: 0.1
# author: li

if [ "$(id -u)" -ne 0 ]; then
    echo "Not root user, exit."
    exit 1
fi

decompression_dir=/data
pkg_install_dir=/data/nacos
pkg_name=nacos-server-2.2.3
username=nacos

if [[  ! -f  "${pkg_name}.tar.gz" || ! -f "jdk-8u301-linux-x64.tar.gz"  ]] ; then
    echo "${pkg_name}.tar.gz package or jdk-8u301-linux-x64.tar.gz is not exist"
    exit
fi

printf "\n<<<<<< install jdk \n"
tar xzf jdk-8u301-linux-x64.tar.gz -C ${decompression_dir}
tar xzf ${pkg_name}.tar.gz -C ${decompression_dir}
echo "export JAVA_HOME=${decompression_dir}/jdk1.8.0_301
export JRE_HOME=${decompression_dir}/jdk1.8.0_301/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH" >> /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh
java -version

if ! id -u ${username} >/dev/null 2>&1;then 
    useradd ${username} -M -s /sbin/nologin
fi

chown -R ${username}:${username} ${pkg_install_dir}
sed -i "s,export JAVA_HOME,export JAVA_HOME=${decompression_dir}/jdk1.8.0_301,g" ${pkg_install_dir}/bin/startup.sh

printf "\n<<<<<< start $username using systemctl \n"
cat <<EOF > /usr/lib/systemd/system/$username.service
[Unit]
Description=$username server
Wants=network-online.target
After=network.target

[Service]
User=$username
Group=$username
Type=forking
Environment=JAVA_HOME=${decompression_dir}/jdk1.8.0_301
WorkingDirectory=$pkg_install_dir/bin/
ExecStart=$pkg_install_dir/bin/startup.sh -m standalone
ExecStop=${pkg_install_dir}/bin/shutdown.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start $username
systemctl enable $username

sleep 20
printf "\n<<<<<< show $username service status \n"
systemctl status $username --no-pager


# add firewalld configure file
systemctl status firewalld &>/dev/null
if [ $? -eq 0 ]; then
cat << EOF > /etc/firewalld/services/$username.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
    <short>$username</short>
		<description>$username is a centralized service for maintaining configuration information, naming, providing distributed synchronization, and providing group services. Usually used with Kafka.</description>
		<port protocol="tcp" port="8848"/>
		<port protocol="tcp" port="9848"/>
		<port protocol="tcp" port="9849"/>
		<port protocol="tcp" port="7848"/>
</service>
EOF
    systemctl restart firewalld
    firewall-cmd --add-service=$username --permanent
    firewall-cmd --reload
    printf "\n<<<<<< firewall rule already add \n"
fi
printf "\n<<<<<< Install $username completed \n"

# test
service_regist_status=$(curl -s -X POST 'http://127.0.0.1:8848/nacos/v1/ns/instance?serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080')
service_discovery=$(curl -s -X POST 'http://127.0.0.1:8848/nacos/v1/ns/instance?serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080')
service_public_config=$(curl -s -X POST 'http://127.0.0.1:8848/nacos/v1/ns/instance?serviceName=nacos.naming.serviceName&ip=20.18.7.10&port=8080')
service_get_config=$(curl -s -X GET "http://127.0.0.1:8848/nacos/v1/cs/configs?dataId=nacos.cfg.dataId&group=test")

printf "service regist status: $service_regist_status"
echo "service discovery status: $service_discovery"
echo "service public config status: $service_public_config"
echo "service get config: $service_get_config"
