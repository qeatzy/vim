func! git#root(path) abort
    let abspath = path#abspath(a:path)
    while len(abspath) > 1 && !isdirectory(abspath .'/.git')
        let abspath = matchstr(abspath, '^\(.*\)\ze/')
        " echo matchstr('/home/zyq3e/nnotes/dev/vim/dev/autoload/git.vim', '^\(.*\)\ze/')
    endwhile
    return abspath  " '' if not git repo
endfunc " git#root
" echo git#root(path#abspath(''))

func! git#do_files(lines, cmd) abort
    let files = []
    for line in a:lines
        call add(files, line[3:])
    endfor
    " echo 'git add ' . join(files,' ')
    let cmd = 'git '. a:cmd .' '. join(files,' ')
    let g:job = job_start(cmd, {'close_cb':'git#status'})
endfunc " git#add

func! s:receiver(lst_dest, channel, msg) abort
    call add(a:lst_dest, a:msg)
endfunc " s:receiver

func! s:setline(lst, channel) abort
    call var#setline(bufnr('%'), a:lst)
endfunc " s:setline

func! git#status(...) abort
    " let g:job = job_start('git status --porcelain', {'out_io':'buffer','out_buf':bufnr('%')})
    " let g:x = get(g:,'x',[])
    let g:x = []
    let g:job = job_start('git status --porcelain', {'out_mode':'nl','out_cb':function('s:receiver', [g:x]),'close_cb':function('s:setline',[g:x])})
endfunc " git#status
