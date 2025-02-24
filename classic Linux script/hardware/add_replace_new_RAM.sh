#!/bin/bash
# version: 0.1
# date: 2025-02-24
# auth: wolf-li
# description: add or replace new RAM to test RAM work

# 检查是否有 root 权限
if [[ $EUID -ne 0 ]]; then
   echo "请以 root 用户身份运行此脚本。"
   exit 1
fi

# 检查内存信息
echo "检查内存信息..."
dmidecode -t memory | grep -E 'Size|Type|Speed'

# 检查是否安装了 memtest86+
if ! command -v memtest86+ &> /dev/null; then
   echo "memtest86+ 未安装，请先安装 memtest86+。"
   exit 1
fi

# 询问用户是否进行内存基本测试
read -p "是否进行内存基本测试？(y/n): " basic_test
if [[ $basic_test == "y" ]]; then
   echo "进行内存基本测试..."
   memtest86+
   if [[ $? -ne 0 ]]; then
      echo "内存基本测试失败。"
      exit 1
   fi
fi

# 检查是否安装了 stress-ng
if ! command -v stress-ng &> /dev/null; then
   echo "stress-ng 未安装，请先安装 stress-ng。"
   exit 1
fi

# 询问用户是否进行内存压力测试
read -p "是否进行内存压力测试？(y/n): " stress_test
if [[ $stress_test == "y" ]]; then
   # 询问用户压力测试时间
   read -p "请输入压力测试时间（分钟）: " test_time
   echo "进行内存压力测试，时间为 $test_time 分钟..."
   stress-ng --vm 4 --vm-bytes 95% --timeout ${test_time}m
   if [[ $? -ne 0 ]]; then
      echo "内存压力测试失败。"
      exit 1
   fi
   echo "内存压力测试通过。"
fi

echo "所有测试通过，内存可以正常运行。"
