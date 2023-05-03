#!/bin/bash

export HADOOP_VERSION=3.3.4
export METASTORE_VERSION=3.1.3
export AWS_SDK_VERSION=1.12.262

export JAVA_HOME=/usr/local/openjdk-8
export HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar
export HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin

${HIVE_HOME}/bin/start-metastore
