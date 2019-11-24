
if !exists('s:term_nrs') | let s:term_nrs = {} | let s:rterm_nrs = {} | endif
func! s:nrs(cmd)
    let nrs = get(s:term_nrs, a:cmd)
    if nrs is# 0
        let nrs = []
        let s:term_nrs[a:cmd] = nrs
    endif
    return nrs
endfunc " s:nrs

func! term#add(bufnr, afile) abort
    echom "term#add(" . a:bufnr . ", " . a:afile . ")"
    let g:s = a:afile
    " echom 'call add(s:term_nrs, a:bufnr)' a:bufnr
    let cmd = substitute(a:afile, ' \%((\d\+)\)\?$', '','')[1:]
    let nrs = s:nrs(cmd)
    let bufnr = str2nr(a:bufnr)
    call add(nrs, bufnr)
    let s:rterm_nrs[bufnr] = nrs
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
    let nrs = s:nrs(cmd)
    " let action = term#action(get(a:, 1))
    if code is# 0
        if empty(nrs)
            exec 'term ++curwin ' . cmd
            call term#add(bufnr('%'), bufname('%'))
        else
            try
                exec 'b' . nrs[-1]
            catch /E86/  " Buffer does not exist
                " call remove(nrs, -1)
                call term#remove(nrs[-1])
                call term#switch_to_term_buffer(0)
                " term ++curwin zsh
            endtry
        endif
    elseif code is# 1
        exec 'term ++curwin ' . cmd
        call term#add(bufnr('%'), bufname('%'))
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
    endif
endfunc " term#switch_to_term_buffer

func! term#bufnr(cmd)
    let nrs = s:nrs(a:cmd)
    if empty(nrs)
        1sp
        call term#switch_to_term_buffer(0, a:cmd)
        hide
    endif
    return nrs[-1]
endfunc " term#create

" arglist : [ cwd ]
" change window local working directory
" https://vi.stackexchange.com/questions/21798/how-to-change-local-directory-of-terminal-buffer-whenever-its-shell-change-direc
function! Tapi_lcd(bufnum, arglist)
  let winid = bufwinid(a:bufnum)
  let cwd = get(a:arglist, 0, '')
  if winid == -1 || empty(cwd)
    return
  endif
  call win_execute(winid, 'lcd ' . cwd)
endfunction
