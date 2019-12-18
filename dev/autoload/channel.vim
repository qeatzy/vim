func! channel#receiver(lst_dest, channel, msg) abort
    call add(a:lst_dest, a:msg)
endfunc " channel#receiver

func! channel#setline(args, channel) abort
    " args: [lst, bufnr] + [optionally, extra pre func before setline] + [switch True]
    let [lst, bufnr] = a:args[:1]
    let lst = get(a:args,2) isnot 0 ? call(a:args[2], [lst]) : lst
    call var#setline(bufnr, lst)
    if get(a:, 3, 1) | exec 'b '. bufnr | endif
endfunc " channel#setline
