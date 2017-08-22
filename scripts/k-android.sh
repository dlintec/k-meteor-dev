#!/bin/bash  
if  grep -q "ANDROID_HOME" $HOME/.bashrc; then
    echo "Android tools already installed"
else

   wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
   unzip sdk-tools-linux-3859397 -d /home/meteor/android
   echo 'export ANDROID_HOME=/home/meteor/android/tools' >> ~/.bashrc
   echo 'export PATH=$PATH:/usr/lib/android-sdk/tools:/usr/lib/android-sdk/platform-tools' >> ~/.bashrc

fi

