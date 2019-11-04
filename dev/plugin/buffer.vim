
" use leaderf, ctrlp, or write you own buffer switcher

nnoremap <Space>f :set nomore<Bar>:ls<Bar>:set more<CR>:b<Space>
nnoremap <Space>; :bm<CR>
nnoremap <Space>m :bm<CR>

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
