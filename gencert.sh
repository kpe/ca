#!/bin/bash

DEFAULT_CERT="server"

SUBJ_PREF="/O=FakeCA"
PASSWORD="changeit"

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function gencert() {
		local name="$1"
    local altName=""
    while (("$#")); do
        if [[ -n $altName ]]; then
            altName="${altName},"
        fi
        
        if valid_ip $1 ; then
            altName="${altName}IP:$1"
        else
            altName="${altName}DNS:$1"
        fi
        echo "altName for $1 -> $altName"
        shift
    done
    
    openssl genrsa -out ${name}.key 2048
    if [ $DEFAULT_CERT = "client" ]; then
        echo "Generating CLIENT Certificate for $name"
        openssl req -nodes -new -key ${name}.key -out ${name}.csr -outform PEM  \
                -subj "${SUBJ_PREF}/CN=${name}" -config openssl.conf
	      openssl ca -in ${name}.csr -out ${name}.crt  -batch                     \
                -extensions client_ca_extensions -config openssl.conf
    else
        echo "Generating SERVER Certificate for $name with subjectAltName: $altName"
        openssl req -nodes -new -key ${name}.key -out ${name}.csr -outform PEM   \
                -subj "${SUBJ_PREF}/CN=${name}" -reqexts SAN                     \
                -config <(cat openssl.conf <(printf "[SAN]\nsubjectAltName=${altName}\n")) 
	      openssl ca -in ${name}.csr -out ${name}.crt -batch                       \
                -extensions server_ca_extensions -extensions SAN                 \
                -config <(cat openssl.conf <(printf "[SAN]\nsubjectAltName=${altName}\n"))
    fi
    # convert to PKCS12 - with and without password
    openssl pkcs12 -export -out ${name}.nopass.p12 -in ${name}.crt -inkey ${name}.key \
            -chain -CAfile ca.crt -passout pass:
    openssl pkcs12 -export -out ${name}.p12 -in ${name}.crt -inkey ${name}.key        \
            -chain -CAfile ca.crt -passout pass:"${PASSWORD}"

    # generate java JKS
    openssl pkcs12 -export -in <(cat ${name}.key ${name}.crt)                    \
            -chain -CAfile ca.crt -out ${name}.pkcs12 -name "${name}"            \
            -passout pass:"${PASSWORD}"
    keytool -importkeystore -srckeystore ${name}.pkcs12 -srcstoretype pkcs12     \
            -srcalias ${name} -srcstorepass "${PASSWORD}"                        \
            -destkeystore ${name}.jks -deststoretype jks                         \
            -deststorepass "${PASSWORD}" -destalias ${name}
   
    cat ${name}.crt ca.crt > ${name}-and-ca.crt
}


case "$0" in
    "./gen-server-cert.sh")
        DEFAULT_CERT="server"
        ;;
    "./gen-client-cert.sh")
        DEFAULT_CERT="client"
        ;;
    *)
        echo "None of the ./gen-server-cert.sh ./gen-client-cert.sh scripts used"
        DEFAULT_CERT="server"
        ;;
esac

echo "cert: $DEFAULT_CERT"

case $# in
    0)
        echo "No hostname specified, using default hostname.fakeca.local"
        gencert hostname.fakeca.local
        ;;
    *)
        gencert $@
        ;;
esac
    

