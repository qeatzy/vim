if exists('g:autoloaded_dirbufcore')
    finish
endif
let g:autoloaded_dirbufcore = expand('<sfile>')
func! dirbufcore#init() abort
endfunc " dirbufcore#init

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
func! s:update_tree_old() abort
    let [realpath, tree] = s:current_tree()
    let [i, n, stat_count] = [0, len(tree), 0]
    while i < n && stat_count < s:max_stat_count
        let [d, abspath, realpath, updated] = s:add(tree[i])
        let base = realpath == '/' ? '/' : realpath . '/'
        if updated
            let stat_count += len(d.dl)
        endif
        call extend(tree, map(copy(d.dirs), 'base . v:val'))
        let i += 1
    endwhile
    if i > 0
        call remove(tree, 0, i-1)
    endif
endfunc " s:update_tree_old

func! dirbufcore#update_tree(root) abort
    " post-order traversal
    let [d, abspath, realpath, updated] = s:add(a:root)
    for dir in d['dirs']
        call dirbufcore#update_tree(realpath . '/' . dir)
    endfor
    let [d, abspath, realpath, updated] = s:add(a:root)
    return [d, abspath, realpath, updated]
endfunc " dirbufcore#update_tree
func! s:update_trees() abort
    for root in keys(g:trees)
        call dirbufcore#update_tree(root)
        echom "updated tree: " root
    endfor
endfunc " s:update_trees

func! dirbufcore#update_trees(timer) abort
    call s:update_trees()
endfunc " dirbufcore#update_trees

" let g:timer = timer_start(500, function('dirbufcore#update_trees'),
"     \ {'repeat': 3})
"     " \ {'repeat': 50000/s:max_stat_count})

func! s:pathjoin(abspath, name)
    let name = (a:abspath == '/' ? '' : a:abspath) . '/' . a:name
    return name
endfunc " s:pathjoin

fu! dirbufcore#add(path)
    return s:add(a:path)
endfu

func! s:add(path)
    if !isdirectory(a:path) | echoerr 'not a directory [' . a:path . '] -- ' expand('<sfile>') | return | endif
    let abspath = dirbufcore#abspath(a:path)
    let realpath = abspath == '/'? '/' : resolve(abspath)
    let base = abspath == '/' ? '/' : resolve(abspath) . '/'
    let d = get(g:dirs, realpath, {})
    let mtime = getftime(realpath)
    let old_mtime = get(d,'mtime',-1)
    let updated = get(d,'mtime',-1) < mtime
    if empty(d) || updated
        let current_time = localtime()
        let dl_cache = []   " dirs + files
        let dirs = []
        let files = []
        for name in readdir(realpath)
            " let dl[name] = {'isdir' : isdirectory(s:pathjoin(realpath, name))}
            let isdir = isdirectory(s:pathjoin(realpath, name))
            if isdir
                call add(dirs, name)
                let name = name . '/'
            else
                call add(files, name)
            endif
            call add(dl_cache, name)
        endfor
        let d['mtime'] = mtime
        let d['dirs'] = dirs
        let d['files'] = files
        let d['dl'] = dl_cache
        " let d['not_tree_builded'] 
        let d['tree'] = {}
        if has_key(d, 'tree_cache') | call remove(d, 'tree_cache') | endif
        " let not_tree_builded = {}   " name of subdir in either here or `tree`
        " let tree = {}   " name: tree cache of subdir, if name in tree.
        let g:dirs[realpath] = d
    endif
    if !has_key(d, 'tree_cache')
        let not_tree_builded = {}  " temporary , not used in future
        let [tree, dirs, files] = [d['tree'], d['dirs'], d['files']]
        if len(dirs) == len(tree)
            let d['tree_cache'] = files
        else
            for name in dirs
                if has_key(tree, name)
                    continue
                endif
                let path_subdir = base . name
                if getftype(path_subdir) == 'link'
                    let path_subdir = resolve(path_subdir)
                endif
                let subdir = get(g:dirs, path_subdir)
                " if subdir == 0  " E735: dict == 0
                if type(subdir) == v:t_number
                    let not_tree_builded[name] = 0      " not traversed yet
                else
                    let tree_cache = get(subdir, 'tree_cache')
                    if type(tree_cache) != v:t_number   " tree cached
                        let prefix = name . '/'
                        let tree[name] = [prefix]
                        call extend(tree[name], map(copy(tree_cache), 'prefix . v:val'))
                    elseif len(subdir['tree']) != len(subdir['dirs'])
                        let not_tree_builded[name] = 1  " traversed, but not_tree_builded
                    else
                        let not_tree_builded[name] = 2  " tree builded, not tree cached
                    endif
                endif
            endfor
            " if empty(not_tree_builded)
            if len(dirs) == len(tree)
                " choose to build tree_cache eagerly, once all subdirs built.
                " tree cached implies tree builed.
                " or better to expose a method/function to build tree_cache from
                "   tree + files only when actually get called.
                let tree_cache = copy(d['files'])
                " if !empty(dirs) | echom "tree built" len(dirs) abspath | endif
                for name in dirs
                    let tree_cache += tree[name]
                endfor
                let d['tree_cache'] = tree_cache
            endif
        endif
        " let tree_builded = current_time
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

