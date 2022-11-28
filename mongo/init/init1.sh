#!/usr/bin/env bash
echo "Creating mongo users..."

mongo admin --host localhost -u root -p 123456 --eval "db.createUser({user: 'admin', pwd: 'AdminPassWord', roles: [{role: 'userAdminAnyDatabase', db: 'admin'}]});"

mongo admin -u root -p 123456 << EOF
use zonedb
db.createUser({user: 'zone', pwd: 'zonePass', roles:[{role:'readWrite',db:'zonedb'}]})
db.createCollection("logs", { autoIndexId : true })
EOF

echo "Mongo users create..."