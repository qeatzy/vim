
func! run#cmdhist() abort
    let x = map(copy(g:scratch), 'getbufvar(v:val, "runcmd")')
    return x
endfunc

func! run#bufnr(cmd) abort
    let x = map(copy(g:scratch), 'getbufvar(v:val, "runcmd")')
    let idx = index(x, a:cmd)
    return idx >= 0 ? g:scratch[idx] : '%'
endfunc

func! run#setup() abort
    nn <buffer> i :<C-u>exec 'b' . run#bufnr(getline('.'))<CR>
endfunc

func! run#writelines(lines) abort
    " return a file that no need to shell escape
    let fn = tempname()
    call writefile(a:lines, fn)
    return fn
endfunc " run#writelines

func! run#runbash(lno, cnt) abort
    let fn = run#writelines(getline(a:lno, a:lno + a:cnt - 1))
    exec '!bash ' . shellescape(fn)
endfunc " run#runbash

func! run#capturebash(lno, cnt) abort
    let cmd = getline(a:lno, a:lno + a:cnt - 1)
    let fn = run#writelines(cmd)
    " let [shell, shellcmdflag] = [&shell, &shellcmdflag]
    " let [&shell, &shellcmdflag] = ['bash', '']
    " exec '!bash ' . shellescape(fn)
    let output = systemlist(shellescape(fn))
    let nr = buf#nextscratch()
    call setbufvar(nr, 'runcmd', cmd[0] . (len(cmd)>1 ? " (" . len(cmd) . ")" : ""))
    call buf#setline(nr, output)
    exec nr . 'b'
    " let g:o=output
    " let [&shell, &shellcmdflag] = [shell, shellcmdflag]
endfunc " run#capturebash

func! PutAfterCapture(command)
    if a:command =~ '^\s*$'
        return
    endif
    let oldpos = getpos('.')
    silent! let result = Capture(a:command)
    " :put =Capture(a:command)     " use '=' register, not to clutter register.
    " a:command may change cursor position
    call setpos('.', oldpos)
    put=result
    " put change cursor position
    call setpos('.', oldpos)
endfunc!

func! GetInput(hint)    " https://stackoverflow.com/a/15274117/3625404
    call inputsave()
    let cmd = input(a:hint)
    call inputrestore()
    return cmd
endfunc

func! run#GetInputCommandThenCaptureAndPut()
    " cmdline keymap works, eg, <C-k> to get last input, <C-f> to open edit window, <C-r> insert register, ';' to cancel and exit.
    let cmd = GetInput('ex-command to execute: ')
    if cmd =~ '^\s*!'   " eg, '!ls', '!ll', redraw needed.
        exec 'r'.cmd
        redraw!
    elseif cmd =~ '^ [[.a-zA-z0-9].*'    " one space before shell command, add '!', then run and read.
        if cmd == ' ns'
            term ++curwin nvidia-smi
        else
            " exec 'r!' cmd
            call CaptureShellCommand(cmd)
        endif
    elseif cmd =~ '^	[[.a-zA-z0-9].*'  " leading '<Tab>' key, execute shell command, witout capture.
        exec '!' cmd
    else
        if strlen(cmd) == 1     " customized shortcut
            if cmd == 's'
                let cmd = 'scr'
            elseif cmd == 'k' || cmd == 'm'   " :k is alias of :mark
                let cmd = 'marks'
            endif
        elseif cmd =~ '^\s*''\(\w*\)''\?\s*$'   " option start with single quote, closing one optional.
            let cmd = 'set '. substitute(cmd, '^\s*''\(\w*\)''\?\s*$', '\1', '').'?'
            " let cmd = 'set '.cmd.'?'
        endif
        let command = matchstr(cmd, '\w\+')
        if strlen(command) == 0
        elseif exists(':'.command)
            " breaks for '%!uniq'
            " if strgetchar(cmd,1) == 37  " first char is '%'
            "     call PutAfterCapture('\'.cmd)
            " else
                call PutAfterCapture(cmd)
            " endif
        else    " not ex command, try run and read shell command.
            call CaptureShellCommand(cmd)
        endif
    endif
endfunc

func! run#r(...) abort
    let c = getchar()
    " echo c type(c)
    let ch = nr2char(c)
    if ch ==# 'r'
        exec 'norm! r' . nr2char(getchar())
        return
    endif
    if ch ==# 'c'
        let nr = buf#nextscratch()
        " let job = job_start(getline('.'), {'out_io':'buffer','out_buf':nr})
        let job = job_start(getline('.'), {'out_io':'buffer','out_buf':nr})
        exec 'nn gh :<C-u>b ' . nr . '<CR>'
        call io#notify('')
    elseif ch ==# 'p'
        pu +    " no cygwin, + `:reg +` show reg *, `:pu +` use reg *
    elseif ch ==# 's'
       set opfunc=edit#gn_motion_old
       " set opfunc=sad#search_and_replace_forward
       " exec 'norm! "' . v:register . 'g@'
       call feedkeys('"' . v:register . 'g@', 'n')
    elseif ch ==# '*'   " motion, /\<word\>/e<CR>
        call feedkeys('/\<' . expand('<cword>') . '\>/e' . "\<CR>", 'n')
    else
        call feedkeys('r' . ch, 'n')
    endif
endfunc " run#r
