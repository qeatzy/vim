func! loop#next(lst, step, ...)
    let [fns, idx] = a:lst
    let num = len(fns)
    let idx = var#idxinc(idx, a:step, num)
    if a:0 | call call(a:1, [fns[idx]]) | endif
    let a:lst[1] = idx
    return fns[idx]
    " let Callback = type(a:Callback) == 2 ? a:Callback : function(a:Callback)
    " call Callback(fns[idx])
endfunc " loop#next

func! loop#map(map_unmap, ...)
    call execute(a:map_unmap[a:0 == 0])
endfunc " loop#map
