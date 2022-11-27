# 一、创建目录

```bash
mkdir -p /data0/mongo/{data,conf,init}
```

# 二、创建初始化用户脚本

方式一
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

    表示MongoDB的初始root用户的密码为`123456`，然后创建一个`admin`用户，密码为`admin123`，`admin`这个DB的权限`userAdminAnyDatabase`是权限，然后还创建一个`docker`的DB，权限为`readWrite`

方式二

```bash
#!/usr/bin/env bash
echo "Creating mongo users..."

mongo admin --host localhost -u root -p 123456 --eval "db.createUser({user: 'admin', pwd: 'AdminPassWord', roles: [{role: 'userAdminAnyDatabase', db: 'admin'}]});"

mongo admin -u root -p 123456 << EOF
use zonedb
db.createUser({user: 'zone', pwd: 'zonePass', roles:[{role:'readWrite',db:'zonedb'}]})
EOF

echo "Mongo users create..."
```

那么在这里解释一下创建的过程：

1.  创建一个 admin 数据库，其参数为：
    
    -   用户：admin
        
    -   密码：AdminPassWord
        
    -   role：userAdminAnyDatabase
        
2.  创建一个 zonedb 数据库，其参数为：
    
    -   用户：zone
        
    -   密码：zonePass
        
    -   role：readWrite

https://juejin.cn/post/6844903653841567758    基于 Docker 中的 MongoDB 授权使用

# 三、docker-compose配置文件

environment 选项分别表示：（需要说明的是：这是官方支持的）

1.  MONGO_INITDB_ROOT_USERNAME 表示 admin 数据库用户名
2.  MONGO_INITDB_ROOT_PASSWORD 表示 admin 数据库密码

```bash
cat <<'EOF'>docker-compose.yml
version: '3.5'

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
      MONGO_INITDB_DATABASE: docker #指定初始数据库
      #在这里输入 MongoDB 的 root 用户与密码，如果使用了此项，则不需要 --auth 参数
      MONGO_INITDB_ROOT_USERNAME: root   #表示 admin 数据库用户名
      MONGO_INITDB_ROOT_PASSWORD: 123456 #表示 admin 数据库密码
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

2、认证方式二

方式二、初始化  `/data0/mongo/init/setup.js`

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
version: '3.5'

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

https://blog.csdn.net/u014044812/article/details/78666297  Docker系列教程02-MongoDB默认开启鉴权

```bash
当你加入环境变量MONGO_INITDB_ROOT_USERNAME和MONGO_INITDB_ROOT_PASSWORD（缺一不可）后mongodb自动开启权限验证，这在mongo官方镜像文件的docker-entrypoint.sh脚本中可看到  https://github.com/docker-library/mongo/blob/00a8519463e776e797c227681a595986d8f9dbe1/3.0/docker-entrypoint.sh
```

https://juejin.cn/post/6844903653841567758  # 基于 Docker 中的 MongoDB 授权使用