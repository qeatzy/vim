func! cmp#k1(x, y)
    let a = a:x[1]
    let b = a:y[1]
    return (a>b) - (a<b)
endfunc " cmp#k1

func! cmp#k1_r(x, y)
    let a = a:x[1]
    let b = a:y[1]
    return (a>b) - (a<b)
endfunc " cmp#k1

func! cmp#k1len(x, y)
    let a = len(a:x[1])
    let b = len(a:y[1])
    return (a>b) - (a<b)
endfunc " cmp#k1
