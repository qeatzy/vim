let s:dir = expand('<sfile>:p')
let s:root = fnamemodify(s:dir, ':h:h:h')

func! AddPlugins(...) abort
    " let root = get(a:, 1, "$HOME/.vim/bundle")
    " let plugins = readdir(root, {n -> isdirectory(n)})
    let root = get(a:, 1, $HOME . "/.vim/bundle")
    " echo root
    " /home/zyq3e/.vim/bundle
    " let plugins = readdir(root, {n -> isdirectory(n)})
    let plugins = readdir(root)
    " echo plugins
    let g:a = plugins
    for d in plugins
        let d = root . '/' . d
        if isdirectory(d)
            let g:a2 = d
            " let &rtp .= printf(",%s", d)
            exec printf("set rtp+=%s", d)
            if isdirectory(d . '/after')
                " let &rtp .= ',' . d . '/after'
                exec printf("set rtp+=%s/after", d)
            endif
        endif
    endfor
endfunc " AddPlugins

" call AddPlugins()

