#!/usr/bin/env sh

# Ensure Zookeeper is up
ZK_UP=0
for i in $(seq 1 30); do
    "$ZOOKEEPER_HOME/bin/zkServer.sh" status && {
        ZK_UP=1
        break
    }

    sleep 0.1
done
[ $ZK_UP -eq 1 ] || exit 1

STARTUP_OPTS="$KAFKA_HOME/config/server.properties"
STARTUP_OPTS="$STARTUP_OPTS --override advertised.host.name=${KAFKA_ADVERTISED_HOST:-localhost}"
STARTUP_OPTS="$STARTUP_OPTS --override advertised.port=${KAFKA_ADVERTISED_PORT:-9092}"

# Run Kafka
export KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:/etc/zksr/kafka-log4j.properties"
exec $KAFKA_HOME/bin/kafka-server-start.sh $STARTUP_OPTS
