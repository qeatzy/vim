" if exists('g:ft_git') | finish | endif
let g:ft_git = 1
au ft FileType git call ft_git#setup()

func! ft_git#setup() abort
    nn <buffer> a :<C-u>call git#do_files(var#curline(v:count1),'add')<CR>
    nn <buffer> u :<C-u>call git#do_files(var#curline(v:count1),'reset')<CR>
    nn <buffer> s :<C-u>call git#status()<CR>
endfunc " ft_git#setup
" call ft_git#setup()  " bootstrap


