#!/bin/bash
filelines=$(ls -d */ /opt/application | cut -f1 -d'/')

for line in $filelines ; do
    #echo "Checking $line"
    if [ -d /opt/application/$line/app/.meteor ] && [ ! "$line" == "_k-meteor-dev" ];then
       echo $line
    fi

done


