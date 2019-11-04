
func! imap#getchar()
    let c = getchar()
    return c . ' '
    h getchar()
endfunc " imap#ctrl_r

func! imap#ctrl_r()
    let c = getchar()
    let ch = nr2char(c)
    if ch == "r" || ch == "\<C-r>"
        let ch = "="
        return "\<C-r>" . ch
    elseif ch =~ '^[-"*.:%#/=a-z0-9]$'
        " might set paste if multiple lines
        return eval('@' . ch)
        return get(@,ch)
        return ch
        " pu=C('reg')
    else
        return ch
    endif
    return "\<C-r>" . ch
endfunc " imap#ctrl_r
