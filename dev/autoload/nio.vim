func! nio#search()
    echon "\r>>>"
    while 1
        let c = getchar()
        echon "\r" c
        if c is# 47
            call feedkeys('/')
            au CmdlineLeave / ++once call nio#search() 
            " au! CmdlineEnter
            break
        endif
    endwhile
endfunc " nio#search
nn <F1> :<C-u>call nio#search()<CR>
" nun <F1>

