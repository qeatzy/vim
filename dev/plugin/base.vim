
if !exists('g:os')     " -- allow overridding
    if has("win32unix")
        let g:os = "cygwin"
    elseif has('win32')
        let g:os = "windows"
    elseif has('unix')
        let g:os = "unix"
    endif
endif


" set directory^=$ROOT/.vimswap//|" move to entry.vim to avoid .swp
" -- below caused by lazy load of dev, not bug. (set dir in .vimrc fix it.)
" cygwin 64, vim 8.1.1772, bug, always create .swp in current directory, for
" empty file name, eg, 'vi' the first buffer is [No name]. others works
" correctly. fixed by workaroud, ' vi -c "set dir=~/.vim/.vimswap//"'
" or fixed by put 'set dir=~/.vim/.vimswap//' in .vimrc's last line.
" set directory=~/.vim/.vimswap//,~/tmp,/var/tmp,/tmp
" comma separated string, first usable one will be used. directory ending with '//' using full pathname.
set ignorecase smartcase
set nohlsearch incsearch
set hidden
set autoread
set noautochdir

let &clipboard = g:os != 'unix' ? 'unnamed' : 'unnamedplus'

nn Y y$

"tab
autocmd TabNew * ++once call tab#init()

"fn, see "" file
" call graphical file manager
if g:os == 'cygwin' " executable('explorer')
command! -nargs=? FM !explorer <args> &
endif
command! -nargs=? -complete=customlist,PathCompleteList VV e %:p:h/<args>
call CmdAlias('le', 'VV')
command! -nargs=? TMUX !tmux neww -c %:p:h/<args>
call CmdAlias('tmux', 'TMUX')
" also config dirvish to achieve same func


MapToggle <F1> hlsearch
cnoremap <expr> <F1> (getcmdtype() =~# '[/\?]')? OptToggle('hlsearch') : '<F1>'

vnoremap <F2> :<c-u>exec join(getline("'<","'>"),"\n")<CR>
nnoremap <silent> <F2> :<C-u> exec v:count1 == 1 ? getline('.') : join(getline('.',line('.')+(v:count1-1)), "\n") <CR>

inoremap s <Esc>:up<CR>
nnoremap s :up<CR>

set viminfo='1024,f1,%1024,h
