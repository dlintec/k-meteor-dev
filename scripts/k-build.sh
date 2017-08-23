#!/bin/bash  
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
current_app=$(kalan-var "CURRENT_APP")
echo "Starting Build for $current_app for http://11.0.0.132:80 ..."
meteor build /opt/application/$current_app/build --server=http://11.0.0.132:80
    
