if exists('g:ft_dirbuf')
    finish
endif
let g:ft_dirbuf = 1
au ft filetype dirbuf call dirbuf#setup()
call dirbuf#setup()  " bootstrap
