# 一、创建目录

```bash
mkdir -p /data0/mongo/{data,conf,init}
```

# 二、创建初始化用户脚本

表示MongoDB的初始root用户的密码为`123456`，然后创建一个`admin`用户，密码为`admin123`，`admin`这个DB的权限`userAdminAnyDatabase`是权限，然后还创建一个`docker`的DB，权限为`readWrite`

```bash
[root@mongo]# cat /data0/mongo/init/init.sh
#!/usr/bin/env bash
echo "Creating mongo users..."

mongo admin --host localhost -u root -p 123456 --eval "db.createUser({user:'admin',pwd:'admin123',roles:[{role:'userAdminAnyDatabase',db:'admin'},{role:'readWrite',db:'docker'}]});"

mongo admin -u root -p 123456 << EOF
use docker
db.createCollection("logs", { autoIndexId : true })
EOF

echo "Mongo users created."
```

# 三、docker-compose配置文件

1、不带认证方式

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
      MONGO_INITDB_DATABASE: docker
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: 123456
    volumes:
      - /etc/localtime:/etc/localtime:ro #设置容器时区与宿主机保持一致
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
      ME_CONFIG_MONGODB_ADMINUSERNAME: root    #MongoDB admin username
      ME_CONFIG_MONGODB_ADMINPASSWORD: 123456  #MongoDB admin password
      ME_CONFIG_BASICAUTH_USERNAME: root       #mongo-express web username
      ME_CONFIG_BASICAUTH_PASSWORD: 123456     #mongo-express web password

networks:
  db:
    driver: bridge
EOF
```

2、带认证方式

方式二、初始化`/data0/mongo/init/setup.js`

```bash
cat <<'EOF'>/data0/mongo/init/setup.js
db = db.getSiblingDB('docker'); // 创建一个名为"docker"的DB

// 创建一个名为"admin"的用户，设置密码和权限
db.createUser(
    {
        user: "admin",
        pwd: "admin123",
        roles: [
            { role: "dbOwner", db: "docker"}
        ]
    }
);

db.createCollection("test1");  // 在"docker"中创建一个名为"test1"的Collection
EOF
```

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
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: 123456
    volumes:
      - /etc/localtime:/etc/localtime:ro #设置容器时区与宿主机保持一致
      - /data0/mongo/data:/data/db
      - /data0/mongo/init/:/docker-entrypoint-initdb.d/
    command: --wiredTigerCacheSizeGB 4 --auth # 限制内存大小, 需要认证

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
      ME_CONFIG_MONGODB_ADMINUSERNAME: root    #MongoDB admin username
      ME_CONFIG_MONGODB_ADMINPASSWORD: 123456  #MongoDB admin password
      ME_CONFIG_BASICAUTH_USERNAME: root       #mongo-express web username
      ME_CONFIG_BASICAUTH_PASSWORD: 123456     #mongo-express web password

networks:
  db:
    driver: bridge
EOF
```

# 四、启动服务

```bash
docker-compose up -d
```

# 五、注意事项

初始化脚本只有再data数据目录为空时会执行，若未执行初始化脚本，可删除目录重新创建后执行


# 参考资料：

https://www.cnblogs.com/inclme/p/15829489.html  docker-compose安装mongo

https://www.jianshu.com/p/e48f0ec7a322  docker-compose 安装mongo

https://www.cnblogs.com/mxnote/articles/16899560.html  使用Docker-Compose安装MongoDB