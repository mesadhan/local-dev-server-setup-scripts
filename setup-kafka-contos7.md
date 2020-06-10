


wget http://www-us.apache.org/dist/kafka/2.4.0/kafka_2.13-2.4.0.tgz
tar xzf kafka_2.13-2.4.0.tgz
mv kafka_2.13-2.4.0 /usr/local/kafka
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.6.10-1.el7_7.x86_64/bin/java




vi /etc/systemd/system/zookeeper.service

```
[Unit]
Description=Apache Zookeeper server
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
ExecStart=/usr/local/kafka/bin/zookeeper-server-start.sh /usr/local/kafka/config/zookeeper.properties
ExecStop=/usr/local/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
```

vi /etc/systemd/system/kafka.service

```
[Unit]
Description=Apache Kafka Server
Documentation=http://kafka.apache.org/documentation.html
Requires=zookeeper.service

[Service]
Type=simple
Environment="JAVA_HOME=/usr/lib/jvm/jre-11-openjdk"
ExecStart=/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties
ExecStop=/usr/local/kafka/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target

```

Service update

    systemctl daemon-reload
    sudo systemctl start zookeeper
    sudo systemctl status zookeeper
    sudo systemctl enable zookeeper


Step – Creating Topics in Apache Kafka

    cd /usr/local/kafka
    bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic testTopic

    Created topic testTopic.

See created topic

    bin/kafka-topics.sh --list --zookeeper localhost:2181

    testTopic
    KafkaonCentOS8
    TutorialKafkaInstallCentOS8

Step – Apache Kafka Producer and Consumer

Let’s run the producer and then type a few messages into the console to send to the server.

    bin/kafka-console-producer.sh --broker-list localhost:9092 --topic testTopic

    >Welcome to kafka
    >This is my first topic
    >


Read data from the Kafka cluster and display messages to the standard output.

    bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic testTopic --from-beginning

    Welcome to kafka
    This is my first topic


References:

    https://linuxize.com/post/install-java-on-centos-7/
    https://tecadmin.net/install-apache-kafka-centos-8/