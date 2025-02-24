#!/bin/bash
# version: 0.1
# auth: wolf-li
# date: 2025-02-24
# description: add new hard drive(HDD)

# 检查是否有 root 权限
if [[ $EUID -ne 0 ]]; then
   echo "请以 root 用户身份运行此脚本。"
   exit 1
fi

# 检查新硬盘是否被识别
echo "扫描新硬盘..."
new_disk=$(lsblk -no NAME,SIZE,TYPE | grep 'disk' | tail -n 1 | awk '{print $1}')

if [[ -z "$new_disk" ]]; then
   echo "未找到新硬盘。"
   exit 1
fi

echo "找到新硬盘: /dev/$new_disk"

# 检查硬盘的 SMART 状态
echo "检查硬盘 SMART 状态..."
smartctl -H /dev/$new_disk
if [[ $? -ne 0 ]]; then
   echo "硬盘 SMART 检查失败。"
   exit 1
fi

# 检查硬盘容量
disk_size=$(lsblk -bno SIZE /dev/$new_disk)
if [[ $disk_size -gt $((2 * 1024 ** 4)) ]]; then
   echo "硬盘容量大于 2TB，使用 parted 创建分区。"
   partition_tool="parted"
else
   echo "硬盘容量小于 2TB，使用 fdisk 创建分区。"
   partition_tool="fdisk"
fi

# 询问用户是否创建分区
read -p "是否创建新分区？(y/n): " create_partition
if [[ $create_partition == "y" ]]; then
   if [[ $partition_tool == "parted" ]]; then
      echo "使用 parted 创建新分区..."
      parted -s /dev/$new_disk mklabel gpt
      parted -s /dev/$new_disk mkpart primary 0% 100%
   else
      echo "使用 fdisk 创建新分区..."
      echo -e "n\np\n1\n\n\nw" | fdisk /dev/$new_disk
   fi
   sleep 2  # 等待分区表刷新
fi

# 询问用户是否创建文件系统
read -p "是否创建文件系统？(y/n): " create_filesystem
if [[ $create_filesystem == "y" ]]; then
   echo "创建文件系统..."
   mkfs.ext4 /dev/${new_disk}1
   if [[ $? -ne 0 ]]; then
      echo "文件系统创建失败。"
      exit 1
   fi
fi

# 挂载硬盘
mount_point="/mnt/test_disk"
echo "挂载硬盘到 $mount_point..."
mkdir -p $mount_point
mount /dev/${new_disk}1 $mount_point
if [[ $? -ne 0 ]]; then
   echo "硬盘挂载失败。"
   exit 1
fi

# 进行读写测试
test_file="$mount_point/test_file"
echo "进行读写测试..."
dd if=/dev/zero of=$test_file bs=1G count=10
if [[ $? -ne 0 ]]; then
   echo "写测试失败。"
   umount $mount_point
   exit 1
fi

dd if=$test_file of=/dev/null bs=1G
if [[ $? -ne 0 ]]; then
   echo "读测试失败。"
   umount $mount_point
   exit 1
fi

echo "所有测试通过，硬盘可以正常运行。"

# 询问用户是否永久挂载
read -p "是否永久挂载硬盘？(y/n): " permanent_mount
if [[ $permanent_mount == "y" ]]; then
   uuid=$(blkid -o value -s UUID /dev/${new_disk}1)
   echo "UUID=$uuid $mount_point ext4 defaults 0 2" >> /etc/fstab
   echo "硬盘已永久挂载到 $mount_point。"
fi

# 卸载硬盘
umount $mount_point
echo "硬盘已卸载。"
