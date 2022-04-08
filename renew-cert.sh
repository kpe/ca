#!/bin/bash

# https://www.golinuxcloud.com/renew-expired-root-ca-certificate-openssl/

CERT_NAME=$1
DAYS=${2:-365}

if [[ "$CERT_NAME" == "ca" ]] ; then
    echo "renewing root CA for $DAYS days"
    openssl x509 -x509toreq -in ca.crt -signkey ca.key -out ca.csr
    openssl x509 -req -days $DAYS -in ca.csr -signkey ca.key -out ca.crt
elif [[ -f ./$CERT_NAME.crt ]] ; then
    echo "renewing $CERT_NAME.crt for $DAYS days"
    openssl x509 -x509toreq -in $CERT_NAME.crt -signkey $CERT_NAME.key -out $CERT_NAME.csr
    openssl ca -days $DAYS -in $CERT_NAME.csr -in $CERT_NAME.csr -out $CERT_NAME.crt -config openssl.conf -batch
else
    echo "Certificate NOT FOUND: $CERT_NAME.crt"
fi
