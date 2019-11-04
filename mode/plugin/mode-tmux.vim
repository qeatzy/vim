
" echo tempname()
" h writefile()

" let x = [3]
" echo [1,2] + x[:-2] + [0]
" echo x[0] x[-1] x[1:-2]
" let x = ['33;','22']
" echo map(x, 'escape(v:val, ";''")')

" if !has_key(s:, 'd_tmux_escape')
"     let s:d_tmux_escape = {
" endif
" for \t tab break, use :retab! to transform to space
func! Tmux_escape(s)
    let s = a:s
    " let s = substitute(s,"\t"," ","g")
    "           '"'"'
    let s = substitute(s,"'",'''"''"''',"g")
    return s
endfunc

func! Tmux_send(keys, ...) abort
    let opt = get(a:, 1, '')
    let multi_arg = get(a:, 2, 0)
    let keys = (type(a:keys) != v:t_list) ? [a:keys] : a:keys
    let endswith_colon = (keys[-1][-1:] == ';') ? 1 : 0
    if multi_arg
        let cmd = map(keys, " \"'\" . escape(v:val,';') . \"'\" ")
        let cmd[0] = "tmux send-keys -t .+1 " . opt . cmd[0]
        let cmd = [join(cmd, ' ')]
    else
        let keys[-1] = substitute(keys[-1], ';\s*$', '\\;', '')
        " let cmd = map(keys, 'escape(v:val, ";''")')
        let cmd = map(keys, 'Tmux_escape(v:val)')
        let cmd[0] = "tmux send-keys -t .+1 " . opt . " '" . cmd[0]
        " let cmd[0] = "tmux send-keys -t .+1 -l '" . cmd[0]
        let cmd[-1] .= "'"
        if endswith_colon && (has_key(b:, 'sql_colon') ? b:sql_colon : get(g:, 'sql_colon', 0))
            let cmd[-1] = cmd[-1] . " \\; send -t .+1 enter"
        endif
    endif
    " echo cmd
    let fn = tempname()
    " let fn = 'xx'
    call writefile(cmd, fn)
" call writefile([endswith_colon , (has_key(b:, 'sql_colon') ? b:sql_colon : get(g:, 'sql_colon', 0))] + cmd, fn)
"         return
    call system('bash ' . fn . ' &>/dev/null')
    " system() to avoid hit-enter
    " exec 'sil! !bash xx &>/dev/null'
    " redraw!
    " call writefile("tmux send-keys -t .+1 'Enter'", 'xx')
    " echo a:keys type(a:keys) type([])
    " exec "!tmux send-keys -t .+1 '" . keys . "'"
endfunc

func! Toggle_mode_tmux_sql()
    if !get(b:, '_b_Toggle_mode_tmux_sql', 0)
        echo 'Toggle_mode_tmux_sql on'
        let b:_b_Toggle_mode_tmux_sql = 1
        nn <buffer> <silent> l :<C-u>call Tmux_send(getline('.',line('.')+(v:count)), '-l')<CR>
        nn <buffer> <C-j> :<C-u>call Tmux_send('Enter')<CR>
        " nn <buffer> <C-m> :<C-u>call Tmux_send(';Enter')<CR>
        " nn <buffer> <C-m> :<C-u>call Tmux_send([';', 'Enter'])<CR>
        nn <buffer> <C-m> :<C-u>call Tmux_send([';', 'Enter'],'', 1)<CR>
        nn <buffer> <C-p> :<C-u>call Tmux_send('C-p')<CR>
        nn <buffer> <C-n> :<C-u>call Tmux_send('C-n')<CR>
        nn <buffer> <C-u> :<C-u>call Tmux_send('C-u')<CR>
        nn <buffer> q :<C-u>call Tmux_send('q')<CR>
        nn x :<C-u>call Tmux_send(GetInput('sql-command to execute: '))<CR>
        let b:__saved_mapping =  Save_mappings(['x'],'n',1)
        " let b:__saved_mapping_c =  Save_mappings([';'],'c',1)
        " cunmap ;
    else
        echo 'Toggle_mode_tmux_sql off'
        let b:_b_Toggle_mode_tmux_sql = 0
        call Restore_mappings(b:__saved_mapping)
        " call Restore_mappings(b:__saved_mapping_c)
        nunmap <buffer> l
        nunmap <buffer> <C-j>
        nunmap <buffer> <C-m>
        nunmap <buffer> <C-p>
        nunmap <buffer> <C-n>
        nunmap <buffer> <C-u>
        nunmap <buffer> q
    endif
endfunc
nn <f8> :<C-u>call Toggle_mode_tmux_sql()<CR>

" " in a .sql file, exploration without to change to alternate tmux pane
" nn <C-j> :sil! !tmux send -t .+1 Enter >/dev/null<CR>:redraw!<CR>
" nn <C-p> :sil! !tmux send -t .+1 C-p >/dev/null<CR>:redraw!<CR>
" nn <C-l> :exec "!tmux send-keys -t .+1 '" . escape(getline('.'),';') . "'"<CR><CR>
" nn <C-u> :sil! !tmux send -t .+1 C-u >/dev/null<CR>:redraw!<CR>
