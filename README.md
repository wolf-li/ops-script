<p align="center">
  <h1>运维脚本合集</h1>
</p>
<span id="nav-1"></span>

## 内容目录

<details>
  <summary>点我 打开/关闭 目录列表</summary>

- [内容目录](#内容目录)
- [项目介绍](#项目介绍)
- [功能特色](#功能特色)
- [仓库结构](#仓库结构)
- [新手入门](#新手入门)
- [目前完成情况](#目前完成情况)
  - [中间件安装卸载脚本](#中间件安装卸载脚本)
  - [经典脚本案例](#经典脚本案例)
- [版权许可](#版权许可)

</details>

<span id="nav-2"></span>

## 项目介绍

主要存放运维工作经常使用的脚本。

<span id="nav-3"></span>

## 功能特色

- 一键安装/卸载中间件和数据库
  - 自动根据机器硬件配置对中间件进行配置调优
  - 启用 systemd 控制中间件
  - 启用防火墙策略对中间件安装主机进行加固
- 经典脚本

<span id="nav-4"></span>

## 仓库结构

```
|—— .gitlab                         
| |—— issue_templates                GitLab Issue 模板
| | |—— Bug.md                       GitLab Issue Bug 模板
|—— classic Linux script             Linux 经典脚本案例
|—— soft                             存放软件安装、卸载脚本目录
| | |—— 单点部署                     （旧代码不要使用）
| | |—— elasticsearch                
| | | | |—— install.sh               安装脚本
| | | | |—— uninstall.sh             卸载脚本
......
......
|—— windows script                   Windows 经典脚本案例
| |—— autoLoginWeb                     web 自动登录
|—— LICENSE                          许可证
|—— README.md                        介绍页面
```

## 新手入门

下载脚本中提供的软件安装连接，下载脚本放在软件压缩包同一级目录下。

```
./install.sh   安装相应软件
./uninstall.sh 卸载相应软件
```

<span id="nav-6"></span>

## 目前完成情况

### 中间件安装卸载脚本

- [x] Nginx 1.20.1  
- [x] Elasticsearch 6.8.5  
- [x] Kafka 2.8.1  
- [x] Zookeeper 3.7.0  
- [x] RocketMQ 4.9.0  
- [x] FastDFS 5.11  
- [x] Redis 3.2.8  

### 经典脚本案例

- [x] 1. 系统初始化  
- [x] 2. 邮件告警  
- [x] 3. 批量创建 100 个用户并设置密码  
- [x] 4. 一键查看服务器资源利用率  
- [x] 5. 找出占用 CPU/内存过高的进程  
- [x] 6. 查看网卡实时流量  
- [x] 7. 监控 100 台服务器磁盘利用率  
- [x] 8. 批量检查网站是否异常  
- [x] 9. 批量主机执行命令  
- [ ] 10. 一键部署 LNMP 网站平台  
- [x] 11. 监控 MYSQL 主从同步状态是否有异常  
- [x] 12. MYSQL 数据库备份  
- [x] 13. nginx 日志访问分析  
- [x] 14. nginx 日志访问日志自动按天切割
- [x] 15. 自动发布 JAVA 项目（tomcat）  
- [x] 16. 自动发布 PHP 项目  
- [x] 17. DOS 攻击防范 （自动屏蔽攻击 IP）  
- [x] 18. 文件变化监控  
- [x] 19. 批量修改用户密码


<span id="nav-7"></span>

## 版权许可

[License MIT](LICENSE)
