#!/bin/bash

date=`date +%Y-%m-%d`

echo -e =======================================================$(hostname -I |awk '{print $1}')==========================================================
total_mem=$(free -h | awk 'NR==2{print $2}')
used_mem=$(free -h | awk 'NR==2{print $3}')
used_percent=$(free -h | sed -n '2p' | awk '{printf ("%.2f\n",$3/$2*100)}')
total_sys_disk=$(df -h | grep vda |awk '{print $2}')
total_sys_used_disk=$(df -h | grep vda |awk '{print $3}')
total_percent_used_disk=$(df -h | grep vda  |awk '{print $5}')
total_data_disk=$(df -h | grep data |awk '{print $2}')
total_data_used_disk=$(df -h | grep data |awk '{print $3}')
total_data_percent_used_disk=$(df -h | grep data|awk '{print $5}')

echo 总内存     已使用内存      内存使用率      系统盘总容量    系统盘使用量    系统盘使用率    数据盘总容量    数据盘使用量    数据盘使用率
echo -e "  $total_mem\t  $used_mem\t    $used_percent"%"\t$total_sys_disk\t      $total_sys_used_disk\t    $total_percent_used_disk\t       $total_data_disk\t      $total_data_used_disk\t    $total_data_percent_used_disk"
if [ -s /data/backup_mysql/${date}_mysql.sql ];then
        echo Mysql Backup OK
else
        echo "Mysql Backup Failed"
fi
if [ `ps -ef |grep mysqld |grep -v grep |wc -l` -gt 0 ];then
        echo "Mysql status is OK"
else
        echo "Mysql status is Failed"
fi