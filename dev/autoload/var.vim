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
