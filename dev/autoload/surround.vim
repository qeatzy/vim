func! surround#d() abort
    " (a (b (c) ))  3dsb ds3b
    " too hard if consider () inside of '' ""
    let c = getchar()
    let cnt = v:count1
    if 48 <= c && c <= 57     " 0-9
        let cnt *= c-48
        let c = getchar()
    endif
    let ch = nr2char(c)
        let po = getcurpos()
    if ch ==# 'b'
        let pat_in = '\%(\%(''[^'']*''\)\|\%("[^"]*"\)\|[^()]\)*'
        while 1
            let p2 = searchpos('(' . pat_in . '\()\)\{-,1}' . pat_in . '\%' . line(".") . "l" . '\%' . col(".") . "c", 'bWp')
            if p2[0] == 0 | echo "p2 fail" | call setpos('.', po) | return | endif
            echo "p2" p2 getcurpos()
            if p2[2] == 1
                let begpos = p2
                " call setpos('.', po)
                break
            elseif !exists('q2')
                let q2 = getcurpos()
            endif
        endwhile
        if exists('q2') 
            call setpos('.', q2) 
            echo "q2" q2
        endif
        while 1
            let p1 = searchpos(pat_in . '\((\)\{-,1}' . pat_in . ')', 'eWzp')
            " let p1 = searchpos(pat_in . ')', 'ceWzp')
            if p1[0] == 0 | echom "p1 fail"  po p1| call setpos('.', po)| return | endif
            echo "p1" p1 getcurpos()
            if p1[2] == 1
                let endpos = p1[:1]
                call setpos('.', po)
                break
            endif
        endwhile
        echo 'x x' begpos endpos
        " let begpos = searchpos('(\%(\%(''[^'']*''\)\|\%("[^"]*"\)\|[^(]\)*', 'bcW')
        " let pb = getcurpos()
        " let endpos = searchpos('\%(\%(''[^'']*''\)\|\%("[^"]*"\)\|[^)]\)*)', 'ceWz')
        " let pe = getcurpos()
    endif
    " call setpos("'[", po)
    exec 'sil norm! r' . matchstr(getline('.'), '\%' . col('.') . 'c.')
    " -- from https://stackoverflow.com/questions/23323747/vim-vimscript-get-exact-character-under-the-cursor
    "  -- a dummy change, to restore old postion if undo.
    call cursor(endpos)
    norm! x
    call cursor(begpos)
    norm! x
    echo begpos endpos " | " po
    " echo c "cnt =" cnt
endfunc " surround#d
nn <F1> :<C-u>call surround#d()<CR>
