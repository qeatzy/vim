
" use leaderf, ctrlp, or write you own buffer switcher

nnoremap <Space>f :set nomore<Bar>:ls<Bar>:set more<CR>:b<Space>
nnoremap <Space>; :bm<CR>
"nnoremap <Space>m :bm<CR>
nnoremap <Space>m :<C-u>call buf#next_modified()<CR>
call CmdAlias('fg', ' norm! ')

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

func! Buffer_left_0_right_1(cnt, is_right)
    exec a:cnt a:is_right ? 'bn' : 'bp'
endfunc
nnoremap <Space>h :<c-u>call Buffer_left_0_right_1(v:count1, 0)<CR>
nnoremap <Space>l :<c-u>call Buffer_left_0_right_1(v:count1, 1)<CR>

"terminal
augroup terminal
    autocmd!
    autocmd TerminalOpen * call term#add(expand('<abuf>'))
    autocmd TerminalOpen * set laststatus=1
    autocmd BufEnter * if getbufvar(expand('<abuf'), '&bt') == 'terminal' | set laststatus=1 | endif
    autocmd BufLeave * if getbufvar(expand('<abuf'), '&bt') == 'terminal' | set laststatus=2 | endif
    " autocmd BufEnter * echom 'BufEnter' expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd BufLeave \!* echom 'BufLeave' expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd TerminalOpen *    echom "TerminalOpen" expand('<amatch>') expand('<abuf>') expand('<afile>')
augroup END " terminal
tnoremap jj <C-w>N
nnoremap <silent> <C-z> :<C-u>call term#switch_to_term_buffer()<CR>
nnoremap <silent> gm :<C-u>call term#switch_to_term_buffer()<CR>
inoremap <silent> <C-z> <C-o>:call term#switch_to_term_buffer()<CR>
tnoremap <silent> gt <C-w>:b #<CR>
tnoremap go <C-w><C-w>|" cause problem when paste, eg, https://github.com/goldfeld/vim-seek
tnoremap qo <C-w><C-o>

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

