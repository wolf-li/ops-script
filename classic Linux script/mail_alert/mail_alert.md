# 使用 mailx + systemd 邮件监控服务
mailx 软件安装
在线：
- CentOS
```
yum install mailx -y
mailx -V    # mailx 版本，检测是否安装成功

# 修改 mailx 配置
vi /etc/mail.rc
set from=                 # 发送邮件邮箱名 （如：xxx@163.com ）
set smtp=smtp.163.com     # 邮件发送服务器
set smtp-auth-user=       # 邮箱用户名
set smtp-auth-password=   # 邮箱用户密码
set smtp-auth=login

# 发送测试邮件
echo '邮件正文'|mailx -v -s "邮件标题" 邮箱地址 
```
创建触发告警的 systemd 任务
```
[Unit]
Description=%i failure email notification

[Service]
Type=oneshot
ExecStart=/bin/bash -c '/root/script/mail_alert.sh  %i'  # 脚本文件见mail_alert.sh
```
将告警任务添加到对应服务的 systemd 中
```
[Unit]
Description=zk.service
After=network.target
OnFailure=service-down-notify-email@%i.service
```
验证
```
systemctl status zookeeper | grep -i pid
kill -9 (zookeeper pid)
查看邮箱
```


文章：
[日志监控+自动告警](https://mp.weixin.qq.com/s?__biz=MzU2NTU2MjIzNQ==&mid=2247488172&idx=2&sn=b302fe5a70f4a63545c9640c0c4ae4ce&chksm=fcb88cb8cbcf05aedf98553fb88bd76da37055448922f11b5dba23f931ebadcc1e8ee766cbd1&mpshare=1&scene=1&srcid=0814ZwC8mBYUyvEeCJ8ihZx8&sharer_sharetime=1597382653226&sharer_shareid=6f243aebe9fbc3604fa7bbcda4395fb6&key=d9259f2335ef3c3cd3c88ff50c1ffc63f20631790b3b72be8be3666f98e3d956653a80db393d6333e1b6ff26834388e80533834eafcd5192046c75b171d22ceddcf5a2deb80a280174315828cceacb500a6fa842d4d0cdf66d4b9ffdf655b18e444c5a2466e52a93a6b9b4daca594960a208373886c9191bf9c0f358468c1705&ascene=1&uin=MjE0MDM3ODYyNw%3D%3D&devicetype=Windows+10+x64&version=62090529&lang=zh_CN&exportkey=A72kEnmJb7ASVKC2r6HmDuQ%3D&pass_ticket=pAEB82ZTmyevlOVa4urt0K%2FH%2ByDWxda8%2F9JsnxsKL%2Fo%2BZ0unCcaOAy5KwfPrEeMM)
[systemd定时器教程](http://www.ruanyifeng.com/blog/2018/03/systemd-timer.html)
[Linux: systemd-unit files edit, restart on failure and email notifications](https://dev.to/setevoy/linux-systemd-unit-files-edit-restart-on-failure-and-email-notifications-5h3k)