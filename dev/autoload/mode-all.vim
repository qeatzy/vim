
func! SetMode(mode) abort
    exec 'nn <f8> :<C-u>call ' . g:modes[a:mode] . '()<CR>'
    exec 'call ' . g:modes[a:mode] . '()'
endfunc
let g:modes = {'python': 'Toggle_mode_tmux_python', 'color': 'Toggle_mode_loop_theme'}
func! ModeCandidates(A,L,P)
    return filter(keys(g:modes), 'v:val =~ a:A')
endfunc
com! -nargs=1 -complete=customlist,ModeCandidates Mode call SetMode(<q-args>)

" call CmdAlias('mode', 'Mode')
" call CmdAlias('mod', 'Mode')
" call CmdAlias('mo', 'Mode')
