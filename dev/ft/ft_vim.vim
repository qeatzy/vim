" sourced if filetype been set as vim
if !exists('*AutoSource')
    let s:AutoSource_counter = 0
    let g:AutoSource = {}
    augroup AutoSource
        autocmd!
    augroup END " AutoSource
endif
func! AutoSource(filename)
    let filename = len(a:filename) <= 1 ? expand('%') : a:filename
    let filename = path#abspath(filename)
    echo 'so ' . a:filename
    if !has_key(g:AutoSource, filename)
        exec 'so ' . filename
        exec 'au AutoSource BufWritePost ' . filename . ' so ' . filename
        let g:AutoSource[filename] = get(g:AutoSource, filename) + 1
    endif
endfunc " AutoSource

" func! Test_cmdline_expand(...)
"     echo a:000
" endfunc " Test_cmdline_expand
" com! -nargs=1 SO call Test_cmdline_expand(<q-args>)
" com SO
" SO %
" h <q-args>

" buffer-local
func! ft_vim#init()
    " nn <buffer> <F10> :<C-u>echo %<CR>
    nn <buffer> <F10> :<C-u>call AutoSource('%')<CR>
    nn <buffer> ;c :<C-u>call SetOpfunc('cms#vim')<CR>g@
    nn <buffer> gc :<C-u>call SetOpfunc('cms#cms_vim')<CR>g@
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
    autocmd ft FileType vim call ft_vim#init()
endif
    let ft#vim += 1
