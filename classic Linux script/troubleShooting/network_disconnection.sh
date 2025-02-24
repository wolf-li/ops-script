#!/bin/bash
# auth: wolf-li
# date: 2025-02-24
# version: 0.1
# description: trouble shooting network disconnection

# Network Disconnection
# Salient Phenomena:
# Unable to access network resources.
# The ping command could not connect to the target host.
# The ifconfig or ip addr command shows that the network interface status is abnormal.
# Troubleshooting solution:
# Check the network cables and hardware connections.
# Use the ip link show command to check the network interface status.
# Check the network configuration file to make sure it is configured correctly.
# Use the traceroute command to diagnose network path issues.

#!/bin/bash
LOG_FILE="/var/log/network_monitor.log"
TARGET="8.8.8.8"  # 测试目标，可修改

if ! ping -c 1 "$TARGET" &> /dev/null; then
    echo "$(date) - 无法连接到 $TARGET" >> "$LOG_FILE"
    echo "诊断结果: 网络连接中断" >> "$LOG_FILE"
    echo "解决方案建议:" >> "$LOG_FILE"
    echo "1. 检查网络电缆和硬件连接。" >> "$LOG_FILE"
    echo "2. 使用 'ip link show' 查看网络接口状态。" >> "$LOG_FILE"
    echo "3. 检查网络配置文件，确保设置正确。" >> "$LOG_FILE"
    echo "4. 使用 'traceroute' 诊断网络路径问题。" >> "$LOG_FILE"
fi
