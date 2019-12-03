" " set nocp
" " https://vi.stackexchange.com/questions/2572/detect-os-in-vimscript
" if !exists('g:os')     " -- allow overridding
"     if has("win32unix")
"         let g:os = "cygwin"
"     elseif has('win32')
"         let g:os = "windows"
"     elseif has('unix')
"         let g:os = "unix"
"     endif
" endif
"
" let s:dir = expand('<sfile>:p')
" let s:root = fnamemodify(s:dir, ':h:h:h')
"
" call main#init()
" call tobject#init()
"
"
" let a0 = s:root
"
" if match(&rtp,'ultisnips') != -1
" " if bundle#has('ultisnips')
"     let g:UltiSnipsUsePythonVersion = 3
"     let g:UltiSnipsSnippetDirectories=[ '/cygdrive/e/notes/task/install/vim/snippet']
"     " If the list has only one entry that is an absolute path, UltiSnips will not
"     " iterate through &runtimepath but only look in this one directory for snippets.
"     " This can lead to significant speedup. This means you will miss out on snippets
"     " that are shipped with third party plugins. You'll need to copy them into this
"     " directory manually.
" endif " ultisnips
