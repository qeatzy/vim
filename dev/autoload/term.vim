
if !exists('s:term_nrs') | let s:term_nrs = {} | let s:rterm_nrs = {} | endif
func! term#nrs(cmd)
    let nrs = get(s:term_nrs, a:cmd)
    if nrs is# 0
        let nrs = []
        let s:term_nrs[a:cmd] = nrs
    endif
    return nrs
endfunc " term#nrs

func! s:parse_pid(msg) " return value of term_getjob(), all arg1 of job-exit_cb
    return matchstr(a:msg, '^\%(process \)\zs\d\+')
endfunc " s:parse_pid

if !exists('s:term_pids') | let s:term_pids = {} | endif
func! term#pid_add(bufnr, pid)
    let s:term_pids[a:pid] = a:bufnr
endfunc " term#pid_add
func! term#pid2bufnr(pid)
    return s:term_pids[a:pid]
endfunc " term#pid2bufnr
func! s:Cb_exit_cb(job, exit_code)
    let pid = s:parse_pid(a:job)
    let bufnr = term#pid2bufnr(pid)
    call term#remove(bufnr)
    let g:ee = get(g:,'ee',[])
    call add(g:ee, [a:job,a:exit_code])
endfunc " EE

func! term#add(bufnr, afile) abort
    echom "term#add(" . a:bufnr . ", " . a:afile . ")"
    let cmd = matchstr(matchstr(a:afile, '\%(\%(.*[\/]\|^\)!\?\)\zs.\{-1,}\%(\%( (\d\+)\)\|$\)\@='), '\%(.*[\/]\|^\)\zs.\{-1,}\%(\%(.exe\)\|$\)\@=')
    let nrs = term#nrs(cmd)
    let bufnr = str2nr(a:bufnr)
    call add(nrs, bufnr)
    let s:rterm_nrs[bufnr] = nrs
    let pid = s:parse_pid(term_getjob(bufnr))
    call term#pid_add(bufnr, pid)
    " let g:s = a:afile
    " let cmd = substitute(a:afile, ' \%((\d\+)\)\?$', '','')[1:]
    " echom 'call add(s:term_nrs, a:bufnr)' a:bufnr
    " let s='E:\cygwin64\bin\zsh.exe'
    " let s='zsh.exe (1)'
    " echo s
    " echo matchstr(s, '\%\(.*[\/]\|^\)\zs.*')
    " echo matchstr(s, '\%(.*[\/]\|^\)\zs.\{-\}\%(\%(\.exe\) [()0-9]\+\)\@=')
    " trim ' (1)', then trim '.exe'
endfunc " term#add

func! term#all() abort
    echo s:term_nrs
endfunc " term#all

func! term#remove(bufnr, ...)
    let nrs = get(s:rterm_nrs, a:bufnr)
    if nrs is# 0 | return | endif
    call remove(s:rterm_nrs, a:bufnr)
    let idx = index(nrs, a:bufnr)
    if idx >= 0
        if a:0
            exec remove(nrs, idx) . 'bw!'
        else
            call remove(nrs, idx)
        endif
    endif
endfunc " term#remove

" let s:term_nrs = []
func! term#switch_to_term_buffer(...) abort
    let code = get(a:, 1)
    let cmd = get(a:, 2, 'zsh')
    let nrs = term#nrs(cmd)
    " let action = term#action(get(a:, 1))
    if code is# 0
        if empty(nrs)
            exec 'term ++curwin ' . cmd
            " call term#add(bufnr('%'), bufname('%'))
        else
            try
                " exec 'b' . nrs[-1]
                call term#switch(1)
            catch /E86/  " Buffer does not exist
                " call remove(nrs, -1)
                call term#remove(nrs[-1])
                call term#switch_to_term_buffer(0)
                " term ++curwin zsh
            endtry
        endif
    elseif code is# 1
        exec 'term ++curwin ' . cmd
        " call term#add(bufnr('%'), bufname('%'))
    elseif code is# 2
        exec 'bw! ' . nrs[-1]
        " call remove(nrs, -1)
        call term#remove(nrs[-1])
        " so %
    elseif code is# 8
        " h confirm(
        call add(nrs, remove(nrs, 0))
        call term#all()
    elseif code is# 9
        call term#all()
    elseif code is# 'cycle'     " only call from terminal buffer
        let idx = index(nrs, bufnr('%'))
        " exec 'b ' . (idx + 1 == len(nrs) ? get(g:, 'lastbufnr', '#') : nrs[idx+1])
        exec 'b ' . (idx == 0 ? get(g:, 'lastbufnr', '#') : nrs[idx-1])
    endif
endfunc " term#switch_to_term_buffer

