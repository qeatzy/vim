
let g:bufnrs = get(g:, 'bufnrs', [])
func! buf#enter(bufnr, ...) abort
    let type = a:0 ? a:1 : getbufvar(a:bufnr, '&ft')
    " echom [a:bufnr, type, term_getjob(a:bufnr), 'buf#enter']
    " if &bt ==# 'terminal' # set after called
    " if term_getjob(a:bufnr) != v:null
    if type ==# 'terminal'
        call term#BufEnter(a:bufnr)
    elseif type ==# 'dirbuf'
    else
        call list#remove(g:bufnrs, a:bufnr)
        call add(g:bufnrs, a:bufnr)
    endif
endfunc " buf#enter

func! buf#leave(bufnr, ...) abort
    let type = a:0 ? a:1 : getbufvar(a:bufnr, '&ft')
    if type ==# 'terminal'
        call term#BufLeave(a:bufnr)
    elseif type ==# 'dirbuf'
    else
    endif
endfunc " buf#leave

func! buf#delete(bufnr, ...) abort
    let type = a:0 ? a:1 : getbufvar(a:bufnr, '&ft')
    " echom [a:bufnr, type, term_getjob(a:bufnr), 'buf#delete']
    if type ==# 'terminal'
        call term#BufDelete(a:bufnr)
    elseif type ==# 'dirbuf'
    else
    endif
endfunc " buf#delete

func! buf#nr(type) abort
    if a:type ==# 'normal'
        return get(g:bufnrs, -1, 1)
    endif
endfunc " buf#nr

func! buf#c_w() abort
    if &buftype ==# 'terminal'
        call term_sendkeys(bufnr('%'), "\<C-w>")
    else
        if winnr('$') > 1
            call feedkeys("\<C-w>", 'n')
        endif
    endif
endfunc " buf#c_w

func! buf#qo() abort
    if winnr('$') > 1
        echom ":only"
        only
    elseif &buftype ==# 'terminal'
        echom "call term_sendkeys('', 'qo')"
        call term_sendkeys(bufnr('%'), 'qo')
        " call feedkeys('qo', 'n')
    endif
endfunc " buf#qo

func! buf#go() abort
    if winnr('$') > 1
        winc w
    else
        if &buftype ==# 'terminal'
            call term_sendkeys(bufnr('%'), 'go')
        endif
    endif
endfunc " buf#go

func! buf#close_if_term_window() abort
    if &buftype !=# 'terminal' || winnr('$') == 1
        return
    endif
    close
endfunc " buf#close_if_term_window

if !exists('g:scratch')
    let g:scratch = []
    let s:idx = -1
endif
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

func! buf#nextscratch(...) abort
    let nth = a:0 ? a:1 : 0
    if nth > len(g:scratch) || (nth == 0 && len(g:scratch) < 10)
        call add(g:scratch, buf#addscratch())
    endif
    if nth == 0
        let s:idx += 1
        if s:idx >= len(g:scratch) | let s:idx = -1 | endif
        return g:scratch[s:idx]
    else
        return g:scratch[nth % len(g:scratch)]
    endif
endfunc

" nn ;s :<C-u>exec 'b '. buf#nextscratch(v:count)<CR>

" nnoremap <F4> :<C-u>call buf#Toggle_diff_alternate_buffer()<CR>
func! buf#Toggle_diff_alternate_buffer() abort
    "-- feature: possibly return to previous position.
    if &diff
        diffoff!
        if winnr('$') > 1
            close
        endif
        set noscrollbind nocursorbind nocursorcolumn nocursorline
    else
        vsp
        b #
        diffthis
        set scrollbind cursorbind cursorcolumn cursorline
        winc p
        diffthis
        set scrollbind cursorbind cursorcolumn cursorline
        winc p
    endif
endfunc


func! buf#next_modified() abort
    let m = filter(getbufinfo(), 'v:val.changed == 1 && (getbufvar(v:val.bufnr, "&bt") != "terminal")')
    let m = map(m, 'v:val.bufnr')
    " echo m
    "     delfun buf#next_modified
    "
    if !empty(m)
        let curr = bufnr('%')
        if curr >= m[-1] || len(m) == 1
            let nr = m[0]
        else
            for nr in m
                if nr > curr | break | endif
            endfor
        endif
        exec 'b ' . nr
    endif
endfunc " buf#next_modified

func! buf#tab(count0,...) abort
    " 1t or t1 go tab 1, tt [show tabline, hide after 3s], tma [mark current tab as a]
    if a:count0 > 0
        if a:count0 <= tabpagenr('$')
            exec 'tabnext ' . a:count0
        endif
        return
    endif
    let c = getchar()
    let ch = nr2char(c)
    if ch ==# 't'
        tabs
    elseif ch =~ '^[$1-9]$'
        exec 'tabnext ' . ch
    elseif ch ==# 'n' || ch ==# '+'
        tabnext
    elseif ch ==# 'p' || ch ==# '-'
        tabprev
    elseif ch ==# 'o'
        $tabnew %
    elseif ch ==# 'c' || ch ==# 'x'
        tabclose
    elseif ch ==# 'l'
        tabs
        " tabnext<space>
        echo 'tabnext '
        let c = getchar()
        echon c
        " call feedkeys(":tabnext ")
    endif
endfunc " buf#tab(count0,...)

function! s:GetName() abort
    call inputsave()
    let g:username = input('Please enter your name: ')
    call inputrestore()
    return g:username
endfunction

" nnoremap <F1> :<c-u>echo 33 <C-\>e<sid>GetName()<CR>

            " \:<c-u>call <sid>GetName()<cr>
            " \:<c-u>execute 'normal! a ' . g:username .
            " \ '. You have a very nice name.'<cr>

" delfu buf#gmarkbuf
func! buf#gmarkbuf(mark) " go mark
    if a:mark =~# '^[a-z]$'
        let gmark = toupper(a:mark)
        let pos = getpos("'" . gmark)
        if pos[0] > 0
            exec 'b ' . pos[0]
        endif
    endif
endfunc " buf#gmarkbuf
