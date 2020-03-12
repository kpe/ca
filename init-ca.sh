#!/bin/bash

DEFAULT_CA_NAME="FakeCA"


echo "Initializing new FakeCA"
rm -rf certs *.key *.crt *.der *.csr *.p12 *.pkcs12 *.jks serial* index*

mkdir -p certs 
echo 01 > serial
touch index.txt

echo "  generating CA keys"
openssl req -nodes -x509         \
        -config openssl.conf     \
        -newkey rsa -days 3650   \
        -out ca.crt -outform PEM \
        -subj "/CN=${DEFAULT_CA_NAME}/"
openssl x509 -in ca.crt -out ca.der -outform DER
