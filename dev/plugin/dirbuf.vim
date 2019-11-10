
" nn - :<C-u>call dirbuf#goparent(v:count1)<CR>
" nn ql :<C-u>call dirbuf#dh_open('.')<CR>
nn <silent> - :<C-u>call dirbuf#goparent(v:count1)<CR>
" autocmd FileType dirbuf nn - :<C-u>call dirbuf#openpath(expand('%:p:h:h'))<CR>
nn ql :<C-u>call dirbuf#openpath('.')<CR>
nn gh :<C-u>call bbuf#openbuffers()<CR>

func! s:lazy_dirbuf_pwd(timer) abort
    " call dirbuf#openpath($PWD)
endfunc
let Lazy_dirbuf_pwd = funcref('s:lazy_dirbuf_pwd')

augroup dirbuf
    autocmd!
    " autocmd BufNew * if isdirectory(expand('<amatch>')) | call dirbuf#openpath(expand('<amatch>'), 'dir', 0) | endif
    " autocmd BufNew * if isdirectory(expand('<amatch>')) && getbufvar(expand('<abuf>'),'dirbuf') isnot# 0 | call dirbuf#openpath(expand('<amatch>')) | endif
    autocmd VimEnter * call timer_start(200, Lazy_dirbuf_pwd)
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
