if exists('g:ft_gitcommit') | finish | endif
let g:ft_gitcommit = 1
au ft FileType gitcommit call ft_gitcommit#setup()

func! ft_gitcommit#setup() abort
    if !exists('b:git') | return 1 | endif
    nn <buffer> s :<C-u>call b:git.status()<CR>
    nn <buffer> q :<C-u>call b:git.commit_commit()<CR>
endfunc " ft_gitcommit#setup
call ft_gitcommit#setup()  " bootstrap
