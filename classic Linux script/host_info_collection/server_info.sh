#!/bin/bash
# date: 2025-02-24
# auth: grok3
# description: show hardware infomation

# 设置颜色
GREEN='\033[0;32m'
NC='\033[0m' # 无颜色

echo -e "${GREEN}=== 服务器硬件信息收集脚本 ===${NC}"
echo "当前日期: $(date)"
echo "主机名: $(hostname)"
echo "-----------------------------------"

# 1. 系统基本信息
echo -e "${GREEN}1. 系统信息${NC}"
echo "操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo "无法获取")"
echo "内核版本: $(uname -r)"
echo "是否虚拟机: $(if [ -n "$(systemd-detect-virt 2>/dev/null)" ]; then echo "是 ($(systemd-detect-virt))"; else echo "否 (物理机)"; fi)"
echo "是否Docker容器: $(if [ -f /.dockerenv ]; then echo "是"; else echo "否"; fi)"

# 2. 产品信息和序列号
echo -e "${GREEN}2. 产品信息${NC}"
if command -v dmidecode >/dev/null 2>&1; then
    echo "制造商: $(sudo dmidecode -s system-manufacturer 2>/dev/null || echo "无法获取")"
    echo "产品名: $(sudo dmidecode -s system-product-name 2>/dev/null || echo "无法获取")"
    echo "序列号: $(sudo dmidecode -s system-serial-number 2>/dev/null || echo "无法获取")"
    echo "UUID: $(sudo dmidecode -s system-uuid 2>/dev/null || echo "无法获取")"
    echo "版本: $(sudo dmidecode -s system-version 2>/dev/null || echo "无法获取")"
    echo "SKU 编号: $(sudo dmidecode -s system-sku-number 2>/dev/null || echo "无法获取")"
else
    echo "dmidecode 未安装，无法获取产品信息"
fi

# 3. CPU 信息
echo -e "${GREEN}3. CPU 信息${NC}"
if command -v lscpu >/dev/null 2>&1; then
    lscpu 2>/dev/null || echo "无法获取 CPU 信息"
else
    echo "CPU 型号: $(cat /proc/cpuinfo | grep "model name" | head -n1 | cut -d':' -f2 | sed 's/^[ \t]*//')"
    echo "物理 CPU 数量: $(cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l)"
    echo "逻辑 CPU 核心数: $(nproc)"
fi

# 4. 内存信息
echo -e "${GREEN}4. 内存信息${NC}"
if command -v free >/dev/null 2>&1; then
    free -h 2>/dev/null || echo "无法获取内存信息"
    dmidecode -t memory
else
    echo "free 未安装，无法获取内存信息"
fi

# 5. 硬盘信息
echo -e "${GREEN}5. 硬盘信息${NC}"
if command -v lsblk >/dev/null 2>&1; then
    lsblk -d -o NAME,SIZE,TYPE,MODEL 2>/dev/null || echo "无法获取硬盘信息"
else
    echo "lsblk 未安装，无法获取硬盘信息"
fi

# 6. 扩展卡信息 (网卡、RAID 卡、HBA 卡等)
echo -e "${GREEN}6. 扩展卡信息${NC}"
if command -v lspci >/dev/null 2>&1; then
    echo "PCI 设备列表:"
    lspci | grep -E "Ethernet|RAID|Storage|Host bridge" 2>/dev/null || echo "未检测到扩展卡"
else
    echo "lspci 未安装，无法获取 PCI 设备信息"
fi

# 7. 网卡信息
echo -e "${GREEN}7. 网卡信息${NC}"
for interface in $(ip link | grep -oP '(?<=^\d: ).*?(?=:)'); do
    echo "接口: $interface"
    echo "状态: $(ip link show $interface | grep -o "state [A-Z]*" | cut -d' ' -f2)"
    echo "MAC 地址: $(ip link show $interface | grep -o "ether [0-9a-f:]*" | cut -d' ' -f2)"
    echo "IP 地址: $(ip addr show $interface | grep -o "inet [0-9./]*" | cut -d' ' -f2)"
    echo "---"
done

# 8. 风扇信息 (需要 ipmitool 或其他工具)
echo -e "${GREEN}8. 风扇信息${NC}"
if command -v ipmitool >/dev/null 2>&1; then
    sudo ipmitool sensor | grep -i fan 2>/dev/null || echo "未检测到风扇信息"
else
    echo "ipmitool 未安装，无法获取风扇信息"
fi

# 9. 电源信息
echo -e "${GREEN}9. 电源信息${NC}"
if command -v ipmitool >/dev/null 2>&1; then
    sudo ipmitool sdr type "Power Supply" 2>/dev/null || echo "未检测到电源信息"
else
    echo "ipmitool 未安装，无法获取电源信息"
fi

# 10. GPU 信息
echo -e "${GREEN}10. GPU 信息${NC}"
if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv 2>/dev/null || echo "未检测到 NVIDIA GPU"
elif command -v lspci >/dev/null 2>&1; then
    lspci | grep -i "VGA\|3D" 2>/dev/null || echo "未检测到 GPU"
else
    echo "未安装 nvidia-smi 或 lspci，无法获取 GPU 信息"
fi

# 11. 主板信息
echo -e "${GREEN}11. 主板信息${NC}"
if command -v dmidecode >/dev/null 2>&1; then
   echo "主板型号:"
   dmidecode -s baseboard-product-name
   echo "主板序列号："
   dmidecode -s baseboard-serial-number
else
   echo "未安装 dmidecode，无法获取主板信息"
fi

echo -e "${GREEN}=== 信息收集完成 ===${NC}"
