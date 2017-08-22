#!/bin/bash  
if [ ! -d /home/meteor/Android ]; then
   wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
   unzip sdk-tools-linux-3859397 -d /home/meteor/android
   echo 'export ANDROID_HOME=$HOME/android' >> ~/.bashrc
   echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin' >> ~/.bashrc
else
  echo "Android tools already installed"
fi

