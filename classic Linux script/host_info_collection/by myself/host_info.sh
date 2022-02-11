#!/bin/env bash
host_ip=$(hostname -I |awk '{print $1}')
total_mem=$(free -h | awk 'NR==2{print $2}')
used_mem=$(free -h | awk 'NR==2{print $3}')
used_percent=$(free -m | sed -n '2p'| awk '{print $3/$2*100}')
total_sys_disk=$(df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|boot|docker'  | awk '{print $2}' | sed -n 1p)
total_sys_used_disk=$(df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|boot|docker'  | awk '{print $3}' | sed -n 1p)
total_percent_used_disk=$(df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|boot|docker'  | awk '{print $5}' | sed -n 1p)
total_data_disk=$(df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|boot|docker'  | awk '{print $2}' | sed -n 2p)
total_data_used_disk=$(df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|boot|docker'  | awk '{print $3}' | sed -n 2p)
total_data_percent_used_disk=$(df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|boot|docker'  | awk '{print $5}' | sed -n 2p)

echo -e "$host_ip\t ${total_mem}\t ${used_mem}\t ${used_percent}"%"\t ${total_sys_disk}\t ${total_sys_used_disk}\t ${total_percent_used_disk}\t ${total_data_disk}\t  ${total_data_used_disk}\t ${total_data_percent_used_disk}"