if exists('g:autoloaded_dirbufcore')
    finish
endif
let g:autoloaded_dirbufcore = expand('<sfile>')

" d -- directory
" dl  -- directory list, files in a directory, a member of d
" dh  -- directory house, use info from d & dl, manager of dirbuf buffers

let s:Directory = {}

let g:trees = {getcwd(-1) : []}

" how to notify to parent directory? a dir symlink can have mutliple parent.
" let d = $HOME . '/notes'
" echo d
" echo resolve(d . '/..')
" echo dirbufcore#simplify(d . '/..')

" # a dir symlink's mtime is always same as the linked target.
" # if a dir symlink is renamed, its mtime not change.
" :echom getftime('/cygdrive/e') getftime($HOME )
" ln -s /cygdrive/e/notes ~/dtmp
" :echom getftime('/cygdrive/e/notes') getftime($HOME . '/dtmp')
" mv ~/dtmp ~/d2tmp
" :echom getftime('/cygdrive/e/notes') getftime($HOME . '/d2tmp')
" mv ~/d2tmp ~/dtmp
" rm ~/dtmp


" # if a directory's mtime changed, cases are
" 1 a regular file is renamed/deleted.
" 2 a dir symlink or dir is renamed
"     child mtime unmodified
" 3 a dir or dir symlink is deleted
"     child lost

" # to cache/update tree
" each tree is composed of list of subdir trees + file list.
" But, instead of tree ask subdir for cache of subtree,
" tree maintain a list of subdir cache.
" why this? because in this way, 
" 1 when tree mtime change, subdir do not need update.
" 2 have to, since each dir has one true parent, and optionally
"     multiple parent via symlink.
" In summary, say a directory has n subdir and m regular files,
" then the tree cache rooted at that directory can be composed
" by n+1 list, when tree's mtime change, usually only one of
" the n+1 list will need updated.
" But do the tree need to propagate to ascendants?
" Or ascendants' mtime will be changed too?
" -- it's parent's mtime unmodified, thus need to notify 
"  its ascendants somehow.
" -- instead of eager propagate, it's better to mark "I have changed",
" and let ascendants choose when to update.

" # create empty directory xx, then xx/yy in explorer.exe
" # parent mtime changed
" :echom getftime('/cygdrive/e') getftime('/cygdrive/e/xx') getftime('/cygdrive/e/xx/yy') 
" # rename yy to zz, in explorer.exe
" :echom getftime('/cygdrive/e') getftime('/cygdrive/e/xx') getftime('/cygdrive/e/xx/zz') 
" # yy's mtime remain unchanged, parent mtime changed.
" :echom getftime('/cygdrive/e')
" To summarize, a node changed (remove/rename), only direct parent's mtime change.
" To clarify, if a subdir rename/removed.
" case 1, a symlink, has only one parent, 
" case 2, a dir, one direct parent, possibly other via symlink, 
" all those parent and its ascendants need to notified, each of them
" may be symlinked too.
" :echom getftype($HOME . '/notes') getftype('/cygdrive/e/notes')


func! s:current_tree() abort
    let kv = items(g:trees)[0]
    if empty(kv[1])
        call add(kv[1], kv[0])
    endif
    return kv
endfunc " s:current_tree

let s:max_stat_count = 100
func! s:update_tree() abort
    let [realpath, tree] = s:current_tree()
    let [i, n, stat_count] = [0, len(tree), 0]
    while i < n && stat_count < s:max_stat_count
        let [d, abspath, realpath, updated] = s:add(tree[i])
        let base = realpath == '/' ? '/' : realpath . '/'
        if updated
            let stat_count += len(d.dl)
        endif
        call extend(tree, map(copy(d.subdirs), 'base . v:val'))
        let i += 1
    endwhile
    if i > 0
        call remove(tree, 0, i-1)
    endif
endfunc " s:update_tree

func! dirbufcore#update_tree(timer) abort
    call s:update_tree()
endfunc " dirbufcore#dl_update_tree

" let g:timer = timer_start(500, function('dirbufcore#update_tree'),
"     \ {'repeat': 3})
"     " \ {'repeat': 50000/s:max_stat_count})

func! s:pathjoin(abspath, name)
    let name = (a:abspath == '/' ? '' : a:abspath) . '/' . a:name
    return name
endfunc " s:pathjoin

func! s:add(path)
    if !isdirectory(a:path) | echoerr 'not a directory -- ' expand('<sfile>') | return | endif
    let abspath = dirbufcore#abspath(a:path)
    let realpath = abspath == '/'? '/' : resolve(abspath)
    let base = abspath == '/' ? '/' : resolve(abspath) . '/'
    let d = get(g:dirs, realpath, {})
    let mtime = getftime(realpath)
    let updated = get(d,'mtime',-1) < mtime
    if empty(d) || updated
        let dl = {}
        let ndirs = 0
        let subdirs = []
        for name in readdir(realpath)
            " let dl[name] = {'isdir' : isdirectory(s:pathjoin(realpath, name))}
            let isdir = isdirectory(s:pathjoin(realpath, name))
            if isdir
                call add(subdirs, name)
                let ndirs += 1
                let name = name . '/'
            endif
            let dl[name] = {'isdir' : isdir}
        endfor
        let d['subdirs'] = subdirs
        let d['ndirs'] = ndirs
        let d['mtime'] = mtime
        let d['dl'] = dl
        let g:dirs[realpath] = d
    endif
    return [d, abspath, realpath, updated]
