#!/bin/bash  
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm' >> $HOME/.bashrc
source $NVM_DIR/nvm.sh

nvm install node
