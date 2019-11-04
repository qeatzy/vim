" if exists('g:loaded_dirbufcore') || &cp || v:version < 700 || &cpo =~# 'C'
"   finish
" endif
" let g:loaded_dirbufcore = 1
"
" " let g:timer = timer_start(500, dirbufcore#update_trees,
" " let g:timer = timer_start(500, ,
" "     \ {'repeat': 3})
"
" let s:update_tree = function('dirbufcore#update_trees')
"
" func! g:Update_tree_later() abort
"     let timer = timer_start(2000, {timer -> timer_start(500, s:update_tree,
"                 \ {'repeat' : 1})}) 
"     " echom 'g:update_tree_later, timer = ' timer
" endfunc " g:update_tree_later
"
" func! s:TogglePrefix(cnt) abort
"     " let prefix = expand('%') . '/'
"     let prefix = b:dirbuf . '/'
"     let n = len(prefix)
"     if getline('.')[:n-1] ==# prefix
"         let [pat, replace, nchar] = ['^.\{' . n . '\}' , '', -n]
"     else
"         let [pat, replace, nchar] = ['^\s*', prefix, n]
"     endif
"     let range = a:cnt <= 1 ? '' : '.,.+' . (a:cnt-1)
"     let pos = getcurpos()
"     exec 'keepj ' . range . 's=' . pat . '=' . replace . '='
"     let pos[2] += nchar
"     let pos[4] += nchar
"     call setpos(".", pos)
"     call setpos("'`", pos)
" endfunc s:TogglePrefix
"
" func! s:OpenExplorer(...) abort
"     let path = get(a:, 1, b:dirbuf)
"     exec "!cygstart '" . b:dirbuf . "'"
" endfunc s:OpenExplorer
"
" noremap <Plug>db_TogglePrefix :<C-u>call <SID>TogglePrefix(v:count1)<CR>
" noremap <Plug>db_OpenExplorer :<C-u>call <SID>OpenExplorer()<CR>
"
" augroup dirbufcore
"     autocmd!
"     " autocmd VimEnter * call g:Update_tree_later()
"     autocmd filetype dirbuf nn <buffer> <Enter> :<C-u>call dirbufcore#dh_enter()<CR>
"     autocmd filetype dirbuf nn <buffer> i :<C-u>call dirbufcore#dh_enter()<CR>
"     autocmd filetype dirbuf nmap <buffer> ga <Plug>db_TogglePrefix
"     autocmd filetype dirbuf nmap <buffer> ge <Plug>db_OpenExplorer
"     autocmd filetype dirbuf nn <buffer> t :<C-u>call dirbufcore#opentree(expand('%'))<CR>
"     autocmd filetype dirbuf nn <buffer> R :<C-u>call dirbufcore#update_tree(expand('%'))<CR>
"     " autocmd BufNewFile *    echom "BufNewFile" expand('<amatch>')
"     autocmd BufNew *    call dirbufcore#opendirectory(expand('<amatch>'))
"     " autocmd BufNew *    call dirbufcore#dh_open(expand('<amatch>'))
"     " autocmd BufNew */*    echom "BufNew" expand('<amatch>') expand('<abuf>') expand('<afile>')
"     autocmd DirChanged global call dirbufcore#updatecwd(expand('<afile>'))
"     " autocmd DirChanged global call echom(expand('<amatch>'))
"     " autocmd VimEnter * echom 'test VimEnter'
"     " autocmd VimEnter * call youcompleteme#Enable()
"     "autocmd InsertEnter * set timeoutlen=200
" augroup END " dirbufcore
"
" nn - :<C-u>call dirbufcore#goparent(v:count1)<CR>
" nn ql :<C-u>call dirbufcore#dh_open('.')<CR>
"
"
