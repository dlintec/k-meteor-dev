#!/bin/bash  
if [ ! -d /home/meteor/Android ]; then
   wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
   unzip sdk-tools-linux-3859397 -d /home/meteor/Android

else
  echo "Android tools already installed"
fi

