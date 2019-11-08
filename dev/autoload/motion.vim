nmap <Plug>PageDown <C-f>
nmap <Plug>PageUp <C-b>

func! MyPageDown(cnt) range
    " Borland behaviour = the cursor keeps the same xy position during pageup/down.
    " for more, see edit.plg:/"page and " window
    " accept count, similar to ^f
    " principle, ^d ^u in normal mode is of Borland behaviour.
    " TODO: 1. handle long wrapped lines, 2. set jumplist manually
    let l:old_winline = winline()
    " let l:old_pos=getcurpos()[1:]
    " echom l:old_pos
    " let l:old_pos[0]+=(a:cnt * (winheight('%') - 1))
    " call cursor(l:old_pos)
    let l:old_pos=getcurpos()
    let l:old_pos[1]+=(a:cnt * (winheight('%') - 1))
    call setpos('.',l:old_pos)
    let l:new_winline = winline()
    if l:old_winline < l:new_winline
        exec 'norm! '.(l:new_winline - l:old_winline).''
    elseif l:old_winline > l:new_winline
        exec 'norm! '.(l:old_winline - l:new_winline).''
    endif
endfunc
func! MyPageUp(cnt) range
    " see MyPageDown()
    let l:old_winline = winline()
    let l:old_pos=getcurpos()
    let l:old_pos[1]-=(a:cnt * (winheight('%') - 1))
    call setpos('.',l:old_pos)
    let l:new_winline = winline()
    if l:old_winline < l:new_winline
        exec 'norm! '.(l:new_winline - l:old_winline).''
    elseif l:old_winline > l:new_winline
        exec 'norm! '.(l:old_winline - l:new_winline).''
    endif
endfunc
" below key bindings for PageDown/PageUp no longer used, instead, TogViewMode() is used.
" nnoremap <C-b> :call MyPageUp(v:count1)<CR>
func! motion#TogViewMode()
    " feature: add word indicating status in status bar, eg, 'view mode: on'.
    " if !exists('b:is_view_mode')
    "     let b:is_view_mode = 0
    " endif
    " if b:is_view_mode
    if !empty(maparg('j','n'))
        " echo maparg('j','n')
        try
        nunmap <buffer> <space>
        nunmap <buffer> <S-space>
        nunmap <buffer> j
        nunmap <buffer> k
        nunmap <buffer> d
        nunmap <buffer> s
        catch /^E31/
        endtry
    else
        nnoremap <buffer> <space> :call MyPageDown(1)<CR>
        " shift space may not work on some terminal, those who can't distinguish shift space from space.
        nnoremap <buffer> <S-space> :call MyPageUp(1)<CR>
        nnoremap <buffer> j :call MyPageDown(1)<CR>
        nnoremap <buffer> k :call MyPageUp(1)<CR>
        nnoremap <buffer> d :call MyPageDown(1)<CR>
        nnoremap <buffer> s :call MyPageUp(1)<CR>
    endif
    " let b:is_view_mode = (b:is_view_mode + 1) % 2
endfunc
" nnoremap ;v :call motion#TogViewMode()<CR>


func! motion#NextWindowOrTab(...) abort
"n  <C-L>       * :if winnr('$') == 1|tabn|else|winc l|endif<CR>
endfunc
" nn <C-l> :<C-u>call motion#NextWindowOrTab(v:count1)<CR>

func! TestRange() range
    echo a:firstline a:lastline
endfunc
