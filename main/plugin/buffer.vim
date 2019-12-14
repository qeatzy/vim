
" use leaderf, ctrlp, or write you own buffer switcher

" au FileType * let $FT= expand('<amatch>') | runtime ft/ft_$FT.vim
runtime ft/terminal.vim
" au TerminalOpen * ++once let $TERMNR = expand('<abuf>') | runtime ft/terminal.vim
" au FileType * ++once call ft#init(expand('<amatch>'))
nnoremap \g :e!<CR>

nnoremap <Space>f :set nomore<Bar>:ls<Bar>:set more<CR>:b<Space>
nnoremap <Space>; :bm<CR>
"nnoremap <Space>m :bm<CR>
nnoremap <Space>m :<C-u>call buf#next_modified()<CR>
call CmdAlias('fg', ' norm! ')
nn 'e :<C-u>call buf#gmarkbuf('e')<CR>
nn me mE

nn <silent> qo :<C-u>call buf#qo()<CR>

nn <silent> go <C-w>:call buf#go()<CR>

nn qn :<C-u>setl bt=nofile<CR>

func! Buf_go_buffer(count) abort
    let l:count = (a:count == 0)? bufnr('#') : a:count
    if l:count == -1 || l:count == bufnr('%')
        return
    endif
    exec 'b '.l:count
    if &bt != 'terminal'
        norm! `t
    endif
endfunc
"buffer-switching, for a plugin with file completion if no match, see http://vi.stackexchange.com/a/2187
" switch to Nth buffer or alternate buffer if no count is given, and restore cursor.
" autocmd BufLeave * mark t
autocmd BufLeave * norm! mt
nnoremap <silent> gt :<C-u>call Buf_go_buffer(v:count)<CR>|" alternatives: gh
nnoremap g0 :bfirst<CR>
nnoremap g9 :blast<CR>

augroup buffer
    autocmd!
    autocmd BufLeave * if &buflisted && &bt is# ''  | let g:lastbufnr = bufnr('%') | endif
augroup END " buffer

func! Buffer_left_0_right_1(cnt, is_right)
    exec a:cnt a:is_right ? 'bn' : 'bp'
endfunc
nnoremap <Space>h :<c-u>call Buffer_left_0_right_1(v:count1, 0)<CR>
nnoremap <Space>l :<c-u>call Buffer_left_0_right_1(v:count1, 1)<CR>

"tab page
nn t :<C-u>call buf#tab(v:count)<CR>
call CmdAlias('te', 'tab drop')
call CmdAlias('tne',  'tabnew')
call CmdAlias('tnew', 'tabnew')
call CmdAlias('tn', 'tabnext')
call CmdAlias('tp', 'tabprev')
call CmdAlias('ts', 'tabs')
call CmdAlias('tl', 'tabs')
call CmdAlias('t0', 'tabfirst')
call CmdAlias('t9', 'tablast')

func! s:goGlobalMarkH()
let g:bufnr = getpos("'H")[0] | if g:bufnr | exec 'b' .g:bufnr | endif
endfunc
" mark help file, then go back to it.
" nn `H :<C-u>let g:bufnr = getpos("'H")[0] | if g:bufnr | exec 'b' .g:bufnr | endif<CR>
nn `H :<C-u>s:goGlobalMarkH()<CR>
