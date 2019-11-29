func! loop#next(lst, step, Callback)
    let [fns, idx] = a:lst
    let num = len(fns)
    let idx = var#idxinc(idx, a:step, num)
    let Callback = type(a:Callback) == 2 ? a:Callback : function(a:Callback)
    call Callback(fns[idx])
    let a:lst[1] = idx
endfunc " loop#next

func! loop#map(lst, ...)
    let idx = get(a:, 0) isnot# 0
    let mapping = map(copy(a:lst), 'v:val[idx]')
    call execute(mapping)
endfunc " loop#map
