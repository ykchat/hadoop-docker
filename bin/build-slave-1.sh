#! /bin/sh

NAME=hadoop-01
LINE=$(docker ps -f name=$NAME | wc -l)

if [ $LINE -ge 2 ]; then
    echo "$NAME exits already." 1>&2
    exit 1
fi

docker run -itd -p 50010:50010 -h $NAME --name $NAME sequenceiq/hadoop-docker /bin/bash
docker exec $NAME service sshd start

docker exec hadoop-00 sh -c "echo $(docker inspect --format {{.NetworkSettings.IPAddress}} $NAME) $NAME >> /etc/hosts"
docker exec hadoop-00 sh -c "echo $NAME >> /usr/local/hadoop/etc/hadoop/slaves"

docker exec hadoop-00 scp /etc/hosts $NAME:/etc/hosts
docker exec hadoop-00 rsync -av /usr/local/hadoop/etc/hadoop/ $NAME:/usr/local/hadoop/etc/hadoop/

docker exec $NAME /usr/local/hadoop/sbin/yarn-daemon.sh start nodemanager
docker exec $NAME /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode
