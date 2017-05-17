FROM java:openjdk-8-jre-alpine 

ADD cache/* /opt/

RUN chown -R root:root /opt/* && \
    apk update && \
    apk upgrade && \
    apk add bash && \
    rm -rf /var/cache/apk/*
