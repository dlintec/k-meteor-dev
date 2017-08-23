#!/bin/bash  
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
current_app=$(kalan-var "CURRENT_APP")
echo "Starting Build for $current_app for http://$DOMAIN_NAME:80 ..."
meteor build /opt/application/$current_app/build --server=http://$DOMAIN_NAME:80
    
