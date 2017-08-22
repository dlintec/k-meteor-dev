#!/bin/bash  
if  grep -q "ANDROID_HOME" $HOME/.bashrc; then
    echo "Android tools already installed"
else

     #wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
   #unzip sdk-tools-linux-3859397 -d /home/meteor/android
   echo 'export ANDROID_HOME=/usr/lib/android-sdk' >> ~/.bashrc
   echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> ~/.bashrc

fi

