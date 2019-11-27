" sourced if filetype been set as vim


" buffer-local
func! ft_vim#init()
    nn <buffer> <F10> :<C-u>so %<CR>
    setlocal dict+=$ROOT/vim/dev/dict/vim.txt
" or use tag files, which YCM support.
" https://github.com/ycm-core/YouCompleteMe/issues/138
    set isf-=$,+,=
    setlocal isk+=:
endfunc " ft_vim#init

if !exists('ft#vim')
    let ft#vim = 1
    let g:x = bufnr('%')
    call ft_vim#init()  " fix first time being set. see ft.vim
    autocmd FileType vim call ft_vim#init()
endif
    let ft#vim += 1
