#!/bin/bash  
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | sh

source $NVM_DIR/nvm.sh

nvm install node
