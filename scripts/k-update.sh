#!/bin/bash
main() {

cd $LOCAL_IMAGE_PATH
git fetch --all
git reset --hard origin/master
git pull
chmod -R +x $LOCAL_IMAGE_PATH/scripts/
find $LOCAL_IMAGE_PATH/. -name "*.sh" | xargs chmod +x
$LOCAL_IMAGE_PATH/scripts/k-registerscriptsfolder.sh
$LOCAL_IMAGE_PATH/scripts/k-post-update.sh
}

main "$@"
