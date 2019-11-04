if exists('*tab#init')
    finish
endif
func! tab#init()
    echo "tab#init() called"
endfunc tab#init()
" put below line in .vimrc to lazy load (or under plugin directory)
" autocmd tab_init TabNew * ++once call tab#init()

set showtabline=0
