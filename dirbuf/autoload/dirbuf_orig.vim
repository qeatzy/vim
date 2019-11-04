let g:dirs = {'_dirs' : {}}

func! g:dirs.list() dict
    echo keys(self._dirs)
endfunc

func! g:dirs.add(path) dict
        let realpath = dirbuf#resolve(a:path)
        if !has_key(self._dirs, realpath)
            let files = readdir(realpath)
            let g:dirs._dirs[realpath] = {'realpath': realpath, 'files': files }
        endif
        return realpath
    " echo resolve('./autoload/../plugin/../../main/../..')
    " echo resolve(expand('./autoload/../plugin/../../main/../..'))
    " echo expand(resolve('./autoload/../plugin/../../main/../..'))
    " echo resolve(fnamemodify('./autoload/../plugin/../../main/../..', ':p'))
    " echo fnamemodify(resolve('./autoload/../plugin/../../main/../..'), ':p')
endfunc " add

func! g:dirs.open(path) dict abort
    let realpath = g:dirs.add(a:path)
    if !get(g:dirs._dirs[realpath], 'bufnr', 0)
        let nr = bufadd(realpath)
        call setbufvar(nr, '&buftype', 'nofile')
        call setbufvar(nr, '&ft', 'dirbuf')
        sil call bufload(nr)
        " call setbufvar(nr, '&buflisted', 0)
    let g:dirs._dirs[realpath]['bufnr'] = nr
    endif
    let nr = g:dirs._dirs[realpath]['bufnr']
    let files = g:dirs._dirs[realpath]['files']
    let num = len(files) + 1
    if !empty(getbufline(nr, num, num))
        call deletebufline(nr, num, '$')
    endif
    call setbufline(nr, 1, files)
    exec nr . 'b'
    let b:dirbuf = realpath
endfunc " open

func! g:dirs.bufnr(path) dict
    let realpath = a:path
    let d = get(self._dirs, realpath, {})
    let nr = get(d, 'bufnr', 0)
    return nr
endfunc " bufnr
" let g:dirs.bufnr = function('s:bufnr')

" call g:dirs.list()

" for path in ['/home/zyq3e/notes/..', '/home/zyq3e/notes/../..', '/home/zyq3e/notes/../../..', ]
" echo resolve(fnamemodify(path, ':p'))
" endfor

func! dirbuf#resolve(path) abort
    return a:path == '/' ? '/' : resolve(fnamemodify(a:path, ':p'))
endfunc " dirbuf#resolve

" vim resolve symlink by default, eg, getcwd() fnamemodify()
" no builtin way to retain tree structure wrt symlink
" echo simplify('/home/zyq3e/notes/../..') 
" echo fnamemodify('/home/zyq3e/notes/../..', ':p') 
" echo resolve('/home/zyq3e/notes/../..') 
" echo resolve('..') 
func! dirbuf#simplify(path) abort
    let lst = []
    " echo remove(lst,-1)
    " echo split('/path/to', '/', 1)
    " echo split('/path/to', '/', 0)
    let absolute = (a:path[0] == '/')
    let ns = split(a:path, '/')
    for name in ns
        if name == '..'
            if !empty(lst) && lst[-1] != '..'
                call remove(lst, -1)
            else
                call add(lst, '..')
            endif
        elseif name != '.' && name != ''
            call add(lst, name)
        endif
    endfor
    return absolute ? '/' . join(lst, '/') : join(lst, '/')
    " echo split('/home/zyq3e/notes/..', '/',1)
endfunc " dirbuf#simplify

func! dirbuf#bufcreate(name) abort
    let nr = bufadd(a:name)
    call setbufvar(nr, '&buftype', 'nofile')
    call setbufvar(nr, '&ft', 'dirbuf')
    sil call bufload(nr)
    " echo getbufvar(2, '&buftype')
    " call setbufvar(nr, '&buflisted', 0)
    return nr
endfunc " dirbuf#bufcreate

func! dirbuf#open(path) abort
    call g:dirs.open(a:path)
endfunc " dirbuf#open

func! dirbuf#enter() abort
    if exists('b:dirbuf')
        let name = (b:dirbuf == '/' ? '' : b:dirbuf) . '/' . getline('.')
        let nr = g:dirs.bufnr(name)
        if nr
            exec nr . 'b'
        else
            if isdirectory(name)
                call dirbuf#open(name)
            else
                exec 'e ' . name
            endif
        endif
    endif
endfunc " dirbuf#enter

func! dirbuf#pwd(cnt) abort
    let name = bufname('%')
    let c_dirbuf = substitute(name, '.*/', '','')
    if name != ''
        let prefix = dirbuf#simplify(name . repeat('/..', a:cnt))
        let path = prefix[0] == '/' ? prefix : './' . prefix
    else
        let path = '.'
    endif
    let realpath = dirbuf#open(path)
    if c_dirbuf  != ''
        keeppat call search('^' . c_dirbuf . '$', 'c')
    endif
    " let nr = dirbuf#bufcreate(path)
    " if prefix == '' || prefix == '.'
    "     let prefix = getcwd()
    " endif
    " echo fnamemodify('.',':h')
    " " let prefix = expand('%')
    " " let prefix = isdirectory(prefix) ? fnamemodify(prefix, ':h')  expand('%:p:h')
    " " echo expand('%:p:h')
    " let path = prefix . '/' . join(repeat(['..'], a:cnt-1), '/')
    " echo path
endfunc " dirbuf#pwd

" bwipe vv
" echo bufadd('vv')
"  echo setbufline('vv', 1, ["123"])
" echo bufnr('vv')
" echo bufname('vv')
" echo buflisted('vv')
" echo bufloaded('vv')
" call setbufvar(bufnr('vv'), "&buftype", "nofile")
" call setbufvar(bufnr('vv'), "&buflisted", 1)
