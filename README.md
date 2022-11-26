# 一、启动服务

1、获取代码文件

```bash
git clone https://github.com/Lancger/rocketmq-docker.git
```

2、修改对应 `rocketmq-docker/broker/conf/broker.conf` 配置文件中对应的`brokerIP1`信息

```bash
cd /data0/rocketmq-docker
docker-compose up -d
```

3、分配权限

最重要的一步，为所有目录包括子目录分配读写权限 没有写权限无法存储 会报错无法启动

```bash
root># docker ps -a
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS                        PORTS                                                                   NAMES
d71eec72d6f9   apache/rocketmq:4.9.4           "sh mqbroker -c /etc…"   14 seconds ago   Exited (253) 12 seconds ago                                                                           rmqbroker
b89d017b8363   styletang/rocketmq-console-ng   "sh -c 'java $JAVA_O…"   14 seconds ago   Up 12 seconds                 0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                               rmqconsole
f0fdab3c84f3   apache/rocketmq:4.9.4           "sh mqnamesrv"           14 seconds ago   Up 13 seconds                 10909/tcp, 0.0.0.0:9876->9876/tcp, :::9876->9876/tcp, 10911-10912/tcp   rmqnamesrv
```

```bash
#需要修改权限，不然rmqbroker启动失败，异常code为253
chown -R 777 /data0/rocketmq-docker
#或者
chown -R 3000:3000 /data0/rocketmq-docker
```

4、再次启动服务就能成功了

```bash
docker-compose up -d
```

```bash
root># docker ps -a
CONTAINER ID   IMAGE                           COMMAND                  CREATED         STATUS          PORTS                                                                                                               NAMES
d71eec72d6f9   apache/rocketmq:4.9.4           "sh mqbroker -c /etc…"   2 minutes ago   Up 43 seconds   0.0.0.0:10909->10909/tcp, :::10909->10909/tcp, 9876/tcp, 10912/tcp, 0.0.0.0:10911->10911/tcp, :::10911->10911/tcp   rmqbroker
b89d017b8363   styletang/rocketmq-console-ng   "sh -c 'java $JAVA_O…"   2 minutes ago   Up 2 minutes    0.0.0.0:8080->8080/tcp, :::8080->8080/tcp                                                                           rmqconsole
f0fdab3c84f3   apache/rocketmq:4.9.4           "sh mqnamesrv"           2 minutes ago   Up 2 minutes    10909/tcp, 0.0.0.0:9876->9876/tcp, :::9876->9876/tcp, 10911-10912/tcp       
```

# 二、使用官方dashboard

https://github.com/apache/rocketmq-dashboard

注意使用官方的dashboard，默认不会展示系统的topic，需要在Topic菜单栏下方勾选SYSTEM系统Topic

```bash
cd /data0/rocketmq-docker
docker-compose -f docker-compose-dashboard.yml up -d
chown -R 3000:3000 /data0/rocketmq-docker
docker-compose -f docker-compose-dashboard.yml up -d
```

基于官网仓库 https://github.com/apache/rocketmq-docker 同步构建多版本支持 

# 参考资料：

https://www.pudn.com/news/62a9d0c8dfc5ee19686f780c.html  Docker 安装 RocketMQ-4.9.3：DLedger多副本集群
