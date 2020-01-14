" call term_sendkeys(22, "import numpy as np\<CR>")
" call term_sendkeys(22, "\<C-u>")
" call term_sendkeys(22, "1+1\r2+2\r")
" with terminal buffer, use python3 instead of ipython.
" bug, 'term ipython' buffer of vim inside of tmux, cannot paste multiple lines at once.
" ipython in tmux, or ipython in vim without of tmux, can  paste multiple lines at once.
"                             but ipython + term_sendkeys multiple lines still not work.
"                             though python + term_sendkeys multiple lines works. (no tmux)

func! s:isTermDirty_python(prompt)
    return a:prompt ==# '>>> ' ? 0 : 1 + a:prompt[0] ==# '>' 
    " if lastline !=# '>>> '
    "     call term_sendkeys(a:bufnr, "\r")
    "     if lastline[0] ==# '>' | return '' | endif
    " endif
endfunc " s:isTermDirty_python

func! s:isTermDirty_zsh(prompt)
endfunc " s:isTermDirty_zsh

let s:Cb_isTermDirty = {'': {prompt -> prompt is# ''},
        \ 'python': function('s:isTermDirty_python'),
        \ 'zsh': function('s:isTermDirty_zsh'),
        \ }
func! s:Cb_isTermDirty(prompt)
    let Callback = get(s:Cb_isTermDirty, b:pyinter)
    if Callback is# 0 | let Callback = s:Cb_isTermDirty[''] | endif
    return Callback(a:prompt)
endfunc " s:Cb_isTermDirty = {'': {cmd -> cmd is# ''}}
" let x = getbufline(38,'$')[0]
" echo x[-2:]

func! send#termi_python_line(bufnr, ...)
" let [g:a,g:b] = [col('.'), col('$')]
    " if a:0 | call feedkeys(a:1, 'n') | endif
    let char = a:0 ? a:1 . "\<CR>" : "\<CR>" 
    let ncol = col('$')
    if !a:0 && col('.') < ncol
        return char
    endif
    " if ncol == 1
    if ncol - 1 == indent('.')
        " if len(getbufline(a:bufnr, '$')[0]) == 4   " '>>> '
        let prompt = getbufline(a:bufnr, '$')[0]
        let code = s:Cb_isTermDirty(prompt)
        if code
            call term_sendkeys(a:bufnr, "\r")
        endif
    else
        call term_sendkeys(a:bufnr, getline('.') . "\r")
    endif
    return char
endfunc " send#termi_python_line

func! send#termi_key(bufnr, key, ...)
    let char = get(a:, 1, '')
    call term_sendkeys(a:bufnr, a:key)
    return char
endfunc " send#termi_key

func! send#term_lines(bufnr, lines)
    call term_sendkeys(a:bufnr, join(a:lines, "\r") . "\r")
    return
    for line in a:lines
        call term_sendkeys(a:bufnr, line . "\r")
        sleep 10m
    endfor
    " h join(
endfunc " send#term_lines

func! send#init()
augroup send_term
    autocmd!
    inoremap <silent> <buffer> <expr> <CR> send#termi_python_line(b:termnr)
    inoremap <silent> <buffer> <expr>  send#termi_python_line(b:termnr, "\<End>")|" on cygwin, <C-Enter>
    inoremap <silent> <buffer> <expr> <C-p> send#termi_key(b:termnr, "\<C-p>")
    inoremap <silent> <buffer> <expr> <C-n> send#termi_key(b:termnr, "\<C-n>")
    inoremap <silent> <buffer> <expr> <C-d> send#termi_key(b:termnr, nr2char(getchar()))
    nnoremap <silent> <buffer> <expr> <C-d> send#termi_key(b:termnr, nr2char(getchar()))
    " inoremap <silent> <buffer> <CR> <Esc>:call send#term_python_line(b:termnr, getline('.'))<CR>o
    nnoremap <silent> <buffer> <F2> :<C-u>call send#term_lines(b:termnr, var#curline(v:count1))<CR>
    nnoremap <silent> <buffer> <C-u> :<C-u>call term_sendkeys(b:termnr, "\<C-u>")<CR>
    nnoremap <silent> <buffer> <C-j> :<C-u>call term_sendkeys(b:termnr, getline('.') . "\r")<CR>
    nnoremap <silent> <buffer> <F8> :<C-u>exec 'sb ' . b:termnr<CR>
    nnoremap <silent> <buffer> <F12> :<C-u>call term#remove(b:termnr, 'kill')<CR>
    " E684: list index out of range: -1
    " usage, i: <C-o><C-j> to send current line, without move cursor
    " <C-d> key to send any key.
augroup END " send_term
endfunc " send#init

func! send#term()
    call send#init()
    return ''
endfunc " send#term
