if exists('*entry#init')
    finish
endif
func! entry#init() abort
endfunc " entry#init

" to bootstrap
" 1. copy or link this file to ~/.vim/autoload/entry.vim
" 2. put below line in you ~/.vimrc
" call entry#init() " which call bundle#init(), thus entry.vim in autoload directory, eg, ~/.vim/autoload.
" !ln -s `cygpath -w %` ~/.vim/autoload/%:t

" :profile start q.out
" :profile func *
" :profile file *
" h netrw-noload
" .+,'}-1s=/.*==
" .+,'}-1s@.*@let g:bundle_ignore += \['\0'\]@
" on cygwin64, profiling result
" YouCompleteMe slow 360ms, .vimrc itself slow 150ms. other 100ms.
let g:bundle_ignore = []
	:let g:loaded_netrw       = 1
	:let g:loaded_netrwPlugin = 1
let g:bundle_ignore += ['vim-dirvish']
" let g:bundle_ignore = ['dirbuf']
let g:bundle_ignore += ['YouCompleteMe']
let g:bundle_ignore += [['YouCompleteMe', 5]]
let g:bundle_ignore += [['vim-fugitive', 1.2]]
let g:bundle_ignore += [['vim-sneak', 1]]
let g:bundle_ignore += [['vim-unimpaired', 1.4]]
let g:bundle_ignore += [['vim-surround', 1.6]]
let g:bundle_ignore += [['tcomment_vim', 1.8]]
let g:bundle_ignore += [['asyncrun.vim', 2]]
let g:bundle_ignore += [['ultisnips', 1.1]]     " test for after/ directory
" {{{ below group cost 20 - 30 ms, 6 plugins
let g:bundle_ignore += ['ctrlp.vim']
" let g:bundle_ignore += ['ultisnips']
" let g:bundle_ignore += ['ack.vim']
" let g:bundle_ignore += ['emmet-vim']
" let g:bundle_ignore += ['vim-indent-object']
" let g:bundle_ignore += ['vim-snippets']
" }}}

call bundle#init("/cygdrive/e/notes/task/install/vim")
call bundle#init()
call bundle#start()

" source /cygdrive/e/notes/task/install/vim/main/plugin/init.vim

source /cygdrive/e/notes/.previmrc
source /cygdrive/e/notes/.vimrc

if !has('g:has_color_vanilla')
    try
        colorscheme vanilla
        let g:has_color_vanilla = 1
    catch /E185/
        let g:has_color_vanilla = 0
    endtry
elseif g:has_color_vanilla
    colorscheme vanila
endif
let g:st_winback = v:false
source /home/zyq3e/notes/swo/rc/color/vim-loop_theme.vim
sil! R

" call dirbuf#pwd(1)

" At this point do slow actions
" :profile pause
" :noautocmd qall!
