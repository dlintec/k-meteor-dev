#!/bin/bash
filelines=$(ls /opt/application )

for line in $filelines ; do
    #echo "Checking $line"
    if [ -d /opt/application/$line/app/.meteor ] && [ ! "$line" == "_k-meteor-dev" ];then
       echo $line
    fi

done


