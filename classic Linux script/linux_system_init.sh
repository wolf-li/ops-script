#!/bin/env bash
#
# aim: linux system init
# date: 10-24-2021
# 脚本灵感来源: https://www.bilibili.com/video/BV1k7411r71C?p=1
# 脚本可以完成的任务
#  1.  设置时区并同步时间
#  2.  禁用 selinux
#  3.  清空防火墙默认策略
#  4.  历史命令显示操作时间
#  5.  禁止 root 远程登录
#  6.  禁止定时任务发送邮件
#  7.  设置最大打开文件数
#  8， 减少 swap 使用
#  9.  系统内核参数优化
#  10. 安装系统性能分析工具
# version: 0.1
# author: li

## 设置时区并同步时间
printf "\n<<<<<< 1. Set the time zone and update ntp .\n"
date +%Z%z | grep "CST+0800"
if [ $? -ne 0 ];then
    timedatectl set-timezone Asia/Shanghai
fi

ntp_sync(){
    # 收集的 国内常用 ntp server
    ntp_server_list=(
        ntp.ntsc.ac.cn
        ntp.aliyun.com
        time1.cloud.tencent.com 
        time2.cloud.tencent.com 
        time3.cloud.tencent.com
        time4.cloud.tencent.com
        time5.cloud.tencent.com
        ntp.tuna.tsinghua.edu.cn    
    )
    
    ping -c 1 -W1 8.8.8.8 &> /dev/null
    if [ $? -eq 0 ];then
        for ip in ${ntp_server_list[*]};do
            ping -c 1 -W1 ${ip} &> /dev/null
            if [ $? -eq  0 ]; then
                /usr/sbin/ntpdate -u ${ip}
                printf "ntp sync server  ${ip}"
                break
            fi
        done
    else
        read -p "<<<<<< input the inside ntp server name: " inside_ntp_server
        ping -c 1 -W1 ${inside_ntp_server} &> /dev/null
        if [ $? -eq 0 ];then
            /usr/sbin/ntpdate -u ${inside_ntp_server}
        else
            printf "\n<<<<<< can't connect the inside ntp server ${inside_ntp_server}"
            exit 1
        fi
    fi
}

printf "\n<<<<<< update ntp"
if type ntpdate >/dev/null 2>&1; then 
    echo "ntpdate already exist."
    timedatectl status | grep "DST active: yes"
    if [ $? -ne 0 ];then
        systemctl start ntpd
        systemctl enable ntpd
        ntp_sync
    fi
else 
    yum install -y ntp
    systemctl start ntpd
    systemctl enable ntpd
    ntp_sync
fi


#  2.  禁用 selinux
printf "\n<<<<<< 2. Stop using selinux. \n"
sed -i "/SELINUX/s/permissive/disabled/g;/SELINUX/s/enforcing/disabled/g"  /etc/selinux/config

#  3.  清空防火墙默认策略
if egrep "7.[0-9]" /etc/redhat-release &>/dev/null;then
    systemctl stop firewalld
    systemctl disable firewalld
elif egrep "6.[0-9]" /etc/redhat-release &>/dev/null;then
    service iptables stop
    chkconfig iptables off
fi

#  4.  历史命令显示操作时间
if ! grep HISTTIMEFORMAT /etc/bashrc; then
    echo 'epxort HISTTIMEFORMAT="%F %T `whoami` " ' >> /etc/profile
fi

#  5.  禁止 root 远程登录
if ! grep "TMOUT=600" /etc/profile &>/dev/null;then
    echo "export TMOUT=600" >> /etc/profile
fi
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

#  6.  禁止定时任务发送邮件
sed -i 's/^MAILTO=root/MAILTO=""/'  /etc/crontab

#  7.  设置最大打开文件数
if ! grep "* soft nofile 65535" /etc/security/limits.conf &>/dev/null;then
cat >> /etc/security/limits.conf << EOF
* soft nofile 65535
* hard sofile 65535
EOF
fi

#  9.  系统内核参数优化
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_tw_buckets = 20480
net.ipv4.tcp_max_syn_backlog = 20480
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_fin_timeout = 20
EOF

#  8， 减少 swap 使用
## swappiness=0的时候表示最大限度使用物理内存，然后才是 swap空间
echo "0" > /proc/sys/vm/swappiness
# 不使用 swap
# swapoff -a
# sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab

sysctl -p

#  10. 安装系统性能分析工具
yum install gcc make autoconf vim sysstat iostat iftop iotop lrzsz -y

