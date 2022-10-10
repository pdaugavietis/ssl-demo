# SSL in Anger - Demo Code

## DEMO 1 - Building the moving parts

```bash
docker run -it -v $(pwd)/demo-1-artifacts/:/ssl alpine-ssl

# from inside container:
openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -subj "/C=CA/ST=Ontario/L=Toronto/O=SDLC Solutions/OU=DevOps PS/CN=root" -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt
openssl x509 -in rootCA.crt -text

openssl genrsa -out localhost.key 2048
openssl pkey -in localhost.key -text

openssl req -new -sha256 -key localhost.key -subj "/C=CA/ST=Ontario/L=Toronto/O=SDLC Solutions/OU=DevOps PS/CN=localhost" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:dev.localhost.local")) -out localhost.csr
openssl req -in localhost.csr -text

openssl x509 -req -extfile <(printf "subjectAltName=DNS:dev.localhost.local") -days 120 -in localhost.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out localhost.crt -sha256
openssl x509 -in localhost.crt -text
```

## DEMO 2 - SSL in Java

```bash
openssl pkcs12 -export -in demo-1-artifacts/localhost.crt -inkey demo-1-artifacts/localhost.key -out demo-2-java-ssl/localhost.p12 -name tomcat -CAfile demo-1-artifacts/rootCA.crt -caname root -chain
```

```xml
...
    <Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
               maxThreads="150" SSLEnabled="true">
        <SSLHostConfig>
            <Certificate certificateKeystoreFile="conf/server.jks"
                         certificateKeystorePassword="changeme"
                         certificateKeyAlias="tomcat"
                         type="RSA" />
        </SSLHostConfig>
    </Connector>
...
```
