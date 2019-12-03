" " echom v:exception
" let g:a = '    ' . v:errmsg
" " let g:a = v:errors
"
" " intended to be wrapper to some, that is
" " call debug#somefunc(...) will delegate to xxdebug#somefunc()
" " also xxdebug#init() will reload itself if changed
"
" if !exists('g:debugfile')
"     finish
" else
"     let file = fnamemodify(debugfile, ':t')
"     let nfile = matchstr(file, '^\(\w\+\)\.vim$')[:-5]
"     if nfile == ''
"         echom "debugfile name invalid: " debugfile
"         finish
"     endif
"     " echo file
" endif
"
" " intended to wrapper, seems not practical
" de
" delfunc dirbufdebug#check
" echo debug#init('/cygdrive/e/notes/task')
" echo debug#check('/cygdrive/e/notes/task')
" echo e
" echo a "| " b  "|" c "|" d
" set rtp+=/cygdrive/e/notes/task/install/vim/dirbuf
" unlet g:a
" h :rtp
"
" let g:b = matchstr(v:errmsg, 'E117:.* debug#')
" let g:c = v:errmsg[len(g:b):]
" let funcname = v:errmsg[len(g:b):]
" if funcname =~# '^[a-zA-Z]\w*'
"     let g:d = nfile . '#' . g:c
"     exec 'let g:e = ' . g:d . '("/cygdrive/e/notes/task/install/vim")'
"     let cmd = 'func! ' . funcname . '(arg)' .
"             \ '| return ' . nfile . '#' . funcname . '(a:arg)' .
"             \ '| endfunc'
"     func! s:do_callback(cmd)
"         let cmd = copy(a:cmd)
"     echom "to timer "  " execute [" cmd "]"
"     let timer = timer_start(10, {timer -> execute(cmd)})
"     echom "timer" timer  " execute [" cmd "]"
"     endfunc
"     call s:do_callback(cmd)
" endif
"
" if !exists('s:debugfile')
"     let s:debugfile = g:debugfile
" endif
"
" func! debug#init(...)
"     return getftime('/cygdrive/e/notes/task/install/vim/dirbuf/autoload/debug.vim')
" endfunc
"
" " v:beval_bufnr
" " v:beval_col
" " v:beval_lnum
" " v:beval_text
" " v:beval_winid
" " v:beval_winnr
" " v:char
" " v:charconvert_from
" " v:charconvert_to
" " v:cmdarg
" " v:cmdbang
" " v:completed_item
" " v:count
" " v:count1
" " v:ctype
" " v:dying
" " v:errmsg
" " v:errors
" " v:event
" " v:exception
" " v:false
" " v:fcs_choice
" " v:fcs_reason
" " v:fname
" " v:fname_diff
" " v:fname_in
" " v:fname_new
" " v:fname_out
" " v:folddashes
" " v:foldend
" " v:foldlevel
" " v:foldstart
" " v:hlsearch
" " v:insertmode
" " v:key
" " v:lang
" " v:lc_time
" " v:lnum
" " v:mouse_col
" " v:mouse_lnum
" " v:mouse_win
" " v:mouse_winid
" " v:none
" " v:null
" " v:oldfiles
" " v:operator
" " v:option_command
" " v:option_new
" " v:option_old
" " v:option_oldglobal
" " v:option_oldlocal
" " v:option_type
" " v:prevcount
" " v:profiling
" " v:progname
" " v:progpath
" " v:register
" " v:scrollstart
" " v:searchforward
" " v:servername
" " v:shell_error
" " v:statusmsg
" " v:swapchoice
" " v:swapcommand
" " v:swapname
" " v:t_blob
" " v:t_bool
" " v:t_channel
" " v:t_dict
" " v:t_float
" " v:t_func
" " v:t_job
" " v:t_list
" " v:t_none
" " v:t_number
" " v:t_string
" " v:termblinkresp
" " v:termrbgresp
" " v:termresponse
" " v:termrfgresp
" " v:termstyleresp
" " v:termu7resp
" " v:testing
" " v:this_session
" " v:throwpoint
" " v:true
" " v:val
" " v:version
" " v:versionlong
" " v:vim_did_enter
" " v:warningmsg
" " v:windowid
"
"
