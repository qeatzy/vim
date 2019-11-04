" exec 'source ' . expand('<sfile>:p:h') . '/utils.vim'

let s:_f_pythonrc = expand('<sfile>:p:h') . '/.pythonrc'
let s:pythonrc = filereadable(s:_f_pythonrc) ? readfile(s:_f_pythonrc) : []
func! Run_python(lines) abort
    let cmd = s:pythonrc + a:lines
    let fn = tempname()
    call writefile(cmd, fn)
    let py_redir = (has_key(b:, 'py_redir') ? b:py_redir : get(g:, 'py_redir', ''))
    let py_prefix = (has_key(b:, 'py_prefix') ? b:py_prefix : get(g:, 'py_prefix', ''))
    let py_exe = 'python3'
    let cmd = printf('!%s %s %s %s', py_prefix, py_exe, fn, (py_redir == '' ? '' : ' >' .py_redir))
    exec cmd
endfunc

func! Tmux_escape_line(s, target)
    let s = a:s
    " let s = substitute(s,"\t"," ","g")
    "           '"'"'
    if s =~ "'"
        let s = substitute(s,"'",'''"''"''',"g")
    endif
    let s = "send-keys -l " . a:target . "'" . s . "'\\; send-keys " . a:target . " Enter\\; \\"
    return s
endfunc

" works for zsh, psql, python.
" muti-line, not work for ipython
" each line is a tmux send-keys.  one process of tmux, since sub-command separated with ; (\; to escape).
func! Tmux_send_lines(lines) abort
    let target = (has_key(b:, 'tm_opt') ? b:tm_opt : get(g:, 'tm_opt', ' -t .+1 '))
    let lines = a:lines
    let lines = map(lines, 'Tmux_escape_line(v:val, target)')
    let lines[0] = 'tmux ' . lines[0]
    " let fn = WriteLinesToFile(lines + ['first'])
    let fn = WriteLinesToFile(lines)
    call system('bash ' . fn . ' &>/dev/null')
    redraw!
endfunc

func! Tmux_escape(s)
    let s = a:s
    " let s = substitute(s,"\t"," ","g")
    "           '"'"'
    let s = substitute(s,"'",'''"''"''',"g")
    return s
endfunc

" works for zsh, psql, python.
" one pass, not work for ipython
" each line is a tmux send-keys.  one process of tmux, since sub-command separated with ; (\; to escape).
" usage, vim in one tmux pane, another pane `python3 >p.out`, then use `<space>j`
"   and `l` to redirect to python, the output will be flushed to `p.out` line by line.
"     also use IndentObject  onoremap ii ia ai aa. zfii to add fold, zo/zc open/close.
"   the only problem is, you can not edit the `p.out`, otherwise you lose output afterwards.
"     fix?, maybe use `>>p.out` instead.  (not work, still lose output)
"     fix?, try `python3 |tee -a p.out` (not work, still lose output)
"     try redirect to 2 files. zsh `cmd >log1 >log2`, bash `cmd |tee log1 > log2` (tee -a to append)
"      https://unix.stackexchange.com/questions/41246/how-to-redirect-output-to-multiple-log-files
" files ignore in jianguoyun, xx yy xout  http://help.jianguoyun.com/?p=1825
"   can not match pattern, only affect root directory. add *.xx and *.out instead (this works)
"   p.out for python's output
func! Tmux_send_lines_one_pass(lines, ...) abort
    let append_new_line = get(a:, 1, 1)
    let cmd = 'tmux send-keys' . (has_key(b:, 'tm_opt') ? b:tm_opt : get(g:, 'tm_opt', ' -t .+1 -l ')) . "'"
    let lines = a:lines
    let lines = map(lines, 'Tmux_escape(v:val)')
    let lines[0] = cmd . lines[0]
    let lines[-1] .= (append_new_line ? "\015'" : "'")
    let fn = WriteLinesToFile(lines)
    call system('bash ' . fn . ' &>/dev/null')
    redraw!
endfunc

func! Tmux_escape_tmux_each_line(s, target) abort
    let s = a:s
    " let s = substitute(s,"\t"," ","g")
    "           '"'"'
    if s =~ "'"
        let s = substitute(s,"'",'''"''"''',"g")
    endif
    let s = "tmux send-keys -l " . a:target . "'" . s . "\015'"
    return s
endfunc

" do not use this, each line fork a tmux process. only to workaround ipython
" why above method fail for ipython? might be tmux loose some key event when type fast.
func! Tmux_send_lines_tmux_each_line(lines) abort
    let target = (has_key(b:, 'tm_opt') ? b:tm_opt : get(g:, 'tm_opt', ' -t .+1 '))
    let lines = a:lines
    let lines = map(lines, 'Tmux_escape_tmux_each_line(v:val, target)')
    " let lines[0] = 'tmux ' . lines[0]
    " let fn = WriteLinesToFile(lines + ['first'])
    let fn = WriteLinesToFile(lines)
    call system('bash ' . fn . ' &>/dev/null')
    redraw!
endfunc


func! Tmux_send_lines_another(lines) abort
    let cmd = 'tmux ' . has_key(b:, 'tm_opt') ? b:tm_opt : get(g:, 'tm_opt', ' -t .+1 -l ')
    let lines = a:lines
    let lines[0] = cmd . lines[0]
    call WriteLinesToFile(lines + ['another'])
endfunc



" call Run_python(['33'])
nnoremap <space>j mo:call SetOpfunc('Tmux_send_lines_one_pass')<CR>g@
nnoremap <space>k mo:call SetOpfunc('Tmux_send_lines')<CR>g@
" nnoremap <space>k mo:call SetOpfunc('Tmux_send_lines_tmux_each_line')<CR>g@
" autocmd Filetype python nn <buffer> <space>r :<C-u>call Run_python(getline(1,'$'))<CR>
