#! /bin/sh

if [ $# -ne 1 ]; then
    echo 'docker-in.sh requires a minimum of 1 argument.' 1>&2
    echo 'Usage:  build-slave.sh <two-digit>' 1>&2
    exit 1
fi

if [ $(expr length $1) -ne 2 ]; then
    echo 'Argument must be 2-digit number.' 1>&2
    exit 1
fi

if [ $1 = '00' ]; then
    echo 'Argument must be other than 00' 1>&2
    exit 1
fi

if [ $1 = '01' ]; then
    echo 'Argument must be other than 01' 1>&2
    exit 1
fi

NAME=hadoop-$1
LINE=$(docker ps -f name=$NAME | wc -l)

if [ $LINE -ge 2 ]; then
    echo "$NAME exits already." 1>&2
    exit 1
fi

docker run -itd -h $NAME --name $NAME sequenceiq/hadoop-docker /bin/bash
docker exec $NAME service sshd start

docker exec hadoop-00 sh -c "echo $(docker inspect --format {{.NetworkSettings.IPAddress}} $NAME) $NAME >> /etc/hosts"
docker exec hadoop-00 sh -c "echo $NAME >> /usr/local/hadoop/etc/hadoop/slaves"

docker exec hadoop-00 scp /etc/hosts $NAME:/etc/hosts
docker exec hadoop-00 rsync -av /usr/local/hadoop/etc/hadoop/ $NAME:/usr/local/hadoop/etc/hadoop/

docker exec $NAME rm -rf /tmp/hadoop-root/dfs/data/current

docker exec $NAME /usr/local/hadoop/sbin/yarn-daemon.sh start nodemanager
docker exec $NAME /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode
