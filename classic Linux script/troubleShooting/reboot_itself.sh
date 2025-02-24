#!/bin/bash
# auth: wolf-li
# date: 2025-02-24
# version: 0.1
# description: trouble shooting linux reboot itself

# 检查是否有 root 权限
if [[ $EUID -ne 0 ]]; then
   echo "请以 root 用户身份运行此脚本。"
   exit 1
fi

# 检查系统日志
echo "检查系统日志..."
journalctl -b -1 -p err..alert

# 检查内核日志
echo "检查内核日志..."
dmesg | grep -i error

# 检查硬件状态
echo "检查硬件状态..."
# 检查内存错误
grep -i memory /var/log/kern.log

# 检查硬盘状态
smartctl -a /dev/sda  # 根据实际硬盘设备名称调整

# 检查电源状态
echo "检查电源状态..."
upower -i /org/freedesktop/UPower/devices/line_power_AC  # 根据实际电源设备调整

# 检查系统负载
echo "检查系统负载..."
uptime
cat /proc/loadavg

# 检查定时任务
echo "检查定时任务..."
cat /etc/crontab
ls -l /etc/cron.d/
ls -l /var/spool/cron/crontabs/

# 检查最近的重启记录
echo "检查最近的重启记录..."
last -x | grep reboot

echo "故障定位完成，请根据上述信息进行分析。"
