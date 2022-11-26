# 一、启动服务

分配权限(最重要的一步)
为所有目录包括子目录分配读写权限 没有写权限无法存储 会报错无法启动

```bash
chmod -R 777 /docker/rocketmq
```

```bash
git clone https://github.com/Lancger/rocketmq-docker.git

docker-compose up -d
```

基于官网仓库 https://github.com/apache/rocketmq-docker 同步构建多版本支持 

# 参考资料：

https://www.pudn.com/news/62a9d0c8dfc5ee19686f780c.html  Docker 安装 RocketMQ-4.9.3：DLedger多副本集群
