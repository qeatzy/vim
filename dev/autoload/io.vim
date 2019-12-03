" h confirm(
func! io#confirm(msg, accept) abort
    " echo confirm("yes or no")
    let accept = type(a:accept) == v:t_list ? a:accept : split(a:accept, '\zs')
    let default = get(a:, 1, 0)
    try
    while 1
        echon "\r" a:msg
        let c = getchar()
        let ch = nr2char(c)
        echon c "|" ch
        if ch is# "\<Esc>" || c is# "\<BS>"
            return default
        endif
        let idx = index(accept, ch) + 1
        if idx
            return idx
        endif
    endwhile
    catch /.*Interrupt.*/       " <C-c>
    endtry
endfunc " io#confirm
" call io#confirm("rm " . expand('#') . "yes or no", "yn")

func! io#getinput(lst_lines, bufnr, ...) abort
    let [idx,n] = [0, len(a:lst_lines)]
    let ft = get(a:, 1)
    if type(ft) == 0 | let ft = repeat([''], n) | endif
    let input = []
    let patlen = []
    let pat = ""
    for i in range(100)
        let b = filter(copy(a:lst_lines[idx]), 'v:val =~ pat')
        " echom len(b) pat
        echom pat
        echon join(input,'')
        let num = len(b) + 1
        if !empty(getbufline(a:bufnr, num, num))
            call deletebufline(a:bufnr, num, '$')
        endif
        call setbufline(a:bufnr, 1, b)
        redraw!
        " echon repeat(' ',len(input)) . "\r>>> " . join(input,'')
        echon repeat(' ',20) . "\r>>> " . join(input,'')
        try
            let c = getchar()
        catch /^Vim:Interrupt$/  " CTRL-C  https://vim.fandom.com/wiki/Implement_your_own_interactive_finder_without_plugins
            break
        endtry
        echom c
        let ch = nr2char(c)
        " echom c ch
        if ch == "\<Esc>"
            break
        elseif c == 6  "\<C-f>"
            let idx = (idx+1) % n
            continue
            " echo 1%2 0%2 2%2
        elseif ch == "\<C-u>"
            if empty(input)
                break
            endif
            let [pat, patlen, input] = ["", [], []]
            continue
        elseif (ch == "\<C-h>") || (c is# "\<BS>")
        " https://stackoverflow.com/questions/17509217/detect-backspace-in-viml
        " echom c ch "delete"
            if empty(input)
                break
            endif
            call remove(input, -1)
            let n = remove(patlen, -1)
            if n == 0
                let pat = ""
            else
                let pat = pat[:n-1]
            endif
            continue
        else
        endif
        call add(input, ch)
        if ch =~# "[./]"
            let ch = "\\" . ch
        endif
        call add(patlen, len(pat))  " add old len
        let pat .= ch . '.\{-}'
    endfor
    if ft[idx] != '' && ft[idx] != &ft
        let &ft=ft[idx]
    endif
endfunc

func! io#popupinput() abort
    nn q :<C-u>call popup_close(winid)<CR>
    nn q :<C-u>call popup_clear()<CR>
    let winid = popup_create(31,{'maxheight':23,'wrap':0,'highlight':'Comment'})
endfunc " io#popupinput

func! io#notify(msg) abort
    " let winid = popup_create(a:msg,{'highlight':'PmenuThumb'})
    let winid = popup_create(['job done.','q to close this message.','gh to switch to result buffer(or tab)','  after that, q will quit that tab'],{'time':3000, 'minheight':5,'minwidth':10,'border':[],'padding':[],'highlight':'PmenuThumb'})
    " let winid = popup_create(['job done.','q to close this message.'],{'highlight':'PmenuThumb'})
endfunc " io#notify

func! io#cursorDown(...)
    let pos = getcurpos()
    let pos[1] += 1
    call setpos('.', pos)
endfunc " io#cursorDown

func! io#cursorUp(...)
    let pos = getcurpos()
    let pos[1] -= 1
    call setpos('.', pos)
endfunc " io#cursorDown

func! io#putchar(cmd, c)
    let ch = nr2char(a:c)
    let cmd = a:cmd
    if ch is# "\<C-h>" 
        if empty(cmd) | return -1 | endif
        let cmd = cmd[:-2]
    elseif ch is# "\<C-u>" 
        if empty(cmd) | return -1 | endif
        let cmd = ''
    else
        let cmd = a:cmd . ch
    endif
    return cmd
endfunc " io#putchar

func! io#appendRegister(cmd, c)
    let c = getchar()
    let ch = nr2char(c)
    if c is# 23
        let x = expand('<cword>')
    else
        exec 'let x = a:cmd . @' . ch
    endif
    return x
endfunc " io#appendRegister

func! io#searchMotion(cmd, c)
    let cmd = nr2char(a:c) " / or ?
    echon "\r" cmd
    " call feedkeys(cmd,'n')
    " call feedkeys('/','x')
    call feedkeys('/')
    try
    " while 1
    "     " echon "\r" cmd
    "     let c = getchar()
    "     let ch = nr2char(c)
    "     if ch is# "\<C-h>" || ch is# "\<BS>"
    "         let cmd = cmd[:-2]
    "         call feedkeys("\<BS>",'n')
    "     elseif ch is# "\<C-m>"
    "         call feedkeys("\<C-m>",'n')
    "         break
    "     else
    "         let cmd = cmd . ch
    "         call feedkeys(ch)
    "     endif
    " endwhile
    catch /.*Interrupt.*/       " <C-c>
        let status_code = -1
        " echo c
    endtry
    return a:cmd
    echon "\r"
    call feedkeys(
    let c = getchar()
    let ch = nr2char(c)
    if c is# 23
        let x = expand('<cword>')
    else
        exec 'let x = a:cmd . @' . ch
    endif
    return x
endfunc " io#searchMotion

func! io#openfile()
endfunc " io#openfile

if !exists('s:bufnr') | let s:bufnr = bufadd('') | endif
func! io#fuzzyselect(lines, handler)
    exec 'bot sp +b' . s:bufnr
    " top sp +b23
    " below sp +b23
let lines = a:lines
" let lst = items(map(copy(g:dh_dirs), {k,v -> v.viewtime}))
" let lines = map(sort(copy(lst), 'cmp#k1_r'), 'v:val[0]') | echo lines
"     let lines = map(filter(getbufinfo(), 'v:val.listed'), 'v:val.name')
"     let lines = g:ndirs[expand('%:p:h')].tree
"     let lines = filter(copy(g:ndirs[expand('%:p:h')].tree), 'v:val[-1:] !=# "/"')
call setbufline(s:bufnr, 1, lines)
    redraw!
    call io#keyloop(s:bufnr, lines, a:handler)
endfunc " io#fuzzyselect

func! io#fuzzyfiles()
    let path = path#abspath(expand('%:p:h'))
    try
    let lines = filter(copy(g:ndirs[path].tree), 'v:val[-1:] !=# "/"')
    catch /.*/
        call path#tree(path)
        let lines = filter(copy(g:ndirs[path].tree), 'v:val[-1:] !=# "/"')
    endtry
    let handler = {47:'io#searchMotion',18:'io#appendRegister',13:{->1},10:'io#cursorDown',11:'io#cursorUp',0:'io#putchar'}
    call io#fuzzyselect(lines, handler)
endfunc " io#fuzzyfiles

func! io#matcher(lines, cmd)
endfunc " io#matcher

func! s:filter(lines, cmd)
    " let lines = reverse(copy(a:lines))
    " return lines
    let pat = substitute(a:cmd, '.', '\0(.*)', 'g')
    let pat = substitute(a:cmd, '.', '\0.*', 'g')
    let pat = substitute(a:cmd[:-2], '.', '\0\\(.\\{-\\}\\)', 'g')
    let pat = '\(.*\)\zs' . pat . a:cmd[-1:] . '\(.*\)'
    let g:x = pat
    let g:lst = map(copy(a:lines), '[v:val, matchstr(v:val,pat)]')
    let g:lst = filter(g:lst, '!empty(v:val[1])')
    let g:lst = sort(g:lst, 'cmp#k1len')
    let g:lst = map(g:lst, 'v:val[0]')
    return g:lst
    " echo "\n" pat
    " h submatch(
    " h matchstr(
    let lines = filter(copy(a:lines), 'v:val =~ pat')
    return lines
endfunc " s:filter
let s:Filter = function('s:filter')

func! io#keyloop(bufnr, lines, handler, ...)
    let Filter = get(a:, 1, s:Filter)
    if type(Filter) isnot# 2 | let Filter = function(Filter) | endif
    " let clear = "\r" . repeat(' ',30) . "\r"
    let clear = repeat(' ',30) . "\r"
    let clear = "\r"
    let status_code = 0
    let cmd = ''
    try
    while 1
        echon clear
        echon cmd
        let c = getchar()
        " echon "\r" c | continue
        let Handler = get(a:handler, c)
        if Handler is# 0
            let Handler = get(a:handler, 0) " default handler
        endif
        if Handler isnot# 0
            if type(Handler) isnot# 2   " funcref
                let Handler = function(Handler)
            endif
            let rv = Handler(cmd, c)
            if type(rv) is# 0 " int
                if rv == 0
                    redraw  " eg, <C-j> <C-k> cursor down/up
                    continue
                else
                    let status_code = rv
                    break
                endif
            endif
            let cmd = rv
            let lines = Filter(a:lines, cmd)
            let num = len(lines) + 1
            if !empty(getbufline(a:bufnr, num, num))
                call deletebufline(a:bufnr, num, '$')
            endif
            call setbufline(a:bufnr, 1, lines)
            redraw
        endif
    endwhile
    catch /.*Interrupt.*/       " <C-c>
        let status_code = -1
        " echo c
    endtry
    if status_code == -1
        wincmd q
    elseif status_code == 1
        let file = getline('.')
        let nr = bufnr(file)
        let g:x = [nr, getline('.')]
        wincmd q
        if nr > 0
            exec 'b' . nr
        else
            exec 'e ' . file
        endif
    endif
endfunc " io#keyloop
