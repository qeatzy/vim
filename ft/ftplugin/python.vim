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
