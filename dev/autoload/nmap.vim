func! nmap#g(...) abort
    call operator#comment()
    " return "gcc"  " you cannot return string as command, simply not work, wether noremap or not.
endfunc " nmap#g

func! ReducePath(path) abort
    " vim's behavior, all filename that are not descendents of getcwd(-1)
    " are resolve()ed, which resolve symlink under all path component,
    " this happens when vim starts, and anytime global cwd change. eg.
    " getcwd(-1) changed. Also, if you change to where beyond current cwd
    " then all filename will be resolved. see help on getcwd() haslocaldir()
    if path[0] == '/'
        let is_abs = 1
    else
        let is_abs = 0
        let path = 
endfunc

func! nmap#yank_filename(...) abort
    let path = get(a:, 1, expand('%'))
    let @" = path[0] == '/' ? path : fnamemodify(path, ':p')
    let @+ = @"
    let @* = @"
    return
    let path = ReducePath()
endfunc " nmap#yank_filename

noremap <Plug>Nmap_g :<C-u>call <SID>g()<CR>

noremap <Plug>Nmap_g :<C-u>()<CR>
