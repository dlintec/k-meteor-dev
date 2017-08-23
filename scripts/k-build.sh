#!/bin/bash  
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
current_app=$(kalan-var "CURRENT_APP")
echo "Starting Build for $current_app ..."
meteor build /opt/application/$current_app/build --server=$DOMAIN_NAME:80
    
echo "------------------------------------"
echo "Starting Keytool to sign ..."
keytool -genkey -alias $current_app -keyalg RSA -keysize 2048 -validity 10000

echo "------------------------------------"
echo "Starting jarsigner to sign ..."
cd /opt/application/$current_app/build/android/

jarsigner -digestalg SHA1 release-unsigned.apk $current_app
