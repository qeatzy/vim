" !cp % ~/.vim/autoload
" !ln -s %:p ~/.vim/autoload
" !ln -s `cygpath -w %:p` ~/.vim/autoload/bundle.vim
" !cygpath -w %:p
" rm ~/.vim/autoload/bundle.vim
" ll ~/.vim/autoload/bundle.vim

if exists('g:loaded_bundle')
    finish
endif

func! bundle#init(...) abort
    let root = get(a:, 1, $HOME . "/.vim/bundle")
    " /home/zyq3e/.vim/bundle
    let plugins = readdir(root)
    let g:a = plugins
    for d in plugins
        if bundle#ignore(d)
            continue
        endif
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
endfunc " bundle#init

if !exists('g:bundle_ignore')
    let g:bundle_ignore = []
endif
func! bundle#ignore(name)
    return match(g:bundle_ignore, a:name) != -1
endfunc " bundle#ignore

func! bundle#validate(arg)
    body
endfunc " bundle#validate

func! bundle#has(name) abort
    return match(&rtp, a:name) != -1
endfunc " bundle#has
