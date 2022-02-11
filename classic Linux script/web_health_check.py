#!/bin/env bash
#
# 时间: 2021-10-29
# 版本: 0.1
# 作者: li
#
# 脚本名称：web_check.sh 
# 脚本灵感来源: 
# 脚本可以完成的任务：探测指定网站是否存活
# 脚本使用： ./web_check.sh

import os

protocal='https://'
app=['cloudbases',
'bigdata',
'configcenter',
'datalake',
'develop',
'git',
'task',
'devops',
'gateway',
'paas',
'maven',
'harbor',
'api',
'iot']
domain_name='.cscec.com'
env=['-uat','-dev','']
command=[]
urls=[]

for i in range(len(app)):
    for j in range(len(env)):
        urls.append(protocal+app[i]+env[j]+domain_name)
        command.append(' curl -sL -w "%{http_code}" '+urls[-1]+' -o /dev/null')
        
for cmd_tmp in range(len(command)):
    print(urls[i])
    fail_time=0
    for try_tmp in range(3):
        http_code=os.popen(command[i]).read()
        if http_code == '200':
            break
        else:
            fail_time = fail_time + 1
    if fail_time == 3:
        print("connect fail")
    else:
        print("connect normally ")