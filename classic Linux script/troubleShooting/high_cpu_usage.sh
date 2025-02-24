#!/bin/bash
# auth: wolf-li
# date: 2025-02-24
# version: 0.1
# description: trouble shooting high cpu usage

# Salient Phenomena:
# The system is slow to respond.
# The top or htop command shows that a process is experiencing consistently high CPU usage.
# The system temperature may rise.
# Troubleshooting solution:
# Use the top or htop command to identify processes that are taking up too much CPU.
# Use the ps -aux command to view the details of the process.
# Check the process's log files for unusual behavior.
# Consider optimizing your application or limiting the CPU usage of your process.

#!/bin/bash
LOG_FILE="/var/log/cpu_monitor.log"
THRESHOLD=80  # CPU 使用率阈值，单位：%

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
echo "$(date) - CPU 使用率: $CPU_USAGE%" >> "$LOG_FILE"

if (( $(echo "$CPU_USAGE > $THRESHOLD" | bc -l) )); then
    echo "$(date) - CPU 使用率过高: $CPU_USAGE%" >> "$LOG_FILE"
    echo "诊断结果: 可能存在高负载进程或资源争用" >> "$LOG_FILE"
    echo "解决方案建议:" >> "$LOG_FILE"
    echo "1. 使用 'top' 或 'htop' 查看占用 CPU 最高的进程。" >> "$LOG_FILE"
    echo "2. 检查进程日志，定位异常行为。" >> "$LOG_FILE"
    echo "3. 优化应用程序或限制进程的 CPU 使用。" >> "$LOG_FILE"
fi
