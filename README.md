
# Walkthrough

This repo contains bash scripts for issuing client and server certificates used for TESTING (not PRODUCTION). 

USE at your OWN RISK!

1. to create a new CA (and wipe any previous one)


    ./init-ca.sh
     
    
2. to issue a server certificate providing multiple FQDNs and IPs (`subjectAlternativeNames`)


    ./gen-server-cert.sh myservername myservername.local 127.0.0.1

3. to issue a client certificate


    ./gen-client-cert.sh kpe

Each time you issue a certificate, the following files gets written locally, i.e. calling:


    ./gen-server-cert.sh localhost 127.0.0.1
    
would result in (you would usually only need either the `.p12` or the `.key`/`.crt` files):

 - `localhost.key`  - private key
 - `localhost.crt`        - signed certificate
 - `localhost-and-ca.crt` - signed certificate and root CA chain
 - `localhost.p12`        - PKCS12 key store with private key and certificate chain
 - `localhost.nopass.p12` - PKCS12 like above but without password
 - `localhost.pkcs12`     - PKCS12 like above but with name/alias for the private key
 - `localhost.jks`        - a Java key store file 
 - `localhost.csr`        - the certificate sign request
    
All password protected key stores would use the password specified in `gencert.sh`.


    
## Renewing certificates

To [renew](https://www.golinuxcloud.com/renew-expired-root-ca-certificate-openssl/) a certificate,
call the `./renew-cert.sh` script with the certificate base file name and optional expiration in days: 

    ./renew-cert.sh ca 3650       # for the root CA
    ./renew-cert.sh localhost     # defaults to 365 days


