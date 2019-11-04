" .+,$s/\<dirbufcore#/dirbuf#/g
" .+,$s/\<pathbuf#/dirbuf#/g
if exists('*dirbuf#init')
    finish
endif
func! dirbuf#init() abort
endfunc " dirbuf#init

let g:dh_dirs = {}
let g:rdh_dirs = {}

func! dirbuf#goparent(cnt) abort
    let path = expand('%')
    if path == '' | let path = path#cwd() | endif
    if isdirectory(path)
        if get(b:, 'dirbuf')[0] == '/'
            call dirbuf#openpath(path#abspath(path . '/..'))
        else
            call dirbuf#openpath(path)
        endif
    else
            call dirbuf#openpath(path#abspath(path . '/..'))
    endif
endfunc " dirbuf#goparent

fun! KeyPrefix_r() abort
    while 1
        echo "\r r"
        let c = getchar()
        let ch = nr2char(c)
        echo c "|" ch
        if c is# "\<BS>" || ch ==# "q"
            break
        elseif ch == "m"
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
    let type = get(a:, 1, 'dir')
    let force = get(a:, 2, 0)
    let abspath = path#abspath(a:path)
    let b = get(g:dh_dirs, abspath)
    if type(b) == v:t_number
        let b = s:addpath(abspath)
    endif
    let d = path#upget(b.realpath)
    if force || b.viewtime < d.mtime || b.viewttype != type
        if type == 'tree'
            if !has_key(d, 'tree_cache')
                echom "tree_cache not build yet, try again later"
                call path#test(abspath)
                return
            else
                let files = d.tree_cache
            endif
        elseif type == 'dir'
            let files = d.dl
        endif
        let b.viewtime = d.mtime
        let b.viewttype = type
        let num = len(files) + 1
        let nr = b.bufnr
        if !empty(getbufline(nr, num, num))
            call deletebufline(nr, num, '$')
        endif
        call setbufline(nr, 1, files)
    endif
    if get(a:, 2, 1)
        exec 'b ' . b.bufnr
    endif
endfunc " dirbuf#openpath

func! s:addpath(abspath) abort
    let bufname = a:abspath
    let dh = get(g:dh_dirs, bufname, {})
    if empty(dh)
        let realpath = bufname == '/' ? '/' : resolve(a:abspath)
        let nr = bufadd(bufname)
        call setbufvar(nr, '&buftype', 'nofile')
        call setbufvar(nr, '&ft', 'dirbuf')
        call setbufvar(nr, 'dirbuf', bufname)
        call setbufvar(nr, '&buflisted', 0)
        sil call bufload(nr)    " no cost, removal cause bug
        let dh['bufnr'] = nr
        let dh['realpath'] = realpath
        " let dh['d'] = path#get(realpath)  " do not, may be invalid later
        let dh['viewtime'] = -1
        let g:dh_dirs[bufname] = dh
        let g:rdh_dirs[nr] = bufname
    endif
    return dh
endfunc " s:addpath


func! s:pathjoin(abspath, name)
    let name = (a:abspath == '/' ? '' : a:abspath) . '/' . a:name
    return name
endfunc " s:pathjoin

func! dirbuf#dh_enter() abort
    " only be called if ft=dirbuf
    let abspath = get(g:rdh_dirs, bufnr('%'), '')
    if abspath == '' | echom "dh_enter: not dirbuf buffer" | return | endif
    let name = s:pathjoin(abspath, getline('.'))
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
    nn <buffer><silent> i :<C-u>call dirbuf#dh_enter()<CR>
    nn <buffer> t :<C-u>call dirbuf#openpath(expand('%'), 'tree')<CR>
    nn <buffer> R :<C-u>call dirbuf#openpath(expand('%'), 'dir', 1)<CR>
    nn <buffer> r :<C-u>call KeyPrefix_r()<CR>
endfunc
