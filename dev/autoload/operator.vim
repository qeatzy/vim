
func! operator#oplinerange(lno, cnt) abort
endfunc " operator#oplinerange

func! Num_qr(lno, cnt) abort
    let fn = operator#writelines(getline(a:lno, a:lno + a:cnt - 1))
    exec '!cat ' . shellescape(fn)
    " echo readfile(fn)
endfunc

" nn <buffer> qr :<C-u>call Num_qr(line('.'),v:count1)<CR>

func operator#comment(...) abort
    if getline('.') =~ '^\s*#'
        s/\s*#\s*//
    else
        s/^/# /
    endif
endfunc
