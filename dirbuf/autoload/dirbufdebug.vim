" intentionally need to run multiple times, eg, during debug, change then reload.

call dirbufcore#init()

if !exists('debugfile')
    let s:file = expand('<sfile>')   " inner, prevent injection
    let s:time_sourced = localtime()
    let debugfile = s:file " outer interface
elseif debugfile != s:file
    let debugfile = s:file " outer interface
endif

let s:time_sourced_new = localtime()
if !exists('*dirbufdebug#init')
" delfunc dirbufdebug#init to force reload. or just call dirbufdebug#nonexist()
    func dirbufdebug#init() abort
        if s:time_sourced < getftime(s:file)
            exec 'source ' . s:file
            let s:time_sourced = s:time_sourced_new
        endif
        return s:time_sourced
    endfunc " dirbufdebug#dl_init
    func! s:init()
        if s:time_sourced != s:time_sourced_new
            call dirbufdebug#init()
        endif
    endfunc
endif
let s:time_sourced = s:time_sourced_new


func! dirbufdebug#check(root) abort
    " call s:init()   " you can not re-define a in-use function (yourself)
    let [d, abspath, realpath, updated] = dirbufcore#add(a:root)
    let base = realpath . '/'
    let ret = []
    " return
    for name in d.dirs
        if !has_key(d.tree, name)
            let path = resolve(base . name)
            let s = g:dirs[path]
            " subdir
            call add(ret, [path]) ", len(get(s,'tree_cache',[])), len(s.dirs), len(s.tree)])
            " call add(ret, [name ]) ", len(get(s,'tree_cache',[])), len(s.dirs), len(s.tree)])
            " call add(ret, [name, len(get(s,'tree_cache',[])), len(s.dirs), len(s.tree)])
        endif
    endfor
    return ret
    return [len(d.dirs), len(d.tree)]
endfunc " dirbufdebug#dl_no_cach_subdirs
