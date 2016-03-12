# hadoop-docker
Hadoop Cluster by Docker image

## Challenge

- Build Hadoop Cluster on Docker

## Methods

- Use [Apache Hadoop Docker image](https://hub.docker.com/r/sequenceiq/hadoop-docker/) from [SequenceIQ](http://sequenceiq.com/)

## Preconditions

|Target|Version|
|:--|:--|
|Apache Hadoop Docker image|2.7.1|

|Base|Version|
|:--|:--|
|[Boot2docker](http://boot2docker.io/)|1.10.3|
|[Docker Toolbox](https://www.docker.com/products/docker-toolbox) |1.10.3|
|[VartualBox](https://www.virtualbox.org/)|5.0|
|[Cygwin](https://www.cygwin.com/)|2.4.1|
|Windows|8.1|

## Steps

### 1. Build a master node ( ResourceManager + NameNode )

- Run Apache Hadoop Docker image for the master node

```bash
$ docker run -itd -p 8088:8088 -p 9000:9000 -p 19888:19888 -p 50070:50070 -h hadoop-00 --name hadoop-00 sequenceiq/hadoop-docker /bin/bash
$ docker exec hadoop-00 service sshd start
```

- Configure Hadoop on the master node

```bash
$ docker cp core-site.xml hadoop-00:/usr/local/hadoop/etc/hadoop
$ docker cp yarn-site.xml hadoop-00:/usr/local/hadoop/etc/hadoop
$ docker cp hdfs-site.xml hadoop-00:/usr/local/hadoop/etc/hadoop
$ docker cp mapred-site.xml hadoop-00:/usr/local/hadoop/etc/hadoop
$ docker cp slaves hadoop-00:/usr/local/hadoop/etc/hadoop
```

- Remove data for HDFS on the master node

```bash
$ docker exec hadoop-00 rm -rf /tmp/hadoop-root/dfs/data/current
```

- Run daemons on the master node

```bash
$ docker exec hadoop-00 /usr/local/hadoop/sbin/yarn-daemon.sh start resourcemanager
$ docker exec hadoop-00 /usr/local/hadoop/sbin/hadoop-daemon.sh start namenode
$ docker exec hadoop-00 /usr/local/hadoop/sbin/mr-jobhistory-daemon.sh start historyserver
```

### 2. Build a slave node ( NodeManager + DataNode )

- Run Apache Hadoop Docker image for the slave node

```bash
$ docker run -itd -h hadoop-01 --name hadoop-01 sequenceiq/hadoop-docker /bin/bash
$ docker exec hadoop-01 service sshd start
```

- Add the slave node to `/etc/hosts` on the master node

```bash
$ docker exec hadoop-00 sh -c "echo $(docker inspect --format {{.NetworkSettings.IPAddress}} hadoop-01) hadoop-01 >> /etc/hosts"
```

- Add the slave node to `/usr/local/hadoop/etc/hadoop/slaves` on the master node

```bash
$ docker exec hadoop-00 sh -c "echo hadoop-01 >> /usr/local/hadoop/etc/hadoop/slaves"
```

- Synchronize `/etc/hosts` on the slave node to one on the master node.

```bash
$ docker exec hadoop-00 scp /etc/hosts hadoop-01:/etc/hosts
```

- Synchronize Hadoop configurations on the slave node to ones on the master node.

```bash
$ docker exec hadoop-00 rsync -av /usr/local/hadoop/etc/hadoop/ hadoop-01:/usr/local/hadoop/etc/hadoop/
```

- Run daemons on the slave node

```bash
$ docker exec hadoop-01 /usr/local/hadoop/sbin/yarn-daemon.sh start nodemanager
$ docker exec hadoop-01 /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode
```

### 3. Build a client

- Run Apache Hadoop Docker image for the client

```bash
$ docker run -itd -h hadoop-cli --name hadoop-cli sequenceiq/hadoop-docker /bin/bash
```

- Add the master node to `/etc/hosts` on the client

```bash
$ docker exec hadoop-cli sh -c "echo $(docker inspect --format {{.NetworkSettings.IPAddress}} hadoop-00) hadoop-00 >> /etc/hosts"
```

- Synchronize Hadoop configurations on the client to ones on the master node.

```bash
$ docker exec hadoop-cli rsync -av hadoop-00:/usr/local/hadoop/etc/hadoop/ /usr/local/hadoop/etc/hadoop/
```

### 4. Test

- Run a example in Hadoop from the client

```bash
$ docker exec hadoop-cli /usr/local/hadoop/bin/hdfs dfs -rm -r output
$ docker exec hadoop-cli /usr/local/hadoop/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.0.jar grep input output 'dfs[a-z.]+'
```

- Check the output

```bash
$ docker exec hadoop-cli /usr/local/hadoop/bin/hdfs dfs -cat output/*
6       dfs.audit.logger
4       dfs.class
3       dfs.server.namenode.
2       dfs.period
2       dfs.audit.log.maxfilesize
2       dfs.audit.log.maxbackupindex
1       dfsmetrics.log
1       dfsadmin
1       dfs.servers
1       dfs.replication
1       dfs.file
```

### A. Add a slave node ( NodeManager + DataNode )

- Run Apache Hadoop Docker image for the slave node

```bash
$ docker run -itd -h hadoop-02 --name hadoop-02 sequenceiq/hadoop-docker /bin/bash
$ docker exec hadoop-02 service sshd start
``````

- Add the slave node to `/etc/hosts` on the master node

```bash
$ docker exec hadoop-00 sh -c "echo $(docker inspect --format {{.NetworkSettings.IPAddress}} hadoop-02) hadoop-02 >> /etc/hosts"
```

- Add the slave node to `/usr/local/hadoop/etc/hadoop/slaves` on the master node

```bash
$ docker exec hadoop-00 sh -c "echo hadoop-02 >> /usr/local/hadoop/etc/hadoop/slaves"
```

- Synchronize `/etc/hosts` on slave nodes to one on the master node.

```bash
$ docker exec hadoop-00 scp /etc/hosts hadoop-01:/etc/hosts
$ docker exec hadoop-00 scp /etc/hosts hadoop-02:/etc/hosts
```

- Synchronize Hadoop configurations on slave nodes to ones on the master node.

```bash
$ docker exec hadoop-00 rsync -av /usr/local/hadoop/etc/hadoop/ hadoop-01:/usr/local/hadoop/etc/hadoop/
$ docker exec hadoop-00 rsync -av /usr/local/hadoop/etc/hadoop/ hadoop-02:/usr/local/hadoop/etc/hadoop/
```

- Remove data for HDFS on the slave node

```bash
$ docker exec hadoop-02 rm -rf /tmp/hadoop-root/dfs/data/current
```

- Run daemons on the slave node

```bash
$ docker exec hadoop-02 /usr/local/hadoop/sbin/yarn-daemon.sh start nodemanager
$ docker exec hadoop-02 /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode
```

## Reference

- [Apache Hadoop YARN](https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html)
- [HDFS Architecture](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html)
- [Hadoop Cluster Setup](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/ClusterSetup.html)
- [Apache Hadoop 2.7.1 Docker image](https://github.com/sequenceiq/hadoop-docker)
- [Apache Yarn 2.7.1 cluster Docker image](https://github.com/lresende/docker-yarn-cluster)

