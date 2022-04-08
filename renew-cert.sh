#!/bin/bash

# https://www.golinuxcloud.com/renew-expired-root-ca-certificate-openssl/

CERT_NAME=$1
DAYS=${2:-365}

if [[ -f ./$CERT_NAME.crt ]] ; then
    echo "renewing $CERT_NAME.crt for $DAYS days"
    openssl x509 -x509toreq -in $CERT_NAME.crt -signkey $CERT_NAME.key -out $CERT_NAME.csr
    openssl x509 -req -days $DAYS -in $CERT_NAME.csr -signkey $CERT_NAME.key -out $CERT_NAME.crt
else
    echo "Certificate NOT FOUND: $CERT_NAME.crt"
fi
