#!/bin/bash
#k-registerscript.sh
main() {
cadena="$1"
nombrecompleto="${cadena##*/}"
extension="${nombrecompleto##*.}"
solonombre="${nombrecompleto%%.*}"
chmod +x $cadena

ln -sf $LOCAL_IMAGE_PATH/scripts/$nombrecompleto /usr/local/bin/$solonombre
ln -sf $LOCAL_IMAGE_PATH/scripts/$nombrecompleto /home/meteor/links/$solonombre

echo "$solonombre"
}

main "$@"
