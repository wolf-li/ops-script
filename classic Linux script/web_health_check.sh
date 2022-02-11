#!/bin/env bash
#
# 时间: 2021-10-29
# 版本: 0.1
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：测试网站是否存活
# 脚本使用：./web_health_check.sh

url=(
    'harbor.cscec.com'
    'maven.cscec.com'
)


for i in ${url[*]};do
    fail_time=0
    for ((j=1;j<=3;j++)); do
        http_code=$(curl -sL -w "%{http_code}"  "https://$i" -o /dev/null)
        if [ $http_code -eq 200 ];then
            break
        else
            let fail_time++
        fi
        unset http_code
    done
    if [ $fail_time -eq 3 ];then
        printf "\n $i connect fail \n"
    else
        printf "\n $i connect successful \n"
    fi
done

unset url