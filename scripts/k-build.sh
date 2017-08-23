#!/bin/bash  
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
current_app=$(kalan-var "CURRENT_APP")
echo "Starting Build for $current_app ..."
meteor build /opt/application/$current_app/build --server=$DOMAIN_NAME:80
    