endfunc " s:add

func! s:new(path)
    return s:add(a:path)
    let abspath = dirbufcore#abspath(a:path)
    let realpath = abspath == '/'? '/' : resolve(abspath)
    let d = get(g:dirs, realpath, {})
    if empty(d)
        for name in readdir(realpath)
            " let d[name] = {'isdir' : isdirectory(s:pathjoin(realpath, name))}
            let isdir = isdirectory(s:pathjoin(realpath, name))
            let name = isdir ? name . '/' : name
            let d[name] = {'isdir' : isdir}
        endfor
    let g:dirs[realpath] = d
    endif
    return [d, abspath, realpath, 1]
endfunc " s:new

let s:idx_mru = 0
func! s:dh_mru(abspath)
    return
    let s:idx_mru += 1
    " echo max({})
    let d = get(g:mrudh_dirs, a:abspath, {})
    if empty(d)
        let d['hit'] = 0
        let g:mrudh_dirs[a:abspath] = d
    endif
    let d['hit'] += 1
    let d['idx'] = s:idx_mru
    let last = get(g:mrudh_dirs, 0, '///')
    if match(last, a:abspath) == 0
        let c_dirbuf = matchstr(last[:], '[^/]*', len(a:abspath)+1)
        if c_dirbuf != ''
            keeppat call search('^' . c_dirbuf . '$', 'c')
        endif
    else
        let g:mrudh_dirs[0] = a:abspath
    endif
endfunc " s:dh_mru

func! dirbufcore#dh_open(path, ...) abort
    let from = get(a:, 1, '')
    let [d, abspath, realpath, updated] = s:new(a:path)
    let dh = get(g:dh_dirs, abspath, {})
    if empty(dh)
        let nr = bufadd(abspath)
        call setbufvar(nr, '&buftype', 'nofile')
        call setbufvar(nr, '&ft', 'dirbuf')
        sil call bufload(nr)
        " call setbufvar(nr, '&buflisted', 0)
        let dh['bufnr'] = nr
        let dh['mtime'] = -1
        let g:dh_dirs[abspath] = dh
        let g:rdh_dirs[nr] = abspath
    endif
    let nr = g:dh_dirs[abspath].bufnr
    if dh.mtime < d.mtime
        let files = keys(d.dl)
        let num = len(files) + 1
        if !empty(getbufline(nr, num, num))
            call deletebufline(nr, num, '$')
        endif
        call setbufline(nr, 1, files)
    endif
    exec nr . 'b'
    " let b:dirbuf = realpath
    call s:dh_mru(abspath)
endfunc " dirbufcore#dh_open

func! dirbufcore#goparent(...) abort
    let cnt = get(a:, 1, 1)
    let base = get(a:, 2, expand('%'))
    let cnt = (cnt < 1 ? 1 : cnt) - (base == '')
    let base = dirbufcore#abspath(base)
    let path = cnt == 0 ? base : dirbufcore#simplify(base . repeat('/..', cnt))
    let g:mrudh_dirs[0] = base
    call dirbufcore#dh_open(path)
endfunc " dirbufcore#goparent

func! dirbufcore#dh_enter() abort
    let abspath = get(g:rdh_dirs, bufnr('%'), '')
    if abspath == '' | echom "dh_enter: not dirbuf buffer" | return | endif
    let name = s:pathjoin(abspath, getline('.'))
    if isdirectory(name)
        call dirbufcore#dh_open(name)
    else
        exec 'e ' . name
    endif
endfunc " dirbufcore#dh_enter

let g:dh_dirs = {}
let g:rdh_dirs = {}
let g:mrudh_dirs = {}

let g:dirs = {}

" respect symlinks, on the contrary, getcwd() don't.
let s:cwd = $PWD
func! dirbufcore#updatecwd(path) abort
" autocmd DirChanged global call dirbufcore#updatecwd(expand('<afile>'))
    let g:a = a:path
    let s:cwd = a:path[0] == '/' ? a:path : dirbufcore#simplify(s:cwd . '/' . a:path)
endfunc " dirbufcore#updatecwd

func! dirbufcore#cwd() abort
    return s:cwd
endfunc " dirbufcore#cwd

func! dirbufcore#abspath(path) abort
    return dirbufcore#simplify(a:path[0] == '/' ? a:path : dirbufcore#cwd() . '/' . a:path)
endfunc " dirbufcore#abspath

func! dirbufcore#simplify(path) abort
    let lst = []
    let absolute = (a:path[0] == '/')
    let ns = split(a:path, '/')
    for name in ns
        if name == '..'
            if !empty(lst) && lst[-1] != '..'
                call remove(lst, -1)
            elseif !(empty(lst) && absolute)
                call add(lst, '..')
            endif
        elseif name != '.' && name != ''
            call add(lst, name)
        endif
    endfor
    let path = absolute ? '/' . join(lst, '/') : join(lst, '/')
    return path == '' ? '.' : path
endfunc " dirbufcore#simplify

func! dirbufcore#parent(...) abort
    let cnt = get(a:, 1, 1)
    let base = get(a:, 2, '.')
    return dirbufcore#abspath((base == '' ? './xx' : base) . repeat('/..', (cnt < 1 ? 1 : cnt)))
    " return dirbufcore#simplify((base == '' ? './xx' : base) . repeat('/..', (cnt < 1 ? 1 : cnt)))
endfunc " dirbufcore#nparent
