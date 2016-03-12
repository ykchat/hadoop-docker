#! /bin/sh

docker run -itd -p 8032:8032 -p 8088:8088 -p 9000:9000 -p 19888:19888 -p 50070:50070 -h hadoop-00 --name hadoop-00 sequenceiq/hadoop-docker /bin/bash
docker exec hadoop-00 service sshd start

docker cp core-site.xml hadoop-00:/usr/local/hadoop/etc/hadoop
docker cp yarn-site.xml hadoop-00:/usr/local/hadoop/etc/hadoop
docker cp hdfs-site.xml hadoop-00:/usr/local/hadoop/etc/hadoop
docker cp mapred-site.xml hadoop-00:/usr/local/hadoop/etc/hadoop
docker cp slaves hadoop-00:/usr/local/hadoop/etc/hadoop

docker exec hadoop-00 rm -rf /tmp/hadoop-root/dfs/data/current

docker exec hadoop-00 /usr/local/hadoop/sbin/yarn-daemon.sh start resourcemanager
docker exec hadoop-00 /usr/local/hadoop/sbin/hadoop-daemon.sh start namenode
docker exec hadoop-00 sh -c "USER=root /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver"
