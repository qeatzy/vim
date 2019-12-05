if exists('g:ft_git') | finish | endif
let g:ft_git = 1
au ft FileType git call ft_git#setup()

func! ft_git#setup() abort
    nn <buffer> a :<C-u>call b:git.add(var#curline(v:count1))<CR>
    nn <buffer> u :<C-u>call b:git.reset(var#curline(v:count1))<CR>
    nn <buffer> s :<C-u>call b:git.status()<CR>
    nn <buffer> cc :<C-u>call b:git.commit()<CR>
    " nn <buffer> ca :<C-u>call b:git.commit('--amend')<CR>
    nn <buffer> ca :<C-u>exec '!cd '. b:git.root .'&& git commit --amend'<CR>
endfunc " ft_git#setup
call ft_git#setup()  " bootstrap
