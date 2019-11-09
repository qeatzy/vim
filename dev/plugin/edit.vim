" imap only & both, for cmap only see cmap.vim

"indent-option, see " fmt
set tabstop=4       |" Number of spaces that a <Tab> in the file counts for. eg, used for print.
set shiftwidth=4    |" used by '=' and '<' '>' to format indent.
set softtabstop=4   |" used by <BS> in insert mode, and <Tab> for insert tab. If 'smarttab' is on, shiftwidth is used instead.
" set smarttab        |" default off. if on use shiftwidth for <BS>, if off use softtabstop.
set expandtab       |" expand tab for both inserting <Tab> in insert mode, and '=' '>' '<' commands.
set autoindent      |" inherit indent of previous line
set shiftround      |" round space to multiple of shiftwidth
" :retab
set backspace=indent,eol,start   " Set for maximum backspace smartness

set number
set relativenumber 
nnoremap \n :set number! relativenumber!<CR>

ino jj <Esc>
ino <C-e> <End>
ino <C-f> <Right>
ino <C-b> <Left>
noremap! b <S-Left>|" <Alt-b> move word back        -- both insert and cmdline mode
noremap! f <S-Right>|" <Alt-f> move word forward

ino <C-r><C-r> <C-r>=
ino <C-r>r <C-r>=
ino <expr> <C-r> imap#getchar()
iunmap <C-r>
ino <expr> <C-r> imap#ctrl_r()

nn oo o<CR>

"line
nn dp "_d$|" diffput is original
nn cp "_c$
" nn <Space>d :t.<CR>
nn <Space>d :<C-u>call edit#duplicate_current_line(v:count1)<CR>
" ino <S-CR> <C-o>o|" <S-Enter> to add a new line, like in pycharm
ino  <C-o>o|" on cygwin, <C-Enter> works, <S-Enter> not work
ino m <C-o>o|" Alt-m
nn \d :g//d_<CR>
nn \v :v//d_<CR>

"cms
nn g[ :Commentary<CR>|" accept count


"repeat
nn . :<C-u>call edit#repeat(v:count1)<CR>|" fix repeat of cgn, and https://github.com/hauleth/sad.vim
