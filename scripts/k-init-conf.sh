#!/bin/bash  
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
current_app=$(kalan-var "CURRENT_APP")

if [ ! -e /home/meteor/.$GIT_IMAGE.cfg ];then
 echo "CONTAINER_NAME=$GIT_IMAGE" >> /home/meteor/.$GIT_IMAGE.cfg
fi

 server_url="$(kalan-var 'SERVER_URL')"
 if [ -z "$server_url" ] ;then
    server_url="http://$DOMAIN_NAME"
    kalan-var "SERVER_URL" "$server_url"
 fi

 ssl_mail="$(kalan-var 'SSL_MAIL')"
 if [ -z "$ssl_mail" ] ;then
    ssl_mail="changeme"
    kalan-var "SSL_MAIL" "$ssl_mail"
 fi

 ssl_domain="$(kalan-var 'SSL_DOMAIN')"
 if [ -z "$ssl_domain" ] ;then
    ssl_domain="changeme"
    kalan-var "SSL_DOMAIN" "$ssl_domain"
 fi
