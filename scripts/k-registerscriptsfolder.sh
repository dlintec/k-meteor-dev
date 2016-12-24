#!/bin/bash
main() {
###script k-registerscriptsfolder.sh
filelines=$(ls $LOCAL_IMAGE_PATH/scripts)

for line in $filelines ; do
    #echo "Creando link para script $line"
	$LOCAL_IMAGE_PATH/scripts/k-registerscript.sh $LOCAL_IMAGE_PATH/scripts/$line
done

}
main "$@"
