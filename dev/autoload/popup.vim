let s:script = expand('<sfile>')
if !exists('*popup#init')
func! popup#init() abort
    exec 'so ' . s:script
endfunc " popup#init
endif

nn <buffer> <silent> <F2> :<C-u>call popup#init()<CR>
nn <buffer> <expr> q (popup_clear() ? '' : '')
nn <buffer> <BS> <BS>
" nun <buffer> <BS>
" nun <BS>
" nn <BS>

let s:input = ""
func! popup#filter(winid, key) abort
    echo a:winid
    if a:key =~ '[:;]'
        call popup_close(a:winid)
    else
        " if a:key == "\<C-h>" || a:key == "\<BS\>"
        if a:key == "\<C-h>" || a:key == "\<BS\>"
            let s:input = s:input[:-2]
        else
            let s:input .= a:key
        endif
        call popup_settext(a:winid, repeat([s:input], len(s:input)))
    endif
    return 1
endfunc " popup#filter

" echo 333
call popup_create("please type some keys", {'filter' : 'popup#filter'})
