#!/bin/env bash
#
# 时间: 2021-11-3
# 版本: 0.1
# 作者: li
#
# 脚本名称： 
# 脚本灵感来源: 
# 脚本可以完成的任务：MySQL数据备份
# 脚本使用： 


DATE=$(date +%F_%H-%M-%S)
HOST=localhost
USER=
PASS=
BACKUP_DIR=/data/db_backup

DB_LIST=$(mysql -h$HOST -u$USER -p$PASS -s -e "show databases;" 2>/dev/null | egrep -v "Database|information_scheme|mysql|performance_schema|sys")

for DB in $DB_LIST;do
    BACKUP_NAME=$BACKUP_DIR/${DB}_${DATE}.sql
    if ! mysqldump -h$HOST -u$USER -p$PASS -B $DB > $BACKUP_NAME 2>/dev/null; then
        echo "$BACKUP_NAME fail"
    fi
done


