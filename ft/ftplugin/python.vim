let $PYTHON_EXE='C:/pkg/dt/python3.7.4/python.exe'

nn <buffer> <space>r :<C-u>call VerifyPyExeThenRun(expand('%'))<CR>

if getline(1) =~ 'pygame' | argadd /cygdrive/e/notes/task/install/vim/snippet/pygame-identifiers.py |endif
