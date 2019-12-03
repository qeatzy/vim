func! setup2#bootstrap(names) abort
    let names = type(a:names) != 3 ? [a:names] : a:names
    let idx = match(&rtp, ',')
    let rtp = ($ROOT == &rtp[:idx-1] . '/') ? &rtp[idx+1:] : &rtp
    for fn in names
        let fn = 'autoload/' . fn
        let files = globpath(rtp, fn, 0, 1)
        if !empty(files)
            let lines = readfile(files[0])
            call writefile(lines, $ROOT . fn)
        endif
    endfor
endfunc " setup#bootstrap

func! setup2#init(...)
    let dirs_basic = a:0 > 1 ? a:2 : ['autoload','bundle','.vimswap','.vimundo','tmp']
    if has('win32') && a:0 > 2
        " call add(dirs_basic, 'pkg/bin')
        call add(dirs_basic, a:2)
    endif
    for dir in dirs_basic
        sil! call mkdir($ROOT . dir, 'p')
    endfor
    call setup2#bootstrap('entry2.vim')
    " mkdir -p ~/.vim/{autoload,bundle,.vimswap,.vimundo}
"     all
" bundle.vim
" entry.vim
"     windows gvim
" dirbuf.vim
" gvim.vim
" path.vim
endfunc " setup#init
