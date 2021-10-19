#!/bin/sh

OUTPUT_DIR=$1

mkdir -p $OUTPUT_DIR

openssl genrsa -out $OUTPUT_DIR/rootCA.key 4096
openssl req -x509 -new -subj "/C=CA/ST=Ontario/L=Toronto/O=Adaptavist Canada Inc./OU=DevOps PS/CN=root" -nodes -key $OUTPUT_DIR/rootCA.key -sha256 -days 1024 -out $OUTPUT_DIR/rootCA.crt
openssl x509 -in $OUTPUT_DIR/rootCA.crt -text

openssl genrsa -out $OUTPUT_DIR/localhost.key 2048
openssl pkey -in $OUTPUT_DIR/localhost.key -text

openssl req -new -sha256 -key $OUTPUT_DIR/localhost.key -subj "/C=CA/ST=Ontario/L=Toronto/O=Adaptavist Canada Inc./OU=DevOps PS/CN=localhost" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:jira-dev.local")) -out $OUTPUT_DIR/localhost.csr
openssl req -in $OUTPUT_DIR/localhost.csr -text

openssl x509 -req -extfile <(printf "subjectAltName=DNS:jira-dev.local") -days 120 -in $OUTPUT_DIR/localhost.csr -CA $OUTPUT_DIR/rootCA.crt -CAkey $OUTPUT_DIR/rootCA.key -CAcreateserial -out $OUTPUT_DIR/localhost.crt -sha256
openssl x509 -in $OUTPUT_DIR/localhost.crt -text

