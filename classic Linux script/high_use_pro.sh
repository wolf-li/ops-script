#!/bin/env bash
#
# 时间: 2021-10-27
# 版本: 0.1
# 作者: li
#
# 脚本名称：high_use_pid
# 脚本灵感来源: 
# 脚本可以完成的任务：列出使用资源较高的前10进程
# 脚本使用：./high_use_pid.sh

printf "\n<<<<<<< high use mem top 10 pid\n"
ps -eo pid,pmem,command --sort=pmem | head -10
printf "\n<<<<<<< high use mem top 10 pid\n"
ps -eo pid,pcpu,command --sort=pcpu | head -10