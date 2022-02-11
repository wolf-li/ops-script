#!/bin/bash
date=`date +%Y%m%d`
function  for_in_file() {
        for  i  in  `cat /data/iplist`
do
        ssh $i "sh /data/check_host.sh" >> /data/log/${date}_check_host.txt
done
}
for_in_file

find /data/log -type f -mtime +7 -exec rm -f {} \;