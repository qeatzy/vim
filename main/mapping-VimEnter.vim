func! Supertab()
    let nr = col('.') - 1
    " get char under cursor https://vi.stackexchange.com/questions/11476/how-can-i-get-the-character-at-the-cursor-position-in-a-multibyte-aware-manner
    if nr == 0 || strcharpart(strpart(getline('.'), nr-1),0,1) !~# '[_0-9a-zA-Z]'
        echom "Supertab 1"
        return "\<Tab>"
    else
        call UltiSnips#ExpandSnippet()
        if g:ulti_expand_res == 0
        echom "Supertab 2"
        " return 2
            " return "\<C-n>"
            " youcompleteme
            return pumvisible() ? "\<C-n>" : "\<Tab>"
        endif
        echom "Supertab 3"
        return ""
    endif
endfunc " Supertab()
" inoremap <expr> <Tab> Supertab()
inoremap <Tab> <C-r>=Supertab()<CR>

