#!/bin/bash  
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
current_app=$(kalan-var "CURRENT_APP")
server_url="$(kalan-var 'SERVER_URL')"
echo "Starting Build for $current_app for $server_url ..."

# modificar archivo de cordova para aceptar certificados autofirmados
# cd /opt/application/android/app/.meteor/local/cordova-build/platforms/android/CordovaLib/src/org/apache/cordova/engine
# /app/.meteor/local/cordova-build/platforms/android/CordovaLib/src/org/apache/cordova/engine/SystemWebViewClient.java

meteor build /opt/application/$current_app/build --server=$server_url 
    
