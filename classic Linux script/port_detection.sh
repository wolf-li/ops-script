#!/bin/bash
#
# 时间: 2024-1-5
# 版本: 0.1
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：批量服务器IPv4 指定端口探测
# 脚本使用： 

# 定义要测试的主机数组和端口
hosts=(
    1.1.1.1
    2.2.2.2
    3.3.3.3
)
port=22
timeout_seconds=2  # 设置超时时间，单位为秒

# 循环测试每个主机的端口
for host in "${hosts[@]}"; do
  {
    if (echo >/dev/tcp/"$host"/"$port") &> /dev/null; then
      echo "Port $port on $host is open"
    else
      echo "Port $port on $host is closed or connection timed out"
    fi
  } &

  # 设置超时，等待连接完成
  pid=$!
  ( sleep $timeout_seconds && kill -9 $pid && echo -e "\nPort $port on $host is closed or connection timed out") 2>/dev/null

  # 等待子进程完成
  wait $pid 2>/dev/null
done
