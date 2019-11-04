
" nn - :<C-u>call dirbuf#goparent(v:count1)<CR>
" nn ql :<C-u>call dirbuf#dh_open('.')<CR>
nn <silent> - :<C-u>call dirbuf#goparent(expand('%:p:h'))<CR>
" autocmd FileType dirbuf nn - :<C-u>call dirbuf#openpath(expand('%:p:h:h'))<CR>
nn ql :<C-u>call dirbuf#openpath('.')<CR>
nn gh :<C-u>call bbuf#openbuffers()<CR>

augroup dirbuf
    autocmd!
    autocmd BufNew * if isdirectory(expand('<amatch>')) | call dirbuf#openpath(expand('<amatch>'), 'dir', 0) | endif
    autocmd VimEnter * call dirbuf#openpath($PWD, 'dir', 0)
    " autocmd BufNewFile *    echom "BufNewFile" expand('<amatch>')
    " autocmd BufNew *    echom "BufNew" expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd WinNew *    echom "WinNew" expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd WinEnter *    echom "WinEnter" expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd TabNew *    echom "TabNew" expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd TabEnter *    echom "TabEnter" expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd FileReadPost *    echom "FileReadPost" expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd BufFilePost *    echom "BufFilePost" expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd BufEnter *    echom "BufEnter" expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd BufAdd *    echom "BufAdd" expand('<amatch>') expand('<abuf>') expand('<afile>')
augroup END " dirbuf

augroup ft
    autocmd!
    autocmd filetype dirbuf call dirbuf#setup()
    autocmd filetype bbuf call bbuf#setup()
    autocmd filetype runcmd call run#setup()
augroup END " ft
