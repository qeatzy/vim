" .+,$s/\<dirbufcore#/dirbuf#/g
" .+,$s/\<pathbuf#/dirbuf#/g
" if exists('*dirbuf#init')
"     finish
" endif
" func! dirbuf#init() abort
" endfunc " dirbuf#init

let g:dh_dirs = get(g:, 'dh_dirs', {})
let g:rdh_dirs = get(g:, 'rdh_dirs', {})

func! dirbuf#goparent(cnt) abort
    let path = expand('%')
    if path == '' | let path = path#cwd() | endif
    let isdir = isdirectory(path)
    if isdir && get(b:, 'dirbuf')[1] != ':'     " not loaded
            call dirbuf#openpath(path)
    else
            let g:lastpath = path
            let g:lastpath_isdir = isdir
            call dirbuf#openpath(path#abspath(path . repeat('\..',a:cnt)))
    endif
endfunc " dirbuf#goparent

fun! KeyPrefix_r() abort
    while 1
        echo "\r r"
        let c = getchar()
        let ch = nr2char(c)
        " echo c "|" ch
        if c is# "\<BS>" || ch ==# "q"
            break
        elseif ch ==# "t"
            call dirbuf#openpath(expand('%'), 'path#gd')
            break
        elseif ch ==# "s"
            call dirbuf#openpath(expand('%'), 'path#gs')
            break
        elseif ch ==# "m"
            " confirm echo 'rm ' . b:dirbuf . '/' . getline('.')
            let cmd = "rm '" . escape(b:dirbuf . '/' . getline('.'),"'") . "'"
            let choice = io#confirm(cmd . " (y)es (n)o"
                        \ , "yn")
            call system(cmd)
            " confirm !echo "hello world"
            break
        endif
    endwhile
endfunc

func! dirbuf#openpath(path, ...) abort
    let abspath = path#abspath(a:path)
    let dh = get(g:dh_dirs, abspath)
    if type(dh) == v:t_number
        let dh = s:addpath(abspath)
    endif
    let d = path#upget(dh.realpath)
    let Sorter = get(a:, 1)
    if dh.viewtime < d.mtime || Sorter isnot# 0
    " if dh.viewtime < d.mtime
        if Sorter is# 0
            let files = d.df
        else
            if type(Sorter) isnot# 2   " funcref
                let Sorter = function(Sorter)
            endif
            let files = Sorter(d)
        endif
        let dh.viewtime = d.mtime
        let num = len(files) + 1
        let nr = dh.bufnr
        if !empty(getbufline(nr, num, num))
            call deletebufline(nr, num, '$')
        endif
        call setbufline(nr, 1, files)
    endif
    if get(a:, 2, 1)
        exec 'b ' . dh.bufnr
    endif
    if !exists('files') | let files = getline(1,'$') | endif
    call s:cursor(abspath, files)
endfunc " dirbuf#openpath

let g:lastpath = get(g:, 'lastpath', '')
func! s:cursor(abspath, files)
    let n = len(a:abspath)
    " if len(g:lastpath) > n && g:lastpath[n] ==# '/' && g:lastpath[:n-1] ==# a:abspath
    if len(g:lastpath) > n && g:lastpath[:n-1] ==# a:abspath
        if g:lastpath[n] !=# '/'
            if n == 1   " a:abspath ==# '/'
                let n = 0
            else
                return
            endif
        endif
        let stop = stridx(g:lastpath, '/', n+1)
        let name = g:lastpath[n+1:stop]
        if stop == -1 && g:lastpath_isdir
            let name .= '/'
        endif
        if name !=# getline('.')
            let idx = index(a:files, name) + 1
            let pos = getcurpos()
            let pos[1] = idx
            call setpos('.', pos)
        endif
    endif
    " let g:lastpath = a:abspath
    " let g:lastpath_isdir = 1
endfunc " s:cursor
    

let g:dbufs = get(g:, 'dbufs', [])
func! s:addpath(abspath) abort
    let bufname = a:abspath
    let dh = get(g:dh_dirs, bufname)
    if dh is# 0
        let realpath = bufname == '/' ? '/' : resolve(a:abspath)
        " if len(bufname) == 2 | let bufname .= '\' | endif
        " culprit, in gvim, 'C:' is not a valid path, 'C:\' is.
        " getftime('C:') return -1
        " bufnr('C:') will return first bufnr under 'C:\'
        " readdir('C:') works though
        " windows gvim 8.1-2300 Yonghui build, bufadd() bug
        " bufadd('C:') return bufnr of ('C:\Users'), bufnr() the same
        " let nr = bufadd(bufname)
        let nr = bufadd( len(bufname) > 2 ? bufname : bufname . '\')
        call add(g:dbufs, [nr, bufname])
        " let nr = bufadd('')
        " exec 'b ' . nr
        " exec 'file ' . bufname
        " b #
        call setbufvar(nr, '&buftype', 'nofile')
        call setbufvar(nr, '&ft', 'dirbuf')
        call setbufvar(nr, 'dirbuf', bufname)
        call setbufvar(nr, '&buflisted', 0)
        sil call bufload(nr)    " no cost, removal cause bug
        call setbufvar(nr, '&readonly', 0)
        let dh = {'bufnr': nr, 'realpath': realpath}
        let dh['viewtime'] = -1
        let g:dh_dirs[bufname] = dh
        let g:rdh_dirs[nr] = bufname
    endif
    return dh
endfunc " s:addpath


func! s:pathjoin(abspath, name)
    " let name = (a:abspath == '/' ? '' : a:abspath) . '/' . a:name
    let name = a:abspath . '\' . a:name
    return name
endfunc " s:pathjoin

func! dirbuf#dh_enter(...) abort
    " only be called if ft=dirbuf
    " let abspath = get(g:rdh_dirs, bufnr('%'), '')
    " if abspath == '' | echom "dh_enter: not dirbuf buffer" | return | endif
    let abspath = get(b:, 'dirbuf')
    if abspath is# 0 | echom "dh_enter: not dirbuf buffer" | return | endif
    let name = s:pathjoin(abspath, var#getline(get(a:, 1)))
    echo getline('.+2')
    if isdirectory(name)
        call dirbuf#openpath(name)
    else
        exec 'e ' . name
    endif
endfunc " dirbuf#dh_enter

" test
" let ot=reltimefloat(reltime()) | exec 'norm i' | echo reltimefloat(reltime()) - ot
" on large directory, eg, /bin on cygwin, (895 files)
"     reopen, already opened & not changed,
"     -- dirvish takes time 0.780s, dirbuf takes time 0.008s
"     first time open
"     -- dirvish takes time 1.18 - 1.44s, dirbuf takes time 0.28 - 0.45s

func dirbuf#setup() abort
    nn <buffer><silent> i :<C-u>call dirbuf#dh_enter(v:count)<CR>
    nn <buffer><silent> I :<C-u>call dirbuf#dh_enter(-v:count)<CR>
    " so %
    nn <buffer> t :<C-u>call path#tree(b:dirbuf)<CR>:call dirbuf#openpath(expand('%'), {d -> d.tree})<CR>
    " nn <buffer> R :<C-u>call dirbuf#openpath(expand('%'), 'dir', 1)<CR>
    nn <buffer> R :<C-u>call dirbuf#openpath(expand('%'),{d -> d.df})<CR>
    nn <buffer> r :<C-u>call KeyPrefix_r()<CR>
    nn <buffer> p :<C-u>call path#info()<CR>
    nn <buffer> E :<C-u>exec '!cygstart ' . b:dirbuf<CR><CR>
endfunc

func! dirbuf#x()
endfunc " dirbuf#x
