mkdir -p ~/.vim/{autoload,bundle,.vimswap,.vimundo}
    && cp dev/autoload/{bundle,entry}.vim ~/.vim/autoload
    && echo 'call entry#init()' >> ~/.vimrc

# download plugin, in background
