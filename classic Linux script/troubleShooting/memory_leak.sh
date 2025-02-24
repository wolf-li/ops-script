#!/bin/bash
# auth: wolf-li
# date: 2025-02-24
# version: 0.1
# description: trouble shooting memory leak
# Memory Leak
# Salient Phenomena:
# System memory usage continues to increase, even when there is no significant load.
# The application becomes slower or unresponsive.
# The system starts using swap space, resulting in degraded performance.
# Troubleshooting solution:
# Use the top or htop command to view memory usage and identify processes that are taking up too much memory.
# Use the free -m command to see how much system memory and swap space is being used.
# Use tools such as Valgrind to perform memory leak detection on your application.
# Check the application's log files for memory-related error messages.


LOG_FILE="/var/log/memory_monitor.log"
THRESHOLD=80  # 内存使用率阈值，单位：%

MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
echo "$(date) - 内存使用率: $MEMORY_USAGE%" >> "$LOG_FILE"

if (( $(echo "$MEMORY_USAGE > $THRESHOLD" | bc -l) )); then
    echo "$(date) - 内存使用率过高: $MEMORY_USAGE%" >> "$LOG_FILE"
    echo "诊断结果: 可能存在内存泄漏或高负载进程" >> "$LOG_FILE"
    echo "解决方案建议:" >> "$LOG_FILE"
    echo "1. 使用 'top' 或 'htop' 查看占用内存最高的进程。" >> "$LOG_FILE"
    echo "2. 检查应用程序日志，定位内存相关错误。" >> "$LOG_FILE"
    echo "3. 考虑重启相关服务或优化应用程序内存使用。" >> "$LOG_FILE"
fi
