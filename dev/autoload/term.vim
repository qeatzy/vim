
if !exists('s:term_nrs') | let s:term_nrs = [] | endif
func! term#add(bufnr) abort
    " echom 'call add(s:term_nrs, a:bufnr)' a:bufnr
    call add(s:term_nrs, a:bufnr)
endfunc " term#add

func! term#all() abort
    echo s:term_nrs
endfunc " term#all

" let s:term_nrs = []
func! term#switch_to_term_buffer() abort
    if empty(s:term_nrs)
        term ++curwin zsh
    else
        exec 'b' . s:term_nrs[-1]
    endif
endfunc " term#switch_to_term_buffer
