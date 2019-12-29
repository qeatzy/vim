
if !exists('s:term_nrs') | let s:term_nrs = [] | let s:term_info = {} | let s:rterm_nrs = {} | endif
func! term#nrs(...)
    return s:term_nrs
endfunc " term#nrs

func! term#all() abort
    echo s:term_nrs
endfunc " term#all

func! term#switchnr()
    if has('gui') | return term#switchnr_gui() | endif
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

" let g:lastswitch = bufnr('#') " fix for E121: Undefined variable: g:lastswitch
let g:lastswitch = 1 " fix for E121: Undefined variable: g:lastswitch
func! term#switch(nth) abort
    let nrs = term#nrs('zsh')
    if a:nth > len(nrs) | return | endif
    " echo nrs
    let g:toswitch = 0
    if a:nth > 0
        " echo nrs[a:nth - 1]
        let g:toswitch = nrs[a:nth - 1]
    elseif a:nth is# 0
        let g:toswitch = buf#nr('normal')
    elseif a:nth is# 'd'
        let g:toswitch = g:lastswitch
    elseif a:nth is# 'c'
        let g:lastswitch = bufnr('%')
        let cmd = get(g:, 'term', 'zsh')
        let opt = {}
        if exists('b:dirbuf') | call extend(opt, {'cwd': b:dirbuf}) | endif
        let nr = term_start(cmd, opt)
        " call term#add(nr, cmd)
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
                let g:toswitch = idx+1 == len(nrs) ? buf#nr('normal') : nrs[idx+1]
            endif
        elseif a:nth is# 'p'
            if &bt !=# 'terminal'
                let g:toswitch = nrs[-1]
            else
                let g:toswitch = idx == 0 ? buf#nr('normal') : nrs[idx-1]
            endif
        elseif a:nth is# 'l'
            echo idx == -1 ? 0 : printf("[%d of %d]", idx + 1, len(nrs))
        elseif a:nth is# 'x'
            if idx != -1
                bd! %
            endif
        elseif a:nth is# 'm'  " send.vim, mark as dest
            if idx == -1
                let nr = term#switchnr()
                if nr > 0 && nr <= len(nrs)
                    let b:termnr = nrs[nr-1]
                    call send#init()
                endif
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

func! term#TerminalOpen(bufnr) abort
    echom ["TerminalOpen", a:bufnr, getbufvar(a:bufnr, '&bt')]
    call add(s:term_nrs, a:bufnr)
    call list#remove(g:bufnrs, a:bufnr)   " fix, &ft not set when BufEnter, buf.vim
    call setbufvar(a:bufnr, '&ft', 'terminal')
endfunc " term#TerminalOpen

func! term#BufEnter(bufnr) abort
    " echom "term#BufEnter" a:bufnr
    set laststatus=0
endfunc " term#BufEnter

func! term#BufLeave(bufnr) abort
    " echom "term#BufLeave" a:bufnr
    set laststatus=2
endfunc " term#BufLeave

func! term#BufDelete(bufnr) abort
    " echom 'term#BufDelete' a:bufnr
    call list#remove(s:term_nrs, a:bufnr)
endfunc " term#BufDelete

