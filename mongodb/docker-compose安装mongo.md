# docker-compose安装mongo并初始化

# 一、创建目录

```bash
mkdir -p /data0/mongo/{data,conf,init}
```

# 二、创建初始化用户脚本

```bash
[root@mongo]# cat /root/tools/mongo/init/init.sh
#!/usr/bin/env bash
echo "Creating mongo users..."

mongo admin --host localhost -u root -p 123456 --eval "db.createUser({user:'admin',pwd:'123456',roles:[{role:'userAdminAnyDatabase',db:'admin'},{role:'readWrite',db:'test'}]});"

mongo admin -u root -p 123456 << EOF
use test
db.createCollection("logs", { autoIndexId : true })
EOF
echo "Mongo users created."
```

# 三、docker-compose配置文件

```bash
cat <<'EOF'>docker-compose.yml 
version: '3'
services:
  mongo:
    image: mongo:4.4.6
    container_name: mongo
    hostname: mongo
    restart: always
    networks:
      - db
    ports:
      - "27017:27017"
    environment:
      TZ: Asia/Shanghai
      MONGO_INITDB_DATABASE: test
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: 123456
    volumes:
      - /etc/localtime:/etc/localtime
      - /data0/mongo/data:/data/db
      - /data0/mongo/conf:/data/configdb
      - /data0/mongo/init/:/docker-entrypoint-initdb.d/
    command: mongod

  mongo-express:
    image: mongo-express
    container_name: mongo-express
    restart: always
    links:
      - mongo:mongo
    depends_on:
      - mongo
    networks:
      - db
    ports:
      - "27018:8081"
    environment:
      ME_CONFIG_OPTIONS_EDITORTHEME: 3024-night
      ME_CONFIG_MONGODB_SERVER: mongo
      ME_CONFIG_MONGODB_ADMINUSERNAME: root
      ME_CONFIG_MONGODB_ADMINPASSWORD: 123456
      ME_CONFIG_BASICAUTH_USERNAME: root
      ME_CONFIG_BASICAUTH_PASSWORD: 123456

networks:
  db:
    driver: bridge
EOF
```

# 四、启动服务

```bash
[root@mongo]# docker-compose up -d
```

# 五、注意事项

初始化脚本只有再data数据目录为空时会执行，若未执行初始化脚本，可删除目录重新创建后执行

# 参考资料：

https://www.cnblogs.com/inclme/p/15829489.html  docker-compose安装mongo