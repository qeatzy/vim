let g:mvqueue = get(g:, 'mvqueue', [])

func! Lines(cnt) abort
    let start = line('.')
    return getline(start, start + a:cnt - 1)
endfunc " Lines

func! Action(Callback, ...) abort
    " let Callback = type(a:Callback) != 2 ? function(a:Callback) : a:Callback
    call call(a:Callback, a:000)
endfunc " Action

func! Add_to_mvqueue(cnt) abort
    call extend(g:mvqueue, Lines(a:cnt))
    echo g:mvqueue
endfunc " Add_to_mvqueue

func! Files(files)
    let files = a:files
    call map(files, "substitute(v:val,'/$','','')")
    call map(files, "b:dirbuf . '/' . v:val")
    return files
endfunc " Files

func! Put_mvqueue(cnt) abort
    let dest_source = [getline('.')]
    call extend(dest_source, copy(g:mvqueue))
    let dest_source = Files(dest_source)
    let cmd = 'mv -t ' . join(dest_source, ' ')
    " sil! exec cmd
    call system(cmd)
    echo cmd
    call Clear_mvqueue('no echo')
endfunc " Put_mvqueue

func! Clear_mvqueue(...) abort
    if !empty(g:mvqueue)
        call remove(g:mvqueue,0,-1)
    endif
    if !a:0 | echo g:mvqueue | endif
endfunc " Clear_mvqueue

func! Echo_mvqueue() abort
    echo g:mvqueue
endfunc " Echo_mvqueue



func! Setup_mvqueue(...)
    nn <buffer> x :<C-u>call Action('Add_to_mvqueue', v:count1)<CR>
    nn <buffer> p :<C-u>call Action('Put_mvqueue', v:count1)<CR>
    nn <buffer> c :<C-u>call Action('Clear_mvqueue')<CR>
    nn <buffer> e :<C-u>call Action('Echo_mvqueue')<CR>
endfunc " Setup_mvqueue
