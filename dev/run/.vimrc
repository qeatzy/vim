" ~/.vimrc
" find '~/.vim' or '~/vimfiles' and remove from rtp
let &rtp = substitute(&rtp,'\','/','g')
let idx = match(&rtp, ',')
let $ROOT = &rtp[:idx-1] . '/'
let &rtp = &rtp[idx+1:]

" prepend '~/.vim/vim/dev' or '~/vimfiles/vim/dev' to rtp
set rtp^=$ROOT/vim/dev
if has('win32')
    set rtp^=$ROOT/vim/dev/platform_windows
endif

call entry3#init()
