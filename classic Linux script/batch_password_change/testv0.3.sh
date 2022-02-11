#!/bin/env bash
#
# 时间: 2021-11-1
# 版本: 0.3
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务: 验证用户密码是否修改成功
# 脚本使用： ./test.sh

# host.info format
# IP username passwd port
# resive command from outside
# 脚本问题： ip 不能相同

# 改进使用 sshpass 一句化搞定
# sshpass -p 41do6z9V+B0cH#X ssh app@10.250.76.33 "echo 1"

OLD_INFO=new_info
for IP in $(awk '/^[^#]/{print $1}' $OLD_INFO); do
 USER=$(awk -v I=$IP 'I==$1{print $2}' $OLD_INFO)
 PASS=$(awk -v I=$IP 'I==$1{print $3}' $OLD_INFO)
 PORT=$(awk -v I=$IP 'I==$1{print $4}' $OLD_INFO)

 echo $IP >> check_host
 sshpass -p $PASS ssh $USER@$IP "echo 1" >> check_host
done
