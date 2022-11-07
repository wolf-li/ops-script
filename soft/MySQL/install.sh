#!/bin/bash
#
# aim: install singal mysql 5.7.x
# date: 2022-6-8
# mysql下载地址：https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.35-el7-x86_64.tar.gz 
# enviroment: CentOS 7
# version: 0.1
# author: wolf-li


dir=/data
user=mysql
install_mysql_version=mysql-5.7.35
install_dir=$dir/$install_mysql_version
port=3306

printf "Check whether the port is used: "
portNum=`ss -ntpl | grep ${port} | wc -l`
if [[ $portNum -gt 0 ]];then
    echo -e "\033[31m tcp port ${port} already use try to other port !!!\033[0m"
    exit 1
else
    echo -e "\033[32m pass\033[0m"
fi


# 判断用户是否为 root 否则不执行
if [[ $EUID -ne 0 ]]
then
    echo "Now your are not root, you should change root to exec this script";
    exit 1
fi

if [[  ! -f  "$install_mysql_version-el7-x86_64.tar.gz" ]] ; then
    echo "$install_mysql_version-el7-x86_64.tar.gz package is not exist"
    exit 1
fi

if [ ! -d $dir ];then
    mkdir $dir &>/dev/null
fi

grep $user /etc/passwd &>/dev/null
if [ $? -ne 0 ];then
    useradd $user -M -s /sbin/nologin
fi
mkdir -p /var/lib/mysql

tar xzf $install_mysql_version-el7-x86_64.tar.gz -C $dir
mv /data/$install_mysql_version-el7-x86_64/ /data/$install_mysql_version
mkdir -p /data/$install_mysql_version/{data,logs}
yum install -y autoconf

cat << EOF > /etc/my.cnf
[client]
port=${port}
socket=/var/lib/mysql/mysql.sock
default-character-set=utf8

[mysql]
no-auto-rehash
default-character-set=utf8

[mysqld]
port=${port}
character-set-server=utf8
socket=/var/lib/mysql/mysql.sock
basedir=$install_dir
datadir=$install_dir/data
explicit_defaults_for_timestamp=true
lower_case_table_names=1
back_log=103
max_connections=3000
max_connect_errors=100000
table_open_cache=512
external-locking=FALSE
max_allowed_packet=32M
sort_buffer_size=2M
join_buffer_size=2M
thread_cache_size=51
query_cache_size=32M
transaction_isolation=REPEATABLE-READ
tmp_table_size=96M
max_heap_table_size=96M
log-error=$install_dir/logs/error.log
###***slowqueryparameters
long_query_time=1
slow_query_log = 1
slow_query_log_file=$install_dir/logs/slow.log
read_buffer_size=1M
read_rnd_buffer_size=16M
bulk_insert_buffer_size=1M


skip-name-resolve

###***master-slavereplicationparameters
#slave-skip-errors=all

#***Innodbstorageengineparameters
innodb_buffer_pool_size=512M
innodb_data_file_path=ibdata1:10M:autoextend
#innodb_file_io_threads=8
innodb_thread_concurrency=16
innodb_flush_log_at_trx_commit=1
innodb_log_buffer_size=16M
innodb_log_file_size=512M
innodb_log_files_in_group=2
innodb_max_dirty_pages_pct=75
innodb_lock_wait_timeout=50
innodb_file_per_table=on

[mysqldump]
quick
max_allowed_packet=32M

[myisamchk]
key_buffer=16M
sort_buffer_size=16M
read_buffer=8M
write_buffer=8M

[mysqld_safe]
open-files-limit=8192
log-error=$install_dir/logs/error.log
pid-file=$install_dir/mysqld.pid
EOF

chown 644 /etc/my.cnf

sed -i "s,/usr/local/mysql,$install_dir," $install_dir/support-files/mysql.server

chown -R $user:$user /var/lib/mysql $install_dir

$install_dir/bin/mysqld --initialize --user=mysql --basedir=$install_dir --datadir=$install_dir/data/

cp $install_dir/support-files/mysql.server /etc/rc.d/init.d/mysqld
chmod 755 /etc/init.d/mysql &>/dev/null
sed -i "s#^basedir=.*#basedir=$install_dir#" /etc/init.d/mysql &>/dev/null
sed -i "s#^datadir=.*#datadir=$install_dir\/data#" /etc/init.d/mysql &>/dev/null
chkconfig --add mysqld &>/dev/null
chkconfig mysqld on &>/dev/null
service mysqld start &>/dev/null

echo "MySQL=$install_dir
PATH=\$PATH:\$MySQL/bin
export MySQL PATH" >> /etc/profile.d/MySQL.sh
source /etc/profile.d/MySQL.sh

systemctl status firewalld &>/dev/null
if [ $? -eq 0 ]; then
    firewall-cmd --add-port=${port}/tcp --permanent
    firewall-cmd --reload
fi

echo "password is:" $(awk '/A temporary password/{print substr($0,length($0)-11)}' $install_dir/logs/error.log)
