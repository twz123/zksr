#!/usr/bin/env sh

# Ensure Kafka is up
KAFKA_OK=0
for i in $(seq 1 30); do
    [ -z "$( "$KAFKA_HOME/bin/kafka-topics.sh" --zookeeper localhost:2181 --list | head -n1 )" ] && {
        KAFKA_OK=1
        break
    }

    sleep 0.1
done
[ $KAFKA_OK -eq 1 ] || exit 1


# Run schema registry
cd $SCHEMA_REGISTRY_HOME && \
exec java -cp "$( ls -1 libs/kafka-schema-registry-[0-9]*.jar ):$( cat etc/classpath )" \
    -Dlog4j.configuration=file:/etc/zksr/schema-registry-log4j.properties \
    io.confluent.kafka.schemaregistry.rest.SchemaRegistryMain \
    etc/schema-registry.properties
