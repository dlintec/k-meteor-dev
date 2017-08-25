#!/bin/bash  
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
current_app=$(kalan-var "CURRENT_APP")
server_url="$(kalan-var 'SERVER_URL')"

mobile_build_url="$(kalan-var 'MOBILE_BUILD_URL')"
if [ -z "$mobile_build_url" ] ;then
   mobile_build_url="$server_url"
   kalan-var "MOBILE_BUILD_URL" "$mobile_build_url"
fi


echo "Building app [$current_app] MOBILE_BUILD_URL=$mobile_build_url ..."

# modificar archivo de cordova para aceptar certificados autofirmados
# cd /opt/application/android/app/.meteor/local/cordova-build/platforms/android/CordovaLib/src/org/apache/cordova/engine
# /app/.meteor/local/cordova-build/platforms/android/CordovaLib/src/org/apache/cordova/engine/SystemWebViewClient.java

meteor build /opt/application/$current_app/build --server=$mobile_build_url 
    
