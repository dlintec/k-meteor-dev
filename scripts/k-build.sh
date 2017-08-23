#!/bin/bash  
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
current_app=$(kalan-var "CURRENT_APP")
meteor build ~/build-output-directory --server=your-desired-app-hostname.meteor.com
    
keytool -genkey -alias your-app-name -keyalg RSA -keysize 2048 -validity 10000

cd ~/build-output-directory/android/

jarsigner -digestalg SHA1 unaligned.apk your-app-name
