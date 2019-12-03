if !exists('g:ndirs') | let g:ndirs = {} | endif
func! s:add(realpath) abort
    let d = get(g:ndirs, a:realpath)
    if d is# 0 | let d = {'mtime': -1, 'realpath': a:realpath, 'base': a:realpath == '/' ? '/' : a:realpath . '/'} | let g:ndirs[a:realpath] = d | endif
    let mtime = getftime(a:realpath)
    if mtime > d.mtime
        let base = d.base
        let dirs = []
        let files = []
        let df = []     " dirs + files, dirs append '/'
        let links = []
        for name in readdir(a:realpath)
            let abspath = base . name
            if isdirectory(abspath)
                call add(dirs, name)
                call add(links, getftype(abspath) ==# 'link' ? resolve(abspath) : 0)
                call add(df, name . '/')
            else
                call add(files, name)
            endif
        endfor
        call extend(df, files)
        let d['mtime'] = mtime
        let d['dirs'] = dirs
        let d['files'] = files
        let d['df'] = df
        let d['links'] = links
    endif
    let d['atime'] = localtime()
    return d
endfunc
" call s:add(resolve(path#abspath('.')))
" echo g:ndirs

func! path#upget(realpath) abort
    return s:add(a:realpath)
endfunc " path#get

func! path#abspath(path) abort
    return path#simplify_abs(a:path[0] ==# '/' ? a:path : path#cwd() . '/' . a:path)
endfunc " path#abspath

func! path#realpath(abspath) abort
    return a:abspath ==# '/' ? '/' : resolve(a:abspath)
endfunc " path#realpath

func! path#simplify_abs(abspath) abort
    if a:abspath =~# '\%(/\|^\)\.\.\%(/\|$\)' " has /../
        let lst = []
        let ns = split(a:abspath, '/')
        for name in ns
            if name ==# '..'
                if !empty(lst)
                    call remove(lst, -1)
                endif
            elseif name !=# '.'
                call add(lst, name)
            endif
        endfor
        return '/' . join(lst, '/')
    else
        " revome '//' and '/./' and trailing '/'
        let abspath = substitute(a:abspath, '\%(/\|^\)\.\?\%(/\|$\)\@=', '', 'g')
        return abspath !=# '' ? abspath : '/'
    endif
endfunc " path#simplify

func! path#convertpath(abspath, mode)    " convert to windows style
    let abspath = resolve(a:abspath)
    if abspath[11] ==# '/' && abspath[:9] ==# '/cygdrive/'
        if a:mode is# 'dos'
            return abspath[10] . ':' . abspath[11:]
        elseif a:mode is# 'uri'
            return 'file:///' . abspath[10] . ':' . abspath[11:]
        endif
    endif
    return a:abspath
endfunc " path#convertpath

" respect symlinks, on the contrary, getcwd() don't.
let s:cwd = $PWD
let g:cwd = get(g:, 'cwd', [$PWD])
func! path#updatecwd(path) abort
" autocmd DirChanged global call path#updatecwd(expand('<afile>'))
" h win_execute|" do not trigger autocmd
    call add(g:cwd, a:path)
    let g:a = a:path
    let s:cwd = a:path[0] == '/' ? a:path : path#simplify_abs(s:cwd . '/' . a:path)
endfunc " path#updatecwd

func! path#tree(path)
    let abspath = path#abspath(a:path)
    let realpath = abspath == '/' ? '/' : resolve(abspath)
    let stack = [realpath]
    let dstack = []
    let ftree = {realpath: 1}
    let g:d1=[]
    while !empty(stack)
        let d = path#upget(remove(stack,-1))
        call add(g:d1,d.realpath)
        call add(dstack, d)
        let [base, dirs, links] = [d.base, d.dirs, d.links]
        for i in range(len(dirs))
            let islink = links[i] isnot# 0
            let realpath = islink ? links[i] : base . dirs[i]
            if !islink
                call add(stack, realpath)
            endif
            " let tflag = get(ftree, realpath)
            " if tflag == 0
            "     call add(stack, realpath)
            " endif
            " let ftree[realpath] = tflag + islink+1 " bitwise or, but only 1 non-link, thus tflag - (tflag & 1) // 2 == count of links
        endfor
    endwhile
    let dtree = {}  " those being linked >=2 times in tree traversal, only links, no non-link, i.e., tflag > 2 && (tflag & 1 == 0)
    let g:d2 = reverse(copy(dstack))
    for d in reverse(dstack)
        let dirs = d.dirs
        if len(dirs) == 0
            let d['tree'] = d.files
            continue
        endif
        let links = d.links
        let tree = copy(d.files)
        let base = d.base
        for i in range(len(dirs))
            let islink = links[i] isnot# 0
            let realpath = islink ? links[i] : base . dirs[i]
            let tflag = get(ftree, realpath)
            let name = dirs[i] . '/'
            call add(tree, name)
            if !islink
                try
                let subtree = map(copy(g:ndirs[realpath].tree), 'name . v:val')
                catch  /E716/
                    echo name realpath d.realpath
                    debug echo 33
                endtry
                call extend(tree, subtree)
            endif
            " if tflag <= 2
            "     let build = 1
            " else
            "     if and(tflag, 1)
            "         if !islink
            "             let build = 1
            "         endif
            "     else
            "         if get(dtree, realpath) is# 0
            "             let build = 1
            "             dtree[realpath] = 1
            "         endif
            "     endif
            " endif
            " if build
            "     let name = dirs[i] . '/'
            "     try
            "     let subtree = map(copy(g:ndirs[realpath].tree), 'name . v:val')
            "     catch  /E716/
            "         debug echo 33
            "     endtry
            "     call add(tree, name)
            "     call extend(tree, subtree)
            " endif
        endfor
        let d['tree'] = tree
    endfor
    return tree
endfunc " path#tree

func! path#cwd() abort
    return s:cwd
endfunc " path#cwd

func! s:size(x)
    if a:x < 1024
        return a:x
    elseif a:x < 1048576
        return printf('%.1fK', a:x / 1024.0)
    elseif a:x < 1073741824
        return printf('%.1fM', a:x / 1048576.0)
    elseif a:x < 1099511627776
        return printf('%.1fG', a:x / 1073741824.0)
    endif
    return a:x
endfunc " s:size

func! path#info(...) abort
    let path = b:dirbuf . '/' .getline('.')
    let size = getfsize(path)
    let time =  getftime(path)
    echo s:size(size) strftime('%Y-%m-%d %H-%M-%S', time)
endfunc " path#info
  " r!ls --help
  " -S                         sort by file size, largest first
  " -t                         sort by modification time, newest first
  "     --time-style=STYLE     with -l, show times using style STYLE:
  "                              full-iso, long-iso, iso, locale, or +FORMAT;
  "                              FORMAT is interpreted like in 'date'; if FORMAT
  "                              is FORMAT1<newline>FORMAT2, then FORMAT1 applies
  "                              to non-recent files and FORMAT2 to recent files;
  "                              if STYLE is prefixed with 'posix-', STYLE
  "                              takes effect only outside the POSIX locale
    " A timestamp is considered to be recent if it is less than six months old.
    " https://unix.stackexchange.com/questions/237531/why-does-ls-all-show-time-for-some-files-but-only-year-for-others

func! s:cmp(l1,l2) abort
    let a = a:l1[0]
    let b = a:l2[0]
    return (a>b) - (a<b)
endfunc " s:cmp
let s:Cmp = function('s:cmp')

func! path#gs(d)
    let base = a:d.base
    let files = sort(map(copy(a:d.df), '[getfsize(base . v:val), v:val]'), s:Cmp)
    let files = reverse(map(files, 'v:val[1]'))
    return files
endfunc " path#gs

func! path#gd(d)
    let base = a:d.base
    let files = sort(map(copy(a:d.df), '[getftime(base . v:val), v:val]'), s:Cmp)
    let files = reverse(map(files, 'v:val[1]'))
    return files
    " let files = sort(map(copy(a:d.df), {i,v -> [getftime(base . v),v]))
    let files = a:d.df
    let time = getftime(base . files[0])
    let files = map(copy(files), {i,v -> [getftime(base . v),v]})
    let files = sort(files)
    let files = reverse(map(files, 'v:val[1]'))
    return files
    " echo sort([[1,'a'],[0,'b']])
    " h sort(
    " echo getftime($PWD. '/dev')
endfunc " path#gd
