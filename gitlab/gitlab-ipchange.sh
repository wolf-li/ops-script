#!/bin/bash
# description: auto change gitlab url ip
# os: CentOS
# problem: sed "s/\(\s*\)${old_content}/\1${new_content}/g" example.txt  fail

HOST_IP=`ip add | grep global | grep -Po '\w+(\.\w+){3}(?=/)'`
gitlabconfig=`find / -name gitlab.yml -type f`

old_content=`grep -A 2 "## Web server settings" ${gitlabconfig} | grep host: `
new_content='host: '$HOST_IP

sed -i "s/$old_content/    $new_content/g" $gitlabconfig
