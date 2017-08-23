#!/bin/bash  
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
current_app=$(kalan-var "CURRENT_APP")
meteor build /opt/application/$current_app/build --server=$DOMAIN_NAME:80
    
    
keytool -genkey -alias $current_app -keyalg RSA -keysize 2048 -validity 10000

cd /opt/application/$current_app/build/android/

jarsigner -digestalg SHA1 unaligned.apk $current_app
