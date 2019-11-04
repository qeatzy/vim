" .+,$s/\<dirbufcore#/path#/g
if exists('*path#init')
    finish
endif
func! path#init() abort
endfunc " path#init

" respect symlinks, on the contrary, getcwd() don't.
let s:cwd = $PWD
func! path#updatecwd(path) abort
" autocmd DirChanged global call path#updatecwd(expand('<afile>'))
    let g:a = a:path
    let s:cwd = a:path[0] == '/' ? a:path : path#simplify_abs(s:cwd . '/' . a:path)
endfunc " path#updatecwd

func! path#cwd() abort
    return s:cwd
endfunc " path#cwd

func! path#update_tree_incremental() abort
endfunc " path#update_tree_incremental

let s:batch_n_stat = 800
func! path#update_tree_timer(realpath, time) abort
    if has_key(s:, 'update_tree_timer') | echom "in progress" | return | endif
    let s:update_tree_timer = reltimefloat(reltime())
    " echo reltimefloat(reltime()) - reltimefloat(reltime())
    let stack = [a:realpath]
    let [idx, second_pass] = [0,0]
    func! Callback(timer) closure
        echom second_pass idx len(stack) timer
        let cnt = 0
        let n = len(stack)
        while idx < n
            let [d, n_stat] = path#update(stack[idx])
            let cnt += 1 + n_stat
            if !second_pass
                " call extend(stack, d['dirs'])
                let base = stack[idx] . '/'
                for dir in map(copy(d['dirs']), 'base . v:val')
                    if getftype(dir) == 'link'
                        let dir = resolve(dir)
                        if dir[0] != '/'
                            let dir = path#simplify_abs(base . dir)
                        endif
                    endif
                    call add(stack, dir)
                endfor
            endif
            let idx += 1
            if cnt > s:batch_n_stat
                return
            endif
        endwhile
        if idx == len(stack)
            if second_pass
                call timer_stop(timer)
                let msg = printf('tree [%s] updated, %3.2f seconds elapsed',
                            \ a:realpath, reltimefloat(reltime()) - s:update_tree_timer)
                echom msg
                call popup_notification(msg, {'pos':'center'})
                unlet s:update_tree_timer
            endif
            let second_pass += 1
            let idx = 0
            call reverse(stack)
        endif
    endfunc
    let time = max([a:time, 600])
    let timer = timer_start(time, funcref('Callback'), {"repeat": -1})
    " let [d, abspath, realpath, updated] = s:add(a:root)
    " call append(stack, root)
endfunc " path#update_tree

func! path#test(root, ...) abort
    let time = get(a:, 1, 1200)
    let ctime = localtime()
    let abspath = path#abspath(a:root)
    let realpath = abspath == '/' ? '/' : resolve(abspath)
    call path#update_tree_timer(realpath, time)
    " echom "update tree: " a:root "[time]: " localtime() - ctime
endfunc " path#test
func! path#update_tree(root) abort
    " post-order traversal
    let abspath = path#abspath(a:root)
    let realpath = abspath == '/' ? '/' : resolve(abspath)
    let [d, n_stat] = s:add(a:root)
    for dir in d['dirs']
        call path#update_tree(realpath . '/' . dir)
    endfor
    let [d, n_stat] = s:add(a:root)  " to build tree_cache
    return [d, n_stat]
endfunc " path#update_tree
func! s:update_trees() abort
    for root in keys(g:trees)
        for i in range(2)
            call path#update_tree(root)
            echom "updated tree: " root
        endfor
    endfor
endfunc " s:update_trees