func! term#bufnr(cmd)
    let nrs = term#nrs(a:cmd)
    if empty(nrs)
        1sp
        call term#switch_to_term_buffer(0, a:cmd)
        hide
    endif
    return nrs[-1]
endfunc " term#create

func! term#switchnr()
let c = getchar()
if c >= 48 && c <= 57
    return c - 48
else
    if c == 27  " <Esc>, on terminal, <M-x> is <Esc>x
        let c = getchar(0)
    endif
    return nr2char(c)
    " return c >= 48 && c <= 57 ? c - 48 : nr2char(c)  " <M-0> is not possible
endif
endfunc " term#switchnr

func! term#switchnr_gui()
let c = getchar()
if c >= 48 && c <= 57
    return c - 48
else
    if c >= 176 && c <= 185      " 176,185, <M-0> <M-9>
        return c - 176
    elseif c >= 225 && c <= 250  " 225,250 <M-a> <M-z>
        let c -= 128
    endif
    return nr2char(c)
    " return c >= 48 && c <= 57 ? c - 48 : nr2char(c)  " <M-0> is not possible
endif
endfunc " term#switchnr_gui

func! term#switch(nth) abort
    let nrs = term#nrs('zsh')
    if a:nth > len(nrs) | return | endif
    " echo nrs
    let g:toswitch = 0
    if a:nth > 0
        " echo nrs[a:nth - 1]
        let g:toswitch = nrs[a:nth - 1]
    elseif a:nth is# 0
        let g:toswitch = g:lastbufnr
    elseif a:nth is# 'd'
        let g:toswitch = g:lastswitch
    elseif a:nth is# 'c'
        let g:lastswitch = bufnr('%')
        let cmd = get(g:, 'term', 'zsh')
        let opt = {'exit_cb':function('s:Cb_exit_cb')}
        if exists('b:dirbuf') | call extend(opt, {'cwd': b:dirbuf}) | endif
        let nr = term_start(cmd, opt)
        call term#add(nr, cmd)
        let g:toswitch = -1
    elseif a:nth is# 'q'
        call buf#close_if_term_window()
    elseif a:nth is# 's'
        sbuffer #
        winc p
    else
        let idx = index(nrs, bufnr('%'))
        if a:nth is# 'n'
            if &bt !=# 'terminal'
                let g:toswitch = nrs[0]
            else
                let g:toswitch = idx+1 == len(nrs) ? g:lastbufnr : nrs[idx+1]
            endif
        elseif a:nth is# 'p'
            if &bt !=# 'terminal'
                let g:toswitch = nrs[-1]
            else
                let g:toswitch = idx == 0 ? g:lastbufnr : nrs[idx-1]
            endif
        elseif a:nth is# 'l'
            echo idx == -1 ? 0 : printf("[%d of %d]", idx + 1, len(nrs))
        elseif a:nth is# 'x'
            if idx != -1
                bd! %
            endif
        endif
    endif
    if g:toswitch > 0
        " if a:nth is# 'd'
            let nr = bufnr('%')
            let g:lastswitch = nr
        exec 'b ' g:toswitch
    endif
    if g:toswitch
        call term#switch('l')
    endif
endfunc " term#switch


" arglist : [ cwd ]
" change window local working directory
" https://vi.stackexchange.com/questions/21798/how-to-change-local-directory-of-terminal-buffer-whenever-its-shell-change-direc
function! Tapi_lcd(bufnum, arglist)
  let winid = bufwinid(a:bufnum)
  let cwd = get(a:arglist, 0, '')
  if winid == -1 || empty(cwd)
    return
  endif
  " call win_execute(winid, 'lcd ' . cwd)     " do not trigger autocmd
  " call path#updatecwd(cwd)
  exec 'cd ' . cwd
endfunction

" h terminal-api
" 	<Esc>]51;["drop", "README.md"]<07>
" The <Esc>]51;msg<07> sequence is reserved by xterm for "Emacs shell", which is
func! Tapi_openfile(bufnr, args) abort
    " args: filename, lineno or pattern
    let args = type(a:args) == 3 ? a:args : [a:args]
    let g:x = args
    let len = len(args)
    if len > 0
        let nr = bufadd(args[0])
        if !bufloaded(nr) | call bufload(nr) | endif
        call setbufvar(nr, '&buflisted', 1)
        let lineno = get(args, 1)
        if lineno > 0
            exec 'b ' . nr
            exec lineno + 0
            " b #
            exec 'b ' . a:bufnr
        endif
        let g:nr = nr
    endif
endfunc " Tapi_openfile
    " echo "\033]51;[call, Tapi_openfile, [55]]\007"
