func! setup#init()
    let root = matchstr(&rtp, '^[^,]*') . '/'
    let $ROOT = matchstr(&rtp, '^[^,]*') . '/'
    sil! call mkdir(root . 'autoload')
    sil! call mkdir(root . 'bundle')
    sil! call mkdir(root . '.vimswap')
    sil! call mkdir(root . '.vimundo')
    if has('win32')
        sil! call mkdir(root . 'pkg/bin', 'p')
    endif
    " mkdir -p ~/.vim/{autoload,bundle,.vimswap,.vimundo}
    let rtp = matchstr(&rtp, ',\zs.*')
    for fn in ["bundle.vim", "entry.vim"]
        let fn = 'autoload/' . fn
        let files = globpath(rtp, fn, 0, 1)
        if !empty(files)
            let lines = readfile(files[0])
            call writefile(lines, $ROOT . fn)
        endif
    endfor
"     all
" bundle.vim
" entry.vim
"     windows gvim
" dirbuf.vim
" gvim.vim
" path.vim
endfunc " setup#init