let g:dirs = {}
let g:dirs_changed = {}
func! s:add(realpath)
    let base = a:realpath == '/' ? '/' : a:realpath . '/'
    let d = get(g:dirs, a:realpath, {})
    let mtime = getftime(a:realpath)
    let old_mtime = get(d,'mtime',-1)
    let updated = old_mtime < mtime
    let n_stat = 1
    if empty(d) || updated
        let current_time = localtime()
        let dl_cache = []   " dirs + files
        let dirs = []
        let files = []
        for name in readdir(a:realpath)
            let isdir = isdirectory(base . name)
            if isdir
                call add(dirs, name)
                let name = name . '/'
                call add(dl_cache, name)
            else
                call add(files, name)
            endif
        endfor
        call extend(dl_cache, files)
        let d['mtime'] = mtime
        let d['dirs'] = dirs
        let d['files'] = files
        let d['dl'] = dl_cache
        " let d['not_tree_builded'] 
        let d['tree'] = {}
        " if has_key(d, 'tree_cache') | call remove(d, 'tree_cache') | endif
        " let not_tree_builded = {}   " name of subdir in either here or `tree`
        " let tree = {}   " name: tree cache of subdir, if name in tree.
        let g:dirs[a:realpath] = d
        let n_stat += len(dl_cache)
    endif
    if !has_key(d, 'tree_cache')
        let not_tree_builded = {}  " temporary , not used in future
        let [tree, dirs, files] = [d['tree'], d['dirs'], d['files']]
        " let [tree, dirs, files] = [get(d,'tree',{}), d['dirs'], d['files']]
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
                if type(subdir) == v:t_number  " get() return 0
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
    return [d, n_stat]
endfunc " s:add

func! path#get(realpath) abort
    let d = get(g:dirs, a:realpath)
    if type(d) == v:t_number
        let [d, n_stat] = s:add(a:realpath)
    endif
    return d
endfunc " path#get

func! path#upget(realpath) abort
    return s:add(a:realpath)[0]
endfunc " path#get

func! path#update(realpath) abort
    return s:add(a:realpath)
endfunc " path#get

    " if !isdirectory(a:path) | echoerr 'not a directory [' . a:path . '] -- ' expand('<sfile>') | return | endif
    " let abspath = path#abspath(a:path)
    " let realpath = abspath == '/'? '/' : resolve(abspath)
    " return [d, abspath, realpath, updated]

func! path#abspath(path) abort
    return path#simplify_abs(a:path[0] == '/' ? a:path : path#cwd() . '/' . a:path)
endfunc " path#abspath

func! path#simplify_abs(abspath) abort
    " echo substitute('/./..//33//', '/\.\?\%(/\|$\)\@=','','g')
    if a:abspath ==# '/' | return a:abspath | endif
    let abspath = substitute(a:abspath, '/\.\?\%(/\|$\)\@=','','g')
    " echo ('/./..//33//' =~# '/\.\.\%(/\|$\)\@=')
    " let start = match('/./..//33//', '/\.\.\%(/\|$\)\@=')
    " if start != -1    " not worth, since after first .., many may follow, prefix lose
    if abspath =~# '/\.\.\%(/\|$\)\@='
        let lst = []
        let ns = split(abspath, '/')
        for name in ns
            if name == '..'
                if !empty(lst)
                    call remove(lst, -1)
                else
                    " call add(lst, '..')  " not needed, args are abspath, /.. is /
                endif
            else
                call add(lst, name)
            endif
        endfor
        let abspath = '/' . join(lst, '/')
    endif
    return abspath
endfunc " path#simplify

" func! path#abspath(path) abort
"     return path#simplify(a:path[0] == '/' ? a:path : path#cwd() . '/' . a:path)
" endfunc " path#abspath
"
" func! path#simplify(path) abort
"     let lst = []
"     let absolute = (a:path[0] == '/')
"     let ns = split(a:path, '/')
"     for name in ns
"         if name == '..'
"             if !empty(lst) && lst[-1] != '..'
"                 call remove(lst, -1)
"             elseif !(empty(lst) && absolute)
"                 call add(lst, '..')
"             endif
"         elseif name != '.' && name != ''
"             call add(lst, name)
"         endif
"     endfor
"     let path = absolute ? '/' . join(lst, '/') : join(lst, '/')
"     return path == '' ? '.' : path
" endfunc " path#simplify
"
