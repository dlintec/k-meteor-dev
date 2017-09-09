#!/bin/bash  
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
meteor remove-platform android
$LOCAL_IMAGE_PATH/scripts/k-android.sh

export ANDROID_HOME=/home/meteor/android25
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin

current_app=$(kalan-var "CURRENT_APP")
server_url="$(kalan-var 'SERVER_URL')"
if [ ! -e /opt/application/$current_app/app/app_config.txt ];then
  echo "MOBILE_BUILD_URL=$server_url" > /opt/application/$current_app/app/app_config.txt
fi
mobile_build_url="$(file_line_value /opt/application/$current_app/app/app_config.txt 'MOBILE_BUILD_URL' )"
if [ -z "$mobile_build_url" ] || [ "$mobile_build_url" == "changeme" ] || [ "$mobile_build_url" == "http://127.0.0.1" ] || [ "$mobile_build_url" == "http://localhost" ];then
  echo "You must define a MOBILE_BUILD_URL value"
  echo "in app_config.txt file. "
  echo "MOBILE_BUILD_URL should be the IP or domain"
  echo "of the server of this app"
  echo "MOBILE_BUILD_URL=http://myappdomain.com"
else
  echo "Building app [$current_app]..."
  echo "---------------------------------------"
  echo "       SERVER_URL:[$server_url]"
  echo " MOBILE_BUILD_URL:[$mobile_build_url]"
  echo "---------------------------------------"
  # modificar archivo de cordova para aceptar certificados autofirmados
  # cd /opt/application/android/app/.meteor/local/cordova-build/platforms/android/CordovaLib/src/org/apache/cordova/engine
  # /app/.meteor/local/cordova-build/platforms/android/CordovaLib/src/org/apache/cordova/engine/SystemWebViewClient.java

  meteor build /opt/application/$current_app/build --server=$mobile_build_url 
  $LOCAL_IMAGE_PATH/scripts/k-sign.sh
  if [ -e /opt/application/$current_app/app/public/release-unsigned.apk ];then
      echo "removind previous APK /opt/application/$current_app/app/public/release-unsigned.apk"
      rm -rf /opt/application/$current_app/app/public/release-unsigned.apk
  fi
  echo "Copying APK to /opt/application/$current_app/app/public/release-unsigned.apk"
  
  cp -rf /opt/application/$current_app/build/android/release-unsigned.apk /opt/application/$current_app/app/public/release-unsigned.apk

fi  
