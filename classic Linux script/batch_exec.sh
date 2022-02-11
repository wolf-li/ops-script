#!/bin/env bash
#
# 时间: 2021-11-1
# 版本: 0.1
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：使用 ssh 批量执行命令
# 脚本使用： ./batch_exec.sh [command]

# host.info format
# IP username port passwd
# resive command from outside
# 脚本问题： ip 不能相同
COMMAND=$*
HOST_INFO=host.info
for IP in $(awk '/^[^#]/{print $1}' $HOST_INFO);do
	USER=$(awk -v ip=$IP 'ip==$1{print $2}' $HOST_INFO)
	PORT=$(awk -v ip=$IP 'ip==$1{print $3}' $HOST_INFO)
	PASS=$(awk -v ip=$IP 'ip==$1{print $4}' $HOST_INFO)
	/usr/bin/expect -c "
		spawn ssh -p $PORT $USER@$IP
		expect {
			\"(yes/no)\" {send \"yes\r\"; exp_continue}
			\"password:\" {send \"$PASS\r\"; exp_continue}
			\"$USER@*\" {send \"$COMMAND\r exit\r\"; exp_continue}
		}
	"
	echo "-----------------------"
done