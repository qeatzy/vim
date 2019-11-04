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

ino <C-r><C-r> <C-r>=
ino <C-r>r <C-r>=
ino <expr> <C-r> imap#getchar()
iunmap <C-r>
ino <expr> <C-r> imap#ctrl_r()

