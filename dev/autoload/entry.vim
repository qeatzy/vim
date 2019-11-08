if exists('*entry#init')
    finish
endif
func! entry#init() abort
endfunc " entry#init
set nocp shortmess+=IF number relativenumber
nn q :q<CR>
nn gt <C-^>

" [+] if only current modified, [+3] if 3 modified including current buffer.
" [3] if 3 modified and current not, "" if none modified.
func! IsBuffersModified()
    " let cnt = len(filter(getbufinfo(), 'v:val.changed == 1'))
    " exclude terminal buffers
    let cnt = len(filter(getbufinfo(), 'v:val.changed == 1 && (getbufvar(v:val.bufnr, "&bt") != "terminal")'))
    return cnt == 0 ? '' : ( &modified ? ( '[+'. ( cnt > 1 ? cnt : '') . ']' ) : ( '['.cnt.']' ) )
endfunc

func! LineCountCurrentParagraph()
    return line("'}") - line("'{") + ((match(getline("'{"),'^\s*$') == -1) + (match(getline("'}"),'^\s*$') == -1) -1)
endfunc

let s:prevcountcache=[[], 0]
function! ShowCount(...)
    let key=[@/, b:changedtick]
    if s:prevcountcache[0]==#key
        return s:prevcountcache[1]
    endif
    let s:prevcountcache[0]=key
    let s:prevcountcache[1]=0
    let pos=getpos('.')
    try
        let result = 0
        if @/ != ''
            redir => subscount
            silent %s///ne
            redir END
            let result=matchstr(subscount, '\d\+')
        endif
        let s:prevcountcache[1]=result
        return a:0==0 ? result : (result <= a:1 ? result : a:1)
    finally
        call setpos('.', pos)
    endtry
endfunction

set ruf=%120([%n]%-10.30f\ \ %y%=%-20(%l/%L\ %P%)%)
set ls=2
set statusline=
set statusline+=%7*\[%n]                                  " buffernr
set statusline+=%1*%-10.30f\                                " File+path
set statusline+=%2*%<\ %y\                                  " FileType
set statusline+=%3*\ %{''.(&fenc!=''?&fenc:&enc).''}      " Encoding
set statusline+=%3*\ %{(&bomb?\",BOM\":\"\")}\            " Encoding2
set statusline+=%4*\ %{(&ff==\"unix\"?\"\":&ff)}\                              " FileFormat (dos/unix..) 
set statusline+=%8*\ %=\ %l/%L\ [%02p%%]  " Rownumber/total (%)
set statusline+=%9*\ %03c\                            " Colnr
set statusline+=%{LineCountCurrentParagraph()}
set statusline+=%0*\ %{IsBuffersModified()}%r%w\ %P\                      " Modified? Readonly? Top/bot.
set statusline^=%{ShowCount(999)}
if version >= 700
    au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
    au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
endif


" to bootstrap
" 1. copy or link this file to ~/.vim/autoload/entry.vim
" 2. put below line in you ~/.vimrc
" call entry#init() " which call bundle#init(), thus entry.vim in autoload directory, eg, ~/.vim/autoload.
" !cd ~/.vim/autoload && ln -s %:p:h/bundle.vim && ln -s %:p:h/entry.vim
" !rm ~/.vim/autoload/{bundle,entry}.vim;

" :profile start q.out
" :profile func *
" :profile file *
" h netrw-noload
" .+,'}-1s=/.*==
" .+,'}-1s@.*@let g:bundle_ignore += \['\0'\]@
" on cygwin64, profiling result
" YouCompleteMe slow 360ms, .vimrc itself slow 150ms. other 100ms.
let g:bundle_ignore = []
	let g:loaded_netrw       = 1
	let g:loaded_netrwPlugin = 1
let g:bundle_ignore += ['\.git']
let g:bundle_ignore += ['vim-dirvish']
"let g:bundle_ignore += [['dev',0.2]]      " concat dev/plugin/*.vim to tmp/plugin/zz.vim see dev/doc/profile.txt
let g:bundle_ignore += [['dev', [0.3,5.2]]]
" let g:bundle_ignore += ['tmp']
" let g:bundle_ignore += [['tmp', 200]]
" let g:bundle_ignore += ['dev']
let g:bundle_ignore += ['dirbuf']
" let g:bundle_ignore += [['main', [0,6]]]
let g:bundle_ignore += ['main']
let g:bundle_ignore += ['YouCompleteMe']
let g:bundle_ignore += [['YouCompleteMe', 5]]
let g:bundle_ignore += [['vim-fugitive', 1.2]]
let g:bundle_ignore += [['vim-sneak', 1]]
let g:bundle_ignore += [['vim-unimpaired', 1.4]]
let g:bundle_ignore += [['vim-surround', 1.6]]
let g:bundle_ignore += [['tcomment_vim', 1.8]]
let g:bundle_ignore += [['LeaderF', 3]]
let g:bundle_ignore += [['ultisnips', 2.0]]     " test for after/ directory
"                   not function well, try if load normally solve it.
"                   if it after orfer wrong?
"                   seems no by load order, maybe vim.snippets format wrong, or
"                   bug.
" below for ignore
let g:bundle_ignore += [['asyncrun.vim', 2.2]]
let g:bundle_ignore += [['vim-commentary', 2.4]]
" let g:bundle_ignore += [['vim-indent-object', 2.6]]
" {{{ below group cost 20 - 30 ms, 6 plugins
let g:bundle_ignore += ['ctrlp.vim']    " lazy load on CmdUndefined
" let g:bundle_ignore += ['ultisnips']
let g:bundle_ignore += ['ack.vim']
let g:bundle_ignore += ['emmet-vim']
" let g:bundle_ignore += ['vim-indent-object']
" let g:bundle_ignore += ['vim-snippets']
" }}}

call bundle#init($HOME . "/.vim/vim")
call bundle#start('')   " same as call bundle#init()  + call bundle#start()

" call bundle#start()

" call utils#init()

" source /cygdrive/e/notes/task/install/vim/main/plugin/init.vim

" source $HOME/notes/.previmrc
" source $HOME/notes/.vimrc

" if !has('g:has_color_vanilla')
"     try
"         colorscheme vanilla
"         let g:has_color_vanilla = 1
"     catch /E185/
"         let g:has_color_vanilla = 0
"     endtry
" elseif g:has_color_vanilla
"     colorscheme vanila
" endif
" let g:st_winback = v:false
" source /home/zyq3e/notes/swo/rc/color/vim-loop_theme.vim
" sil! R

" call dirbuf#pwd(1)

" At this point do slow actions
" :profile pause
" :noautocmd qall!
