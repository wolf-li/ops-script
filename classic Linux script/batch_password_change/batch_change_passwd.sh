#!/bin/env bash
#
# 时间: 2021-11-1
# 版本: 0.2
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：使用 expect 批量修改用户密码适用于中建环境
# 脚本使用： ./batch_change_passwd

# host.info format
# IP username passwd port
# resive command from outside
# 脚本问题： ip 不能相同

OLD_INFO=old_info
NEW_INFO=new_info
for IP in $(awk '/^[^#]/{print $1}' $OLD_INFO); do
 USER=$(awk -v I=$IP 'I==$1{print $2}' $OLD_INFO)
 PASS=$(awk -v I=$IP 'I==$1{print $3}' $OLD_INFO)
 PORT=$(awk -v I=$IP 'I==$1{print $4}' $OLD_INFO)
 NEW_PASS=$(tr -cd '_a-zA-Z0-9' < /dev/urandom | head -c 16)
 echo "$IP $USER $NEW_PASS $PORT" >> $NEW_INFO

/usr/bin/expect <<EOF
        set time 6
        spawn ssh -p$PORT $USER@$IP
        expect {
                "(yes/no)" {
                        send "yes\r" }
                "*password:" {
                        send "$PASS\r"
                        expect "$USER@*"
                        send "passwd\r"
                        exec sleep 1 }
        }
        expect {
                "(current) UNIX password:*" {
                        send "$PASS\r"
                        exec sleep 1}
        }
	expect { 
		"New password:*" { 
                        send "$NEW_PASS\r" 
			exec sleep 0.3}
	}
        expect {
		"Retype new password:*" {
                        send "$NEW_PASS\r"
                        exec sleep 0.5
                        send "exit\r"
                }
        }
	expect eof
EOF
done
