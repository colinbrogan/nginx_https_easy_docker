#!/bin/bash

FILE=/etc/letsencrypt/live/${DOMAIN}/fullchain.pem


if ! test -f "$FILE"
then
	echo "No cert yet. Run on domain: ${DOMAIN}"
    mkdir /var/www
    echo "Made www folder?"
    echo $(ls /var/www)
    mkdir /var/www/html
    echo "Made www/html folder?"
    echo $(ls /var/www/html)

    echo "Wait 5 seconds for NGINX to be ready"
    sleep 5
    certbot certonly --webroot  --webroot-path=/var/www/certbot --noninteractive --agree-tos -m colinbrogan@gmail.com -d "${DOMAIN}" -d "www.${DOMAIN}"
else
	echo "Cert already exists, move on to renew loop"
fi

while true
do
	echo "Wait 12 hours..."
    sleep 12h &
    wait $!
    echo "...12 hours past, try and renew"
    certbot renew
done
