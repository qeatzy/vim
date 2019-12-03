call entry#init()

func! s:lazy_dirbuf_pwd(timer) abort
    call dirbuf#openpath($PWD,0,0)
endfunc
let Lazy_dirbuf_pwd = funcref('s:lazy_dirbuf_pwd')

    autocmd VimEnter * let g:timer = timer_start(200, Lazy_dirbuf_pwd)
