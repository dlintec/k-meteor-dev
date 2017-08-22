#!/bin/bash  
if  grep -q "ANDROID_HOME" $HOME/.bashrc; then
    echo "Android tools already installed"
else

   #wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip 
   #unzip sdk-tools-linux-3859397 -d /home/meteor/android
   #echo 'export ANDROID_HOME=/usr/lib/android-sdk' >> ~/.bashrc
   #echo 'export PATH=$PATH:/home/meteor/android/tools:/home/meteor/android/tools/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools' >> ~/.bashrc
   #touch ~/.android/repositories.cfg
   
   wget https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
   unzip tools_r25.2.3-linux -d /home/meteor/android25
   echo 'export ANDROID_HOME=/home/meteor/android25/tools' >> ~/.bashrc
   echo 'export PATH=$PATH:/home/meteor/android25/tools:/home/meteor/android25/tools/bin' >> ~/.bashrc
   touch ~/.android/repositories.cfg
 
fi

