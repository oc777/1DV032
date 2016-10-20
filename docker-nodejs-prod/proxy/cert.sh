#! /bin/bash
echo "Generating self-signed certificates..."
rm -rf ./sslcerts
mkdir -p ./sslcerts
openssl genrsa -out ./sslcerts/key.pem 4096
openssl req -new -key ./sslcerts/key.pem -out ./sslcerts/csr.pem
openssl x509 -req -days 365 -in ./sslcerts/csr.pem -signkey ./sslcerts/key.pem -out ./sslcerts/cert.pem
rm ./sslcerts/csr.pem
chmod 600 ./sslcerts/key.pem ./sslcerts/cert.pem
