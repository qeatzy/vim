" you may not need filetype on

" reload setting for all *.vim buffer
    " bufdo! if expand('%') =~ '\.vim$' | call ft_vim#init() |endif

func! ft#load(ft)
    if has_key(s:ft, a:ft)
        return
    endif
    let s:ft[a:ft] = 1
    let $FT = a:ft
    runtime ft/ft_$FT.vim   " need bootstrap itself
endfunc " ft#load
augroup ft_init
    autocmd!
    autocmd FileType * call ft#load(expand('<amatch>'))
augroup END " ft_init
augroup ft
    autocmd!
augroup END " ft

if !exists('g:ft_ft')
    let s:ft = {}
    " fix: call manually for first filetype being set.
    if exists('$FT')
        call ft#load($FT)
    endif
endif
    let g:ft_ft = 1

func! ft#all()
    return s:ft
endfunc " ft#all

func! ft#clear() abort
    sil! au! ft *
endfunc " ft#clear
" if !exists('g:ft_ft')
"     let g:ft_ft = 1
"     runtime autoload/ft.vim      " source itself
"     " fix: call manually for first filetype being set.
"     if exists('$FT')
"         runtime ft/$FT.vim
"     endif
"     " finish
" endif

" au FileType vim ++once runtime ft/ft_vim.vim

" " func! ft#init(ft)
" " endfunc " ft#init
