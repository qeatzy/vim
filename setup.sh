# change to
# call setup#init()
mkdir -p ~/.vim/{autoload,bundle,.vimswap,.vimundo}
    && cp dev/autoload/{bundle,entry}.vim ~/.vim/autoload
    && echo 'call entry#init()' >> ~/.vimrc
    # also gvim.vim if needed

# download plugin, in background
git clone https://github.com/SirVer/ultisnips ~/.vim/bundle/ultisnips
