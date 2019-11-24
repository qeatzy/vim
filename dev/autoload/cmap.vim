func! s:removechar()
    let cmd = getcmdline()[:-2]
    return cmd
endfunc

func! cmap#interactive()
    cnoremap <C-w> <C-\>e<SID>removechar()<CR>
endfunc " cmap#interactive
call cmap#interactive()

augroup cmap
    autocmd!
    autocmd CmdlineChanged @ call setbufline(1,1, getcmdline()) | redraw
augroup END " cmap
