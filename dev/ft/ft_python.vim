if exists('g:ft_python')
    finish
endif
let g:ft_python = 1
au ft filetype python call ft_python#setup()

func! ft_python#setup() abort
    nn <buffer> ;c :<C-u>call SetOpfunc('cms#python')<CR>g@
    nn <buffer> gc :<C-u>call SetOpfunc('cms#cms_python')<CR>g@
endfunc " ft_python#setup
call ft_python#setup()  " bootstrap

" /cygdrive/e/nnotes/dev/vim/ft/ftplugin/python.vim
let $PYTHON_EXE='C:/pkg/dt/python3.7.4/python.exe'

nn <buffer> <space>r :<C-u>call VerifyPyExeThenRun(expand('%'))<CR>

if !exists('*s:pygame')
func! s:pygame() abort
    argadd /cygdrive/e/notes/task/install/vim/dev/snippet/pygame-identifiers.py 
    set ft=python.pygame
endfunc " s:pygame
endif

argadd /cygdrive/e/notes/task/install/vim/dev/snippet/python-identifiers.py
if getline(1) =~ 'pygame' | call s:pygame() |endif

" /cygdrive/e/nnotes/dev/vim/ft/plugin/python.vim
    if $PYTHON_EXE =~ '^[-_. :/a-zA-Z0-9]\+$'
        " echo 'match'
        let s:python_exe = $PYTHON_EXE
    else
        " echo 'not match'
        let s:python_exe = 'python3'
    endif
func! VerifyPyExeThenRun(file) abort
    let pyexe = get(b:, 'pyexe', $PYTHON_EXE)
    if pyexe !~# '^[-_. :/a-zA-Z0-9]*python[0-9.]*\(\.exe\)\?$'
    " echo 'C:/pkg/dt/python3.7.4/python.exe' !~# ''
        let pyexe = 'python3'
    endif
    let py_opt = (has_key(b:, 'py_opt') ? b:py_opt : get(g:, 'py_opt', ''))
    if py_opt !~# '^-["'' a-z-]\+$'     " -m pdb -c 'until 33'
        let py_opt = ''
    else
        let py_opt = escape(py_opt, "\"'")
    endif
    let py_redir = (has_key(b:, 'py_redir') ? b:py_redir : get(g:, 'py_redir', ''))
    echom "[py_redir]" py_redir
    let py_redir = (py_redir =~# '^[-_ ./:0-9a-zA-Z]\+$') ? (" > '" . py_redir . "'") : ''
    echom "[py_redir]" py_redir "after"
    let file = substitute(a:file, '^/cygdrive/\([c-z]\)/', '\1:/', '')
    let cmd = '!"' . pyexe . '" ' . py_opt . ' "' . file . '"' . py_redir
    echom "cmd [" . cmd . "]"
    exec cmd
endfunc " VerifyPyExeThenRun
