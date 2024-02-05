#!/bin/bash

FILE=/etc/letsencrypt/live/${DOMAIN}/fullchain.pem
echo "Setting up with domain: ${DOMAIN}"

sed -i "s|__DOMAIN__|${DOMAIN}|g" /tmp/docker.nginx
sed -i "s|__DOMAIN__|${DOMAIN}|g" /tmp/docker.nginx.switch_me

switchToHTTPSCert() {
    echo "We have the cert file. Now switch to that"
    cat /tmp/docker.nginx.switch_me > /tmp/docker.nginx
    cat /tmp/docker.nginx.switch_me > /etc/nginx/conf.d/default.conf
}



sleeptime=10s
while true
do
    sleep $sleeptime &
    wait $!
    if test -f "$FILE"
    then
        sleeptime=6h
        echo "Found file, set loop to check for updated script every 6 hours"
        switchToHTTPSCert
    else
        echo "No cert file yet, check again in 10 seconds"
    fi
    nginx -s reload
done &
echo "start nginx"
cat /tmp/docker.nginx > /etc/nginx/conf.d/default.conf
nginx-debug -g "daemon off;"