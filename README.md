# 一、启动服务

```bash
git clone https://github.com/Lancger/rocketmq-docker.git
```

```bash
cd /data0/rocketmq-docker
docker-compose up -d
```

分配权限(最重要的一步)
为所有目录包括子目录分配读写权限 没有写权限无法存储 会报错无法启动

```bash
#需要修改权限，不然rmqbroker启动失败，异常code为253
chown -R 777 /data0/rocketmq
#或者
chown -R 3000:3000 /data0/rocketmq

#再次启动服务就能成功了
docker-compose up -d
```

基于官网仓库 https://github.com/apache/rocketmq-docker 同步构建多版本支持 

# 参考资料：

https://www.pudn.com/news/62a9d0c8dfc5ee19686f780c.html  Docker 安装 RocketMQ-4.9.3：DLedger多副本集群
