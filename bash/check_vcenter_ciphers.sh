#!/bin/bash
#
# Author: Dominik Zorgnotti
# Created: 2023-09-21
# Modified: 2023-09-21
#
# Return the supported OpenSSL ciphers against a list of well-known vCenter ports.
# Applicable vCenter version: 8
#
# Globals:
#   VCENTER_HOST
#   VCENTER_PORTS

VCENTER_HOST="127.0.0.1"
VCENTER_PORTS=( 443 636 1514 5480 5580 8084 9087 )
readarray -t OPENSSL_CIPHERS < <(openssl ciphers | tr ":" "\n")

echo "Connecting to ${VCENTER_HOST}"
for port in "${VCENTER_PORTS[@]}"
do
  echo "Testing on port ${port}"
  for cipher in "${OPENSSL_CIPHERS[@]}"
    do 
       connection=$(echo -n "Q" | openssl s_client -cipher ${cipher} -connect ${VCENTER_HOST}:${port} 2>&1)
       if (( $? == 0 )); then
         if [[ "$connection" =~ "Cipher    :" ]] ; then
           echo "SUCCESS: ${cipher}"
         fi
       fi
    done
  echo "---"
done
