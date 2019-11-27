fu! Bufadd(name)
    let nr = bufadd('')
    exec 'b ' . nr
    echom bufnr('%') nr a:name
    exec 'file ' . a:name
    b #
endfu

let g:term = 'E:\cygwin64\bin\zsh.exe'
set isfname+=:,\
set isfname-=~

if !exists('*gvim#after')
set guifont=Consolas:h14:cANSI:qDRAFT
set winaltkeys=no
endif
func! gvim#after(...)

nnoremap <M-x> :<C-u>call run#GetInputCommandThenCaptureAndPut()<CR>
" inoremap <M-x> <Esc>:<C-u>call run#GetInputCommandThenCaptureAndPut()<CR>
nnoremap <M-c> :<C-u>pu= C(input(':'))<CR>

au filetype dirbuf nn <buffer> E :exec '!start explorer ' . b:dirbuf<CR><CR>

nn <M-s> :up<CR>
ino <M-s> <Esc>:up<CR>
sil! au! LeaderF_Mru bufwritepost
sil! au! LeaderF_Gtags bufwritepost
sil! au! repeatPlugin bufwritepost
sil! au! matchparen

ino <M-b> <S-Left>
ino <M-f> <S-right>
nn <Space>i :CtrlPBuffer<CR>

let $ROOT=substitute($ROOT,'\','/','g')
let $PS1='$ '
let $zshrc=$ROOT . 'rc/lib/bash/profile'
" let $ZDOTDIR=$ROOT . 'rc/lib/bash/profile'
let $PATH='/bin:' . $PATH
"gvim: to make `:py3` work, python36.dll directory must in system's PATH.
"gvim on Windows is 32-bit only, make sure python36.dll is 32-bit too.
" let $PATH=$ROOT . 'pkg/bin:/bin:' . $PATH


augroup ftvim
    autocmd!
    setlocal dict=E:\nnotes\dev\rc\dict-vim
augroup END " ftvim

endfunc " gvim#after
call timer_start(1000, 'gvim#after')
