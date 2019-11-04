
augroup path
    autocmd!
    autocmd DirChanged global call path#updatecwd(expand('<afile>'))
    " autocmd filetype dirbuf nn <buffer> T :<C-u>call dirbufcore#opentree(expand('%'))<CR>
augroup END " path
