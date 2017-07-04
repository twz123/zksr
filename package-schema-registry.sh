#!/usr/bin/env sh

set -e

[ $# -eq 2 ] || {
    echo "2 arguments required, $# given!" 1>&2
    exit 1
}

SCHEMA_REGISTRY_VERSION="$1"
OUTPUT_FOLDER="$2"
M2_REPO="https://packages.confluent.io/maven/io/confluent"

[ -d "$OUTPUT_FOLDER" ] || {
    echo "Not a directory: $OUTPUT_FOLDER" 1>&2
    exit 1
}

OUTPUT_FOLDER="$( cd -- "$OUTPUT_FOLDER"; pwd -P )"

BUILD_DIR="$( mktemp -d )" || {
    echo "Failed to create temporary build directory!" 1>&2
    exit 1
}

trap "rm -rf -- '$BUILD_DIR'" INT EXIT

mkdir -p -- "$BUILD_DIR/etc"
cd -- "$BUILD_DIR"
wget -q $M2_REPO/kafka-schema-registry-parent/$SCHEMA_REGISTRY_VERSION/kafka-schema-registry-parent-$SCHEMA_REGISTRY_VERSION.pom
wget -q $M2_REPO/kafka-schema-registry/$SCHEMA_REGISTRY_VERSION/kafka-schema-registry-$SCHEMA_REGISTRY_VERSION.pom
mvn -B install:install-file \
    -Dfile=kafka-schema-registry-parent-$SCHEMA_REGISTRY_VERSION.pom \
    -DpomFile=kafka-schema-registry-parent-$SCHEMA_REGISTRY_VERSION.pom
mvn -B -f kafka-schema-registry-$SCHEMA_REGISTRY_VERSION.pom dependency:copy-dependencies dependency:build-classpath \
    -DincludeScope=runtime \
    -DoutputDirectory=libs \
    -Dmdep.prefix=libs \
    -Dmdep.outputFile=etc/classpath

curl -o "$BUILD_DIR/etc/schema-registry.properties" \
    https://raw.githubusercontent.com/confluentinc/schema-registry/v$SCHEMA_REGISTRY_VERSION/config/schema-registry.properties

cd -- "$BUILD_DIR/libs"
wget -q $M2_REPO/kafka-schema-registry/$SCHEMA_REGISTRY_VERSION/kafka-schema-registry-$SCHEMA_REGISTRY_VERSION.jar

mkdir -- "$BUILD_DIR/schema-registry-$SCHEMA_REGISTRY_VERSION"
mv -- "$BUILD_DIR/libs" "$BUILD_DIR/etc" "$BUILD_DIR/schema-registry-$SCHEMA_REGISTRY_VERSION"
tar cf "$OUTPUT_FOLDER/schema-registry-$SCHEMA_REGISTRY_VERSION.tar" -C "$BUILD_DIR/" schema-registry-$SCHEMA_REGISTRY_VERSION
