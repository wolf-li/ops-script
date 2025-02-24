#!/bin/bash
# auth: wolf-li
# date: 2025-02-24
# version: 0.1
# description: trouble shooting disk space full

# Disk Space Full
# Salient Phenomena:
# Unable to create new files or write data.
# I see a "no space left on device" error in the syslog.
# The app doesn't work properly or crashes.
# Troubleshooting solution:
# Use the df -h command to view disk space usage and identify full partitions.
# Use the du -sh /* command to find directories that take up a lot of space.
# Clean up temporary, log, and unnecessary files.
# Consider increasing disk space or moving data to other partitions.

#!/bin/bash
LOG_FILE="/var/log/disk_monitor.log"
THRESHOLD=90  # 磁盘使用率阈值，单位：%

df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print $5 " " $1}' | while read -r output; do
    usep=$(echo "$output" | awk '{print $1}' | cut -d'%' -f1)
    partition=$(echo "$output" | awk '{print $2}')
    if [ "$usep" -ge "$THRESHOLD" ]; then
        echo "$(date) - 磁盘空间不足: $partition ($usep%)" >> "$LOG_FILE"
        echo "诊断结果: 磁盘空间使用率过高" >> "$LOG_FILE"
        echo "解决方案建议:" >> "$LOG_FILE"
        echo "1. 使用 'du -sh /*' 查找占用空间较大的目录。" >> "$LOG_FILE"
        echo "2. 清理临时文件、日志文件或不必要的数据。" >> "$LOG_FILE"
        echo "3. 考虑增加磁盘容量或迁移数据到其他分区。" >> "$LOG_FILE"
    fi
done
