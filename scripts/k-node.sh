#!/bin/bash  


 if grep -q "nvm.sh" $HOME/.bashrc; then
    echo "NVM already installed"
 else
    curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm' >> $HOME/.bashrc
    source $NVM_DIR/nvm.sh

    nvm install 'lts/*'
    echo "Type 'exit' to return to menu or open a new terminal for the changes to take effect"
 fi

