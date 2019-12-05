func! git#root(abspath) abort
    let abspath = a:abspath
    while len(abspath) > 1 && !isdirectory(abspath .'/.git')
        let abspath = matchstr(abspath, '^\(.*\)\ze/')
        " echo matchstr('/home/zyq3e/nnotes/dev/vim/dev/autoload/git.vim', '^\(.*\)\ze/')
    endwhile
    return abspath  " '' if not git repo
endfunc " git#root
" echo git#root(path#abspath(''))

func! git#do_files(cmd, lines) abort dict
    let files = []
    for line in a:lines
        call add(files, line[3:])
    endfor
    " echo 'git add ' . join(files,' ')
    let cmd = 'git '. a:cmd .' '. join(files,' ')
    let g:job = job_start(cmd, {'cwd':self.root, 'close_cb':self.status})
endfunc " git#add

func! s:receiver(lst_dest, channel, msg) abort
    call add(a:lst_dest, a:msg)
endfunc " s:receiver

func! s:sortfns(lst) abort
    return a:lst
endfunc " s:sortfns

func! s:setline(args, channel) abort
    let [lst, bufnr] = a:args[:1]
    let lst = get(a:args,2) isnot 0 ? call(a:args[2], [lst]) : lst
    call var#setline(bufnr, lst)
    if bufnr('%') != bufnr
        exec 'b '. bufnr
        if &ft !=# b:gitft | let &ft = b:gitft | endif
    endif
    if get(a:args,3) isnot 0 | call call(a:args[3],[]) | endif
endfunc " s:setline

func! git#status(...) abort dict
    " let g:job = job_start('git status --porcelain', {'out_io':'buffer','out_buf':bufnr('%')})
    let lst = []
    let g:job = job_start('git status --porcelain', {'cwd':self.root,'out_mode':'nl','out_cb':function('s:receiver', [lst]),'close_cb':function('s:setline',[[lst,self.nr]])})
endfunc " git#status

let s:COMMIT_HEADER = ["",""]
func! s:prepare_commit(lst) abort
    let lst = map(a:lst, 'substitute(v:val,"^","# ","")')
    return s:COMMIT_HEADER + lst
endfunc " s:prepare_commit

func! git#commit_commit(...) abort dict
    let nr = get(self, 'nr_commit')
    if getbufvar(nr, '&ft') isnot# 'gitcommit' || getbufvar(nr, '&mod') | return 1 | endif
    let lines = getbufline(nr, 1, '$')
    let lines = filter(lines, {k,v -> v =~# '^\s*[^#]'})
    if empty(lines)
        echom "commit canceled, due to empty message"
        return 1
    endif
    let cmd = 'git commit --cleanup strip -F '. get(a:,1,'') .' '. s:COMMIT_EDITMSG
    let g:job = job_start(cmd, {'cwd':self.root,'close_cb':{x -> execute('echo "commited"')}})
endfunc " git#commit_commit

let s:COMMIT_EDITMSG = '.git/COMMIT_EDITMSG'
func! git#commit_prepare() abort dict
    let nr = bufadd(self.root .'/'. s:COMMIT_EDITMSG)
    let self.nr_commit = nr
    call bufload(nr)
    call setbufvar(nr, 'gitft', 'gitcommit')
    call setbufvar(nr, 'git', self)
    let lst = []
    let cmd = 'git commit --dry-run '
    let g:job = job_start(cmd, {'cwd':self.root,'out_mode':'nl','out_cb':function('s:receiver', [lst]),'close_cb':function('s:setline',[[lst,nr,'s:prepare_commit',{->execute('w')}]])})
endfunc " git#commit_prepare

let s:d = {'status': function('git#status'),
    \ 'setline': function('s:setline'),
    \ 'add': function('git#do_files',['add']),
    \ 'reset': function('git#do_files',['reset']),
    \ 'commit': function('git#commit_prepare'),
    \ 'commit_commit': function('git#commit_commit'),
    \}

let s:roots = get(s:, 'roots', {})
func! s:add(realpath) abort
    let d = get(s:roots, a:realpath)
    if d is# 0
        let nr = buf#addscratch('')
        call setbufvar(nr, '&path', a:realpath .','. getbufvar(nr,'&path'))
        call setbufvar(nr, 'gitft', 'git')
        let d = extend(copy(s:d), {'nr': nr,'root': a:realpath})
        let s:roots[a:realpath] = d
        call setbufvar(nr, 'git', d)
    endif
    return d
endfunc " s:add
func! git#init(...) abort
    let abspath = a:0 ? path#abspath(a:path) : expand('%:p:h')
    let root = git#root(abspath)
    if root is# '' | echom "not a git repo" | return 1 | endif
    let realpath = path#realpath(root)
    return s:add(realpath)
endfunc " git#init
com! G call git#init().status()

finish
git commit
1. read input from `git commit --dry-run`
2. edit
3. write to `git commit -F -` or `git commit .git/COMMIT_EDITMSG`
4.  -- use strip mode. (default is strip if edit else whitespace)
