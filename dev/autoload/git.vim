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

func! s:setline(lst, channel) abort dict
    call var#setline(self.nr, s:sortfns(a:lst))
    if bufnr('%') != self.nr
        exec 'b '. self.nr
        if &ft !=# 'git' | set ft=git | endif
    endif
endfunc " s:setline

func! git#status(...) abort dict
    " let g:job = job_start('git status --porcelain', {'out_io':'buffer','out_buf':bufnr('%')})
    " let g:x = get(g:,'x',[])
    let g:x = []
    let g:job = job_start('git status --porcelain', {'cwd':self.root,'out_mode':'nl','out_cb':function('s:receiver', [g:x]),'close_cb':function(self.setline,[g:x])})
endfunc " git#status

let s:d = {'status': function('git#status'),
    \ 'setline': function('s:setline'),
    \ 'add': function('git#do_files',['add']),
    \ 'reset': function('git#do_files',['reset']),
    \}

let s:roots = get(s:, 'roots', {})
func! s:add(realpath) abort
    let d = get(s:roots, a:realpath)
    if d is# 0
        let nr = buf#addscratch('')
        call setbufvar(nr, '&path', a:realpath .','. getbufvar(nr,'&path'))
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
