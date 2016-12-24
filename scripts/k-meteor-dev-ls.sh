#!/bin/bash
main() {
###script k-meteor-dev-ls.sh
filelines=$(ls /opt/application)
valid_apps=""
for line in $filelines ; do
    #echo "Creando link para script $line"
    if [ -d /opt/application/$line/app/.meteor ];then
       valid_apps=$($valid_apps;line)
    fi

done
echo valid_apps
}
main "$@"
