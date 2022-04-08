#!/bin/bash

# https://www.golinuxcloud.com/renew-expired-root-ca-certificate-openssl/

CERT_NAME=$1
DAYS=${2:-365}

if [[ "$CERT_NAME" -eq "ca" ]] ; then
    openssl x509 -x509toreq -in ca.crt -signkey ca.key -out ca.csr
    openssl x509 -req -days $DAYS -in ca.csr -signkey ca.key -out ca.crt
elif [[ -f ./$CERT_NAME.crt ]] ; then
    echo "renewing $CERT_NAME.crt for $DAYS days"
    openssl x509 -x509toreq -in $CERT_NAME.crt -key $CERT_NAME.key -out $CERT_NAME.csr
    openssl x509 -req -days $DAYS -in $CERT_NAME.csr -key ca.key -out $CERT_NAME.crt
else
    echo "Certificate NOT FOUND: $CERT_NAME.crt"
fi
