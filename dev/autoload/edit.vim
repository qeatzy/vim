" to fix repeat of cgn, cgn: https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db
func! edit#repeat(cnt) abort
    call feedkeys(repeat('.',a:cnt),'ni') " 'n' flag to noremap, '.' could be mapto <Plug>(RepeatDot)
endfunc " edit#repeat

" motion version of cgn, from sad.vim https://github.com/hauleth/sad.vim
" use / (search as motion) is most robust, as long as below implementation is correct.
" or just 1 c/pat/e 2 cgn 3 . to repeat
func! edit#gn_motion_old(type, ...) abort
    if a:0 > 0 && a:1 is# "\<C-v>"
        return feedkeys('gv"'.v:register.'c', 'n')
    endif

    let l:temp = @v
    if a:0
        silent exe 'norm! gv"vy'
    elseif a:type is# 'line'
        silent exe "normal! '[V']\"vy"
    else
        silent exe 'normal! `[v`]"vy'
    endif

    let l:search = @v
    let @v = l:temp
    let @/ = '\V\C' . substitute(escape(l:search, '\'), '\n', '\\n', 'g')
    " call histadd('/', substitute(@/, '[?/]', '\="\\%d".char2nr(submatch(0))', 'g'))

    " let l:search = call('sad#search', a:000)
    exe 'let @'.v:register.' = "'.escape(l:search, '"').'"'
    call feedkeys('"'.v:register.'cgn', 'n')
endfunc " edit#gn_motion_old() abort
    ""interface to uset it
    "    set opfunc=edit#gn_motion_old
    "    " set opfunc=sad#search_and_replace_forward
    "    " exec 'norm! "' . v:register . 'g@'
    "    call feedkeys('"' . v:register . 'g@', 'n')

" func! edit#gn_motion()
" endfunc " edit#

func! edit#duplicate_current_line(...) abort
    let cnt = get(a:, 1, 1)
    let pos = getcurpos()
    let pos[1] += 1
    while cnt > 0
        t.
        let cnt -= 1
    endwhile
    call setpos('.', pos)
endfunc " edit#duplicate_current_line
