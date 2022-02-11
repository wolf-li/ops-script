#!/bin/env bash
#
# 时间: 2021-10-27
# 版本: 0.2
# 作者: li
#
# 脚本名称：服务器检测脚本 
# 脚本灵感来源: 
# 脚本可以完成的任务：
# 检测 cpu
# 检测 memory
# 检测 disk
# 检测 tcp、udp 连接状态
# 脚本使用： ./check_server.sh

# pass line
mem=80
disk=85

# show cpu use status

cpu_status(){
us=70
ys=30
ni=5
printf "##### show the cpu used status #######"
printf "\n CPU status : $(top -bn 1 -i -c| grep Cpu | awk '{print $2":"$3" "$4":"$5" "$6":"$7}')\n"

if [ $(echo " ${us} > $(top -bn 1 -i -c| grep Cpu | awk '{print $2}') "|bc) -eq 1 ];then
        printf "\n>>>>> us is [ok]"
else
        printf "\n>>>>> us is  out of pass line 70%%"
fi
if [ $(echo " ${ys} > $(top -bn 1 -i -c| grep Cpu | awk '{print $4}') "|bc) -eq 1 ];then
        printf "\n>>>>> ys is [ok]"
else
        printf "\n>>>>> ys is  out of pass line 30%%"
fi
if [ $(echo " ${ni} > $(top -bn 1 -i -c| grep Cpu | awk '{print $6}') "|bc) -eq 1 ];then
        printf "\n>>>>> ni is [ok]\n\n"
else
        printf "\n>>>>> ni is  out of pass line 5%%  \n"
fi

unset ni
unset ys
unset us
}

# show free use status

memory_status(){
printf "##### show the ram used status #######\n"
free -m | sed -n '2p' | awk '{print "\n used mem is "$3"M\n total mem is "$2"M\n used percent is "$3/$2*100"%"}'
memory_used=$(free -m | sed -n '2p'| awk '{print $3/$2*100}')

if [ $(echo " ${mem} > ${memory_used} "|bc) -eq 1 ];then
        printf "\n>>>>> memory is [ok]\n\n"
else
        printf "\n>>>>> memory is  out of pass line 80%% \n\n"
fi

unset memory_used
unset mem
}

# show disk use status

disk_status(){
printf "##### show the disk used status #######"
disk_used=($( df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|boot|docker' | awk '{print $5}'))
printf "\n<<<<<< the disk used:\n\n"
disk_using=$( df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem|boot|docker' | awk '{print " mount: "$6"\n used size: "$3"\n utilization Rate: "$5}')
echo "${disk_using}"


for disk_u in ${disk_used[*]};do
disk_u=${disk_u%\%}
if [ $disk -gt $disk_u ];then
        printf "\n>>>>> disk is [ok]\n"
else
        printf "\n>>>>> disk is  out of pass line 85%% \n\n"
fi
done

unset disk_used
unset disk_using
unset disk_u
unset disk
}

socket_status(){
    printf "\n\n##### show the socket status #######\n"
    ss -s
    printf "<<<<<< display all tcp and udp connect:\n\n"
    ss -tua
}

cpu_status
memory_status
disk_status
socket_status
