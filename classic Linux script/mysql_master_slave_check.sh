#!/bin/env bash
#
# 时间: 2021-11-2
# 版本: 0.1
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：监控 mysql 主从连接
# 脚本使用： ./mysql_master_slave_monitor.sh

# mysql 主从同步
# mysql master binlog
# slave
# 同步过程
# 写 -> master -> binlog <- relaylog -> slave

HOST=localhost
USER=root
PASSWD=root
IO_SQL_STATUS=$(mysql -h$HOST -u$USER -p$PASSWD -e 'show slave status\G' 2>/dev/null | awk '/Slave_.*_Running:/{print $12}')
for i in $IO_SQL_STATUS; do
    THREAD_STATUS_NAME=${i%:*}
    THREAD_STATUS=${i#*:}
    if [ "$THREAD_STATUS" != "Yes" ];then
        echo "Error: MySQL master-slave $THREAD_STATUS_NAME status is $THREAD_STATUS"
    fi
done



