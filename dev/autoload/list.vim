func! list#remove(lst, value) abort
    let idx = index(a:lst, a:value)
    if idx != -1
        call remove(a:lst, idx)
    endif
endfunc " list#remove
