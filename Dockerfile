FROM java:openjdk-8-jre-alpine 

ENV ZOOKEEPER_HOME=/opt/zookeeper-3.4.9 \
    KAFKA_HOME=/opt/kafka_2.11-0.10.1.0 \
    SCHEMA_REGISTRY_HOME=/opt/schema-registry-3.2.1

RUN apk update && apk upgrade && apk add bash supervisor && rm -rf /var/cache/apk/*

ADD cache/* /opt/
COPY files/ /
RUN chown -R root:root /opt/* && \
    mv "$ZOOKEEPER_HOME/conf/zoo_sample.cfg" "$ZOOKEEPER_HOME/conf/zoo.cfg"

# 2181 is zookeeper, 9092 is kafka, 8081 is schema-registry
EXPOSE 2181 9092 8081

USER nobody
CMD ["/usr/bin/supervisord", "-c", "/etc/zksr/supervisor.conf"]
