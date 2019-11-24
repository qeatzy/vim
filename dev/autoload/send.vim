" call term_sendkeys(22, "import numpy as np\<CR>")
" call term_sendkeys(22, "\<C-u>")
" call term_sendkeys(22, "1+1\r2+2\r")
" with terminal buffer, use python3 instead of ipython.
" bug, 'term ipython' buffer of vim inside of tmux, cannot paste multiple lines at once.
" ipython in tmux, or ipython in vim without of tmux, can  paste multiple lines at once.
"                             but ipython + term_sendkeys multiple lines still not work.
"                             though python + term_sendkeys multiple lines works. (no tmux)

func! send#termi_python_line(bufnr, ...)
" let [g:a,g:b] = [col('.'), col('$')]
    " if a:0 | call feedkeys(a:1, 'n') | endif
    let char = "\<CR>"
    if a:0 | let char = a:1 . char | endif
    let ncol = col('$')
    if !a:0 && col('.') < ncol
        return char
    endif
    " if ncol == 1
    if ncol - 1 == indent('.')
        " if len(getbufline(a:bufnr, '$')[0]) == 4   " '>>> '
        let lastline = getbufline(a:bufnr, '$')[0]
        if lastline !=# '>>> '
            call term_sendkeys(a:bufnr, "\r")
            if lastline[0] ==# '>' | return '' | endif
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

" au filetype pyinter call send#pyinter()
func! send#pyinter(...)
    let b:pyinter = a:0 ? a:1 : 'python3'
augroup pyinter
    autocmd!
    inoremap <silent> <buffer> <expr> <CR> send#termi_python_line(term#bufnr(b:pyinter))
    inoremap <silent> <buffer> <expr>  send#termi_python_line(term#bufnr(b:pyinter), "\<End>")|" on cygwin, <C-Enter>
    inoremap <silent> <buffer> <expr> <C-p> send#termi_key(term#bufnr(b:pyinter), "\<C-p>")
    inoremap <silent> <buffer> <expr> <C-n> send#termi_key(term#bufnr(b:pyinter), "\<C-n>")
    inoremap <silent> <buffer> <expr> <C-d> send#termi_key(term#bufnr(b:pyinter), nr2char(getchar()))
    nnoremap <silent> <buffer> <expr> <C-d> send#termi_key(term#bufnr(b:pyinter), nr2char(getchar()))
    " inoremap <silent> <buffer> <CR> <Esc>:call send#term_python_line(term#bufnr(b:pyinter), getline('.'))<CR>o
    nnoremap <silent> <buffer> <F2> :<C-u>call send#term_lines(term#bufnr(b:pyinter), buf#curline(v:count1))<CR>
    nnoremap <silent> <buffer> <C-u> :<C-u>call term_sendkeys(term#bufnr(b:pyinter), "\<C-u>")<CR>
    nnoremap <silent> <buffer> <C-j> :<C-u>call term_sendkeys(term#bufnr(b:pyinter), getline('.') . "\r")<CR>
    nnoremap <silent> <buffer> <F8> :<C-u>exec 'sb ' . term#bufnr(b:pyinter)<CR>
    nnoremap <silent> <buffer> <F12> :<C-u>call term#remove(term#bufnr(b:pyinter), 'kill')<CR>
    try | call term#bufnr(b:pyinter) | catch /E684/ | endtry
    " E684: list index out of range: -1
    " usage, i: <C-o><C-j> to send current line, without move cursor
    " <C-d> key to send any key.
augroup END " pyinter
return ''
endfunc " send#pyinter
