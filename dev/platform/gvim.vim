fu! Bufadd(name)
    let nr = bufadd('')
    exec 'b ' . nr
    echom bufnr('%') nr a:name
    exec 'file ' . a:name
    b #
endfu

let $platform = 'gvim'

tnoremap <C-u> <C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h><C-h>
func! s:C_d() abort
    let line = getbufline(5,'$')[0]
    let key = line[:2] ==# '>>>' ? repeat("\<C-h>",len(line)) . "exit()\<CR>" : "\<C-d>"
    call feedkeys(key,'n')
endfunc " s:C_d
tnoremap <C-d> <C-w>:call <SID>C_d()<CR>

let $PAGER='vim'  " used by cmd, python inside cmd. not cygwin vim.
let g:term = 'E:\cygwin64\bin\zsh.exe'

if !exists('*gvim#after')
set guifont=Consolas:h14:cANSI:qDRAFT
set winaltkeys=no
endif
func! gvim#after(...)

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


endfunc " gvim#after
call timer_start(1000, 'gvim#after')
