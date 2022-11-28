# docker-compose安装mysql:5.7.31

```bash
#安装docker-compose
export Version="v2.13.0"
curl -L "https://github.com/docker/compose/releases/download/${Version}/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

# 一、新建一个启动服务的目录

```bash
mkdir -p /data0/mysql
cd /data0/mysql
```

# 二、新建文件`docker-compose.yml`

注意: 文件名字必需是docker-compose.yml

```yaml
cat <<'EOF'>docker-compose.yaml
version: '3.8'

services:
  mysql:
    container_name: mysql57
    image: mysql:5.7.31
    restart: always
    ports:
      - 3306:3306
    privileged: true
    volumes:
      - $PWD/mysql57/log:/var/log/mysql 
      - $PWD/mysql57/conf/my.cnf:/etc/mysql/my.cnf
      - $PWD/mysql57/data:/var/lib/mysql
    environment:
      MYSQL_USER: 'www'
      MYSQL_PASSWORD: 'www123456'
      MYSQL_DATABASE: 'example'
      MYSQL_ROOT_PASSWORD: "admin123456"
      TZ: "Asia/Shanghai"
    command: [
        '--character-set-server=utf8mb4',
        '--collation-server=utf8mb4_general_ci',
        '--max_connections=5000'
    ]
    networks:
      - myweb

networks:
  myweb:
    driver: bridge
EOF
```

# 三、新建初始化文件`init-mysql.sh`

```bash
#!/bin/bash
mkdir -p $PWD/mysql57/{conf,data,log}  #创建本地文件夹

#新建配置文件
tee $PWD/mysql57/conf/my.cnf<<-'EOF'
[mysqld]
user=mysql
default-storage-engine=INNODB

pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql

# 实现mysql不区分大小（开发需求，建议开启）
lower_case_table_names=1 

# By default we only accept connections from localhost
#bind-address   = 127.0.0.1

# Disabling symbolic-links is recommended to prevent assorted security risks
default-time_zone = '+8:00'

# 更改字符集 如果想Mysql在后续的操作中文不出现乱码,则需要修改配置文件内容
symbolic-links=0
max_allowed_packet=64M
sql_mode ='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'

# 服务端默认字符集
character-set-server=utf8mb4
# 使用服务端字符集
character-set-client-handshake=FALSE
# 连接层默认字符集
collation-server=utf8mb4_unicode_ci
init_connect='SET NAMES utf8mb4'

[client]
# 客户端来源数据的默认字符集
default-character-set=utf8mb4

[mysql]
# 数据库默认字符集
default-character-set=utf8mb4
EOF
```

# 四、实例化目录和配置文件

```bash
chmod +x init-mysql.sh docker-compose.yaml  #加执行权限

./init-mysql.sh

[root@centos7 mysql]# tree ./  #查看目结构
./
├── docker-compose.yaml
├── init-mysql.sh
└── mysql57
    ├── conf
    │   └── my.cnf
    ├── data
    └── log
```

# 五、启动服务

```bash
docker-compose up -d
```

# 六、登陆mysql

```mysql
docker exec -it mysql57 mysql -uroot -padmin123456

mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.31 MySQL Community Server (GPL)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)

mysql>
```

# 七、其它操作

```bash
docker ps -a #查看启动的服务
docker-compose up -d #后台启动服务
docker-compose -h #帮助命令
docker-compose down #停止并删除服务
docker-compose restart #重启服务
docker-compose stop #停止服务
docker-compose start #停止服务
docker-compose logs #停止日志
```

# 参考资料：

https://blog.51cto.com/u_6192297/3299949 docker-compose 安装 mysql:5.7.31
