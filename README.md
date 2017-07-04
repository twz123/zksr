# ZKSR

All-in-one Docker image for [Kafka][kafka-home] and the
[Schema Registry][sr-home] from Confluent Inc.

    Z=Zookeeper
    K=Kafka
    SR=Schema Registry

[kafka-home]: https://kafka.apache.org
[sr-home]: https://github.com/confluentinc/schema-registry

## Images

Images are built by [Travis CI][zksr-travis] and pushed to [Quay][zksr-quay]:

    quay.io/twz123/zksr:$GIT_COMMIT

[zksr-travis]: https://travis-ci.org/twz123/zksr
[zksr-quay]: https://quay.io/repository/twz123/zksr

## Building

    ./build.sh

## Running

    docker run --rm -p 2181:2181 -p 9092:9092 -p 8081:8081 zksr
