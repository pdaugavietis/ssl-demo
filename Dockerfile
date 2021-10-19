FROM alpine

RUN apk add bash openssl

WORKDIR /ssl
VOLUME /ssl
ENTRYPOINT [ "/bin/bash" ]
