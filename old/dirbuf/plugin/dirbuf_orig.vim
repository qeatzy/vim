" if exists('g:loaded_dirbuf') || &cp || v:version < 700 || &cpo =~# 'C'
"   finish
" endif
" let g:loaded_dirbuf = 1
"
" nn - :<C-u>call dirbuf#pwd(v:count1)<CR>
" nn ql :<C-u>call dirbuf#open('.')<CR>
"
" augroup dirbuf
" autocmd!
" autocmd filetype dirbuf nn <buffer> <Enter> :<C-u>call dirbuf#enter()<CR>
" autocmd filetype dirbuf nn <buffer> i :<C-u>call dirbuf#enter()<CR>
" augroup END " dirbuf
"
" " augroup dirbuf_ftdetect
" "     autocmd!
"     " autocmd BufAdd * echom 'BufAdd' | if !exists('b:dirbuf') && isdirectory(expand('<afile>'))
"     "     \ | redraw | echo '' | let a = expand('<afile>') | echom 'dirbuf_ftdect BufAdd' a
"     "     \ | call dirbuf#open(expand('<afile>')) | endif
"     " autocmd BufNew * echom 'BufNew' | if !exists('b:dirbuf') && isdirectory(expand('<afile>'))
"     "     \ | redraw | echo '' | let a = expand('<afile>') | echom 'dirbuf_ftdect BufNew' a
"     "     \ | call dirbuf#open(expand('<afile>')) | endif
"     " autocmd BufReadPre * if !exists('b:dirbuf') && isdirectory(expand('%'))
"     "     \ | redraw | echo '' | let a = expand('%') | echom 'dirbuf_ftdect BufReadPre' a
"     "     \ | call dirbuf#open(expand('%')) | endif
"     " autocmd BufReadCmd * if !exists('b:dirbuf') && isdirectory(expand('%'))
"     "     \ | redraw | echo '' | let a = expand('%') | echom 'dirbuf_ftdect BufReadCmd' a
"     "     \ | call dirbuf#open(expand('%')) | endif
" " augroup END " dirbuf_ftdetect
"
" " augroup dirbuf_workaround
" "     autocmd!
" "     autocmd BufEnter . echom 'BufEnter' | if expand('%') == '.'
" "         \ | redraw | echo ''
" "         \ | call dirbuf#open('.') | au! | endif
" " augroup END " dirbuf_workaround
