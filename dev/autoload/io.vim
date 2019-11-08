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
    let winid = popup_create(['job done.','q to close this message.','gh to switch to result buffer(or tab)','  after that, q will quit that tab'],{'minheight':5,'minwidth':10,'border':[],'padding':[],'highlight':'PmenuThumb'})
    " let winid = popup_create(['job done.','q to close this message.'],{'highlight':'PmenuThumb'})
endfunc " io#notify
