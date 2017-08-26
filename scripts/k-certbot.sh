#!/bin/bash  
if [ "$(whoami)" == "root" ];then
  source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
  current_app=$(kalan-var "CURRENT_APP")

  server_url="$(kalan-var 'SERVER_URL')"
  ssl_mail="$(kalan-var 'SSL_MAIL')"
  ssl_domain="$(kalan-var 'SSL_DOMAIN')"

  if [ -z "$ssl_mail" ] || [ -z "$ssl_domain" ] || [ "$ssl_mail" == "changeme" ] || [ "$ssl_domain" == "changeme" ];then
    echo "SSL certificate can not be created"
    echo "Must define valid SSL_MAIL and SSL_DOMAIN at settings"
  else
    echo "Creating SSL certificate (certbot)"
    echo "mail:[$ssl_mail] domain:[ssl_domain]"
    file_line_value /home/meteor/nginxconf/nginx-proxy-settings "server_name" "server_name $ssl_domain;"
    file_line_value /home/meteor/nginxconf/nginx-proxy-settings "include snippets/self-signed.conf;" "#include snippets/self-signed.conf;"
    file_line_value /home/meteor/nginxconf/nginx-proxy-settings "include snippets/ssl-params.conf;" "#include snippets/ssl-params.conf;"
    echo "#deleted self_signed.conf" > /home/meteor/nginxconf/self_signed.conf 
    echo "#ssl_certificate /home/meteor/ssl/certs/nginx-selfsigned.crt;" >> /home/meteor/nginxconf/self_signed.conf 
    echo "#ssl_certificate_key /home/meteor/ssl/certs/nginx-selfsigned.key;" >> /home/meteor/nginxconf/self_signed.conf 
 
    file_line_value /home/meteor/nginxconf/ssl_params.conf "ssl_dhparam" "#ssl_dhparam /home/meteor/ssl/certs/dhparam.pem;"

    certbot --nginx --agree-tos -m $ssl_mail 
  fi
else
   echo "You must be root to create SSL certificate"
fi
