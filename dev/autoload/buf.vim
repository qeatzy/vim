
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

func! buf#nextscratch() abort
    if len(g:scratch) < 10
        call add(g:scratch, buf#addscratch())
    endif
    let s:idx += 1
    if s:idx >= len(g:scratch) | let s:idx = -1 | endif
    return g:scratch[s:idx]
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

nnoremap <F1> :<c-u>echo 33 <C-\>e<sid>GetName()<CR>

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
