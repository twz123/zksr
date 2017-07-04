#!/usr/bin/env sh

set -e

check_sha256() {
    echo "${1} *${2}" | shasum -a 256 --check - 1>/dev/null 2>/dev/null
}

download() {
    if ! check_sha256 "$2" "$BUILD_DIR/cache/$1"; then
        wget -O "$BUILD_DIR/cache/$1" "$3"
        check_sha256 "$2" "$BUILD_DIR/cache/$1" || {
            echo "Failed to download $1!" 1>&2
            exit 1
        }
    fi
}

apache_download() {
    download "$2" "$3" "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=$1/$2"
}

package_schema_registry() {
    mkdir -p -- "$BUILD_DIR/cache/.m2"
    docker run -i -v "$BUILD_DIR/cache:/build-cache" -u $( id -u ):$( id -g ) \
        -e MAVEN_CONFIG=/build-cache/.m2 \
        -e MAVEN_OPTS=-Duser.home=/build-cache \
        maven:3.5.0-jdk-8-alpine \
        sh -s -- 3.2.1 /build-cache < "$BUILD_DIR/package-schema-registry.sh"
}

### main

BUILD_DIR="$( cd -- "$( dirname "$0" )" ; pwd -P )"

[ "$0" -ef "$BUILD_DIR/build.sh" ] || {
    echo "Failed to determine build directory!" 1>&2
    exit 1
}

mkdir -p -- "$BUILD_DIR/cache"

apache_download zookeeper/zookeeper-3.4.9 zookeeper-3.4.9.tar.gz e7f340412a61c7934b5143faef8d13529b29242ebfba2eba48169f4a8392f535
apache_download kafka/0.10.1.0 kafka_2.11-0.10.1.0.tgz 6d9532ae65c9c8126241e7b928b118aaa3a694dab08069471f0e61f4f0329390
[ -f "$BUILD_DIR/cache/schema-registry-3.2.1.tar" ] || package_schema_registry

docker build "$BUILD_DIR" -t zksr
