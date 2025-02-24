#!/bin/bash
# auth: wolf-li
# date: 2025-02-24
# version: 0.1
# description: trouble shooting service crash

# Salient Phenomena:
# The service is inaccessible or unresponsive.
# The systemctl status <service> command shows that the service status is "failed" or "inactive".
# Error messages about service crashes are recorded in the log file.
# Troubleshooting solution:
# Check the service log file to find the cause of the crash.
# Use the journalctl -u <service> command to view the system logs.
# Try to start the service manually and observe the error message.
# Check the servicing profile to make sure it's configured correctly.

#!/bin/bash
SERVICE="ssh"  # 可根据需要修改服务名
LOG_FILE="/var/log/service_monitor.log"

if ! systemctl is-active --quiet "$SERVICE"; then
    echo "$(date) - 服务 $SERVICE 已停止" >> "$LOG_FILE"
    echo "诊断结果: 服务 $SERVICE 崩溃或未运行" >> "$LOG_FILE"
    echo "解决方案建议:" >> "$LOG_FILE"
    echo "1. 使用 'journalctl -u $SERVICE' 查看服务日志。" >> "$LOG_FILE"
    echo "2. 尝试启动服务：'systemctl start $SERVICE' 并检查错误。" >> "$LOG_FILE"
    echo "3. 检查服务配置文件，确保设置正确。" >> "$LOG_FILE"
fi
