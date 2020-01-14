if has('$VIM_TERMINAL') | finish | endif


augroup terminal
    autocmd!
    " bug: TerminalOpen not fire
    " TerminalOpen fires even hidden (no new window created)
    " -- use win_execute?
    " autocmd BufEnter * if getbufvar(expand('<abuf'), '&bt') == 'terminal' | set laststatus=1 | endif
    " autocmd BufLeave * if getbufvar(expand('<abuf'), '&bt') == 'terminal' | set laststatus=2 | endif
    " autocmd BufEnter * echom 'BufEnter' expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd BufLeave \!* echom 'BufLeave' expand('<amatch>') expand('<abuf>') expand('<afile>')
    " autocmd TerminalOpen *    echom "TerminalOpen" expand('<amatch>') expand('<abuf>') expand('<afile>')
augroup END " terminal

if !exists('g:terminal#init')
    " call terminal#init($TERMNR) " call manually for first TerminalOpen event.
if $depth <= 1
    nn <silent> d :<C-u>call term#switch(term#switchnr())<CR>
    ino <silent> d <Esc>:call term#switch(term#switchnr())<CR>
    tno <silent> d <C-w>:call term#switch(term#switchnr())<CR>
    nn <silent> <A-d> :<C-u>call term#switch(term#switchnr_gui())<CR>
    ino <silent> <A-d> <Esc>:call term#switch(term#switchnr_gui())<CR>
    tno <silent> <A-d> <C-w>:call term#switch(term#switchnr_gui())<CR>
    tnoremap jj <C-w>N
    nnoremap <silent> gm :<C-u>call term#switch_to_term_buffer(v:count)<CR>
    " nnoremap <silent> <C-z> :<C-u>call term#switch_to_term_buffer(v:count)<CR>
    " inoremap <silent> <C-z> <C-o>:call term#switch_to_term_buffer(v:count)<CR>
    " tnoremap <silent> <C-^> <C-w>:b #<CR>
    tnoremap <silent> <C-^> <C-w>:<C-u>call term#switch_to_term_buffer('cycle')<CR>
    " tnoremap go <C-w><C-w>|" cause problem when paste, eg, https://github.com/goldfeld/vim-seek
    tnoremap <silent> go <C-w>:call buf#go()<CR>
    tnoremap <silent> qo <C-w>:call buf#qo()<CR>
elseif $depth == 2
    set termwinkey=<C-L>
    tnoremap jj <C-L>N
endif " $depth <= 1
endif " !exists('g:terminal#init')
let g:terminal#init = 1

