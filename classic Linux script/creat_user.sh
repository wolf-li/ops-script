#!/bin/env bash
#
# 时间: 2021-10-26
# 版本: 0.1
# 作者: li
#
# 脚本名称：批量创建用户并设置密码
# 脚本灵感来源: 
# 脚本可以完成的任务：批量创建用户并设置随机密码
# 脚本使用： 
# ./Creating_Users_in_Batches.sh [user_name] [user_name] [user_name] ....

USER_LIST=$@
USER_FILE=./user.INFO
for USER in $USER_LIST;do
    if ! id $USER &>/dev/null;then
        PASS=$(echo $RANDOM|md5sum | cut -c 2-11,14)
        useradd $USER
        echo $PASS | passwd --stdin $USER &>/dev/null
        echo "$USER   $PASS" >> $USER_FILE
        echo "$USER User create successful."
    else
        echo "$USER User already existe!"
    fi
done