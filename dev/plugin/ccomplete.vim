" h glob
" h command-complete
" h command-completion-custom
func! PathCompleteList(ArgLead, CmdLine, CursorPos) abort
    let path = expand('%:p:h')
    let cand = glob(path .  '/' . a:ArgLead . '*', 1, 1)
    let n = len(path) + 1
    return map(cand, 'v:val[n:]')
endfunc

cno <silent> <expr> <c-x> '<c-a>'.timer_start(0, {-> setreg('+', substitute(getcmdline(), ' \\|\(^\w\+ \)\\|^', "\n", 'g')."\n\n", 'l') + feedkeys('<c-u><c-c>', 'int') })[-1]|"-- https://vi.stackexchange.com/a/14392/10254
"complete, see " 
set dictionary=~/notes/enDict.txt   |" List of file names used for i^x^k . 
set complete-=i " Don't scan includes, since it can be very slow.
" inoremap <C-f> <C-x><C-f>

