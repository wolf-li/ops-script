#!/bin/bash
#
# 时间: 2024-1-5
# 版本: 0.2
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：批量服务器IPv4 指定端口探测
# 脚本使用： 在 hosts_port 配置需要测试的 ip:port 或 domainname:port 格式内容即可

# 定义要测试的主机数组和端口
#!/bin/bash

# 定义要测试的主机数组和端口
hosts_port=(
    ip/domainname:port
)

timeout_seconds=5  # 设置超时时间，单位为秒

# 循环测试每个主机的端口
for i in "${hosts_port[@]}"; do
  host=${i%%:*}
  port=${i##*:}
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


echo "服务器ip" "$(hostname -i)"

