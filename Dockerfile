FROM openjdk:8-jre-slim as builder
WORKDIR /opt
ENV HADOOP_VERSION=3.3.4
ENV METASTORE_VERSION=3.1.3
ENV PSQL_CONN_VERSION=42.6.0
ENV LOG4J_WEB_VERSION=2.20.0
ENV RM_HADOOP_LOG4J_VERSION=2.0.7
ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin
RUN apt update && \
    apt install -y curl

# add `hadoop`
RUN curl -L https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - 

# add `hive-standalone-metastore`
RUN curl -L https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf - && \
    # add the `hive-metastore` jar
    curl -L https://repo1.maven.org/maven2/org/apache/hive/hive-metastore/${METASTORE_VERSION}/hive-metastore-${METASTORE_VERSION}.jar -o hive-metastore-${METASTORE_VERSION}.jar && \
    cp hive-metastore-${METASTORE_VERSION}.jar ${HIVE_HOME}/lib/ && \
    rm hive-metastore-${METASTORE_VERSION}.jar && \
    # add the postgresql jdbc driver
    curl -L https://jdbc.postgresql.org/download/postgresql-${PSQL_CONN_VERSION}.jar -o postgresql-${PSQL_CONN_VERSION}.jar && \
    cp postgresql-${PSQL_CONN_VERSION}.jar ${HIVE_HOME}/lib/ && \
    rm  postgresql-${PSQL_CONN_VERSION}.jar && \
    # add the `log4j-web` jar to support web servlet containers
    curl -L https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-web/${LOG4J_WEB_VERSION}/log4j-web-${LOG4J_WEB_VERSION}.jar -o log4j-web-${LOG4J_WEB_VERSION}.jar && \
    cp log4j-web-${LOG4J_WEB_VERSION}.jar ${HIVE_HOME}/lib/ && \
    rm log4j-web-${LOG4J_WEB_VERSION}.jar

FROM openjdk:8-jre-slim as runner
WORKDIR /opt
ENV HADOOP_VERSION=3.3.4
ENV METASTORE_VERSION=3.1.3
ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin
COPY --from=builder ${HIVE_HOME} ${HIVE_HOME}
COPY --from=builder ${HADOOP_HOME} ${HADOOP_HOME}
COPY /conf/metastore-site.postgres.xml ${HIVE_HOME}/conf/metastore-site.xml
RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME}
USER hive
EXPOSE 9083