func! s:bufadd(bufname, ...) abort
    let bufname = a:bufname
    if type(a:bufname) == v:t_number
        " use existing buffer, make sure exists.
        " notify manager to add it. or not?
    else
        " ask manager, if buffer with this name exists.
        " create if not exists.
        let dh = get(g:dh_dirs, bufname, {})
        if empty(dh)
            let nr = bufadd(bufname)
            call setbufvar(nr, '&buftype', 'nofile')
            call setbufvar(nr, '&ft', 'dirbuf')
            call setbufvar(nr, 'dirbuf', bufname)
            call setbufvar(nr, '&buflisted', 0)
            sil call bufload(nr)    " no cost, remove cause bug
            let dh['bufnr'] = nr
            let dh['mtime'] = -1
            let g:dh_dirs[bufname] = dh
            let g:rdh_dirs[nr] = bufname
        endif
    endif
    let dh = get(g:dh_dirs, bufname, {})
    return dh
endfunc " s:bufadd
func! dirbufcore#dh_add(path, ...) abort
endfunc " dirbufcore#dh_add


func! dirbufcore#opentree(path) abort
    if isdirectory(a:path)
        call dirbufcore#dh_open(a:path)
    endif
endfunc " dirbufcore#opentree


func! dirbufcore#opentree(path) abort
" from dirbufcore#dh_open
" need refactor
    let [d, abspath, realpath, updated] = dirbufcore#update_tree(a:path)
    let dh = s:bufadd(abspath)
    let nr = dh.bufnr
    if 1
    " if dh.mtime < d.mtime
        let files = d.tree_cache
        " let files = keys(d.dl)
        let num = len(files) + 1
        if !empty(getbufline(nr, num, num))
            call deletebufline(nr, num, '$')
        endif
        call setbufline(nr, 1, files)
    endif
    exec nr . 'b'
    " let b:dirbuf = realpath
    " call s:dh_mru(abspath)
endfunc " dirbufcore#opentree

func! dirbufcore#opendirectory(path) abort
    if isdirectory(a:path)
        call dirbufcore#dh_open(a:path)
    endif
endfunc " dirbufcore#opendirectory

func! dirbufcore#dh_open(path, ...) abort
    let from = get(a:, 1, '')
    let [d, abspath, realpath, updated] = s:add(a:path)
    let dh = s:bufadd(abspath)
    let nr = dh.bufnr
    if dh.mtime < d.mtime
        let files = d.dl
        " let files = keys(d.dl)
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
    " only be called if ft=dirbuf
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
