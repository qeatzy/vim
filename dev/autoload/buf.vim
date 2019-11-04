
let g:scratch = get(g:, 'scratch', [])
let s:idx = -1
func! buf#addscratch(...) abort
    let name = get(a:, 1, '')
    let nr = bufadd(name)
    call setbufvar(nr, '&buftype', 'nofile')    " imply nobuflisted
    call setbufvar(nr, '&bufhidden', 'hide')
    call setbufvar(nr, '&swapfile', 0)
    call bufload(nr)     " no cost, removal cause bug, first setline been overridden
    return nr
endfunc
func! Scratch()
    let nr = buf#addscratch()
    exec nr . 'b'
    return nr
endfunc

func! buf#nextscratch() abort
    if len(g:scratch) < 10
        call add(g:scratch, buf#addscratch())
    endif
    let s:idx += 1
    if s:idx >= len(g:scratch) | let s:idx = -1 | endif
    return g:scratch[s:idx]
endfunc


func! buf#setline(bufnr, lines) abort
    let num = len(a:lines) + 1
    if !empty(getbufline(a:bufnr, num, num))
        call deletebufline(a:bufnr, num, '$')
    endif
    call setbufline(a:bufnr, 1, a:lines)
endfunc
