func! var#get(name)
    if has_key(b:, a:name)
        let x = get(b:, a:name)
    elseif has_key(g:, a:name)
        let x = get(g:, a:name)
    else
        let x = getenv(a:name)
        if x is# v:null | let x = '' | endif
    endif
    return x
endfunc " var#get

func! var#setline(bufnr, lines) abort
    let num = len(a:lines) + 1
    if !empty(getbufline(a:bufnr, num, num))
        call deletebufline(a:bufnr, num, '$')
    endif
    call setbufline(a:bufnr, 1, a:lines)
endfunc

func! var#curline(...) abort
    let cnt = get(a:, 1, 1)
    let start = line('.')
    let last = line('$')
    let stop = start + cnt - 1
    if stop > last
        let stop = last
    endif
    return getline(start, stop)
endfunc " buf#curline

func! var#getline(count)
    " return line count lines below
    let [line, linenr] = [line('.'), line('$')]
    let nr = line + a:count
    if nr > linenr || nr < 1
        let nr = line
    endif
    return getline(nr)
endfunc " var#cline

func! var#idxinc(idx, step, length)
    let idx = a:idx + a:step
    let idx = idx >= 0 ? idx : (idx + (a:length-1-idx) / a:length * a:length)
    let idx = idx < a:length ? idx : idx % a:length
    return idx
endfunc " var#idxinc
