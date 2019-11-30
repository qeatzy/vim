if exists('*entry#init')
    finish
endif
" set shortmess+=W
" set shortmess+=filmnrwxaoOstTWAIcqFS

func! entry#init() abort
endfunc " entry#init
    autocmd GUIEnter * runtime autoload/gvim.vim
set nocp shortmess+=IF number relativenumber
let &rtp = substitute(&rtp,'\','/','g')
let $ROOT = matchstr(&rtp, '^[^,]*') . '/'
let $depth = $depth + 1
set isfname=@,48-57,/,.,-,_,~,$
nn q :q<CR>
nn gt <C-^>
set tabstop=4       |" Number of spaces that a <Tab> in the file counts for. eg, used for print.
set nobackup swapfile undofile
set undodir^=$ROOT/.vimundo//
set directory^=$ROOT/.vimswap//
au BufEnter * ++once if isdirectory(bufname('%')) | so $ROOT/vim/dev/autoload/path.vim | so $ROOT/vim/dev/autoload/dirbuf.vim | setlocal noswapfile | call dirbuf#openpath(bufname('%')) | call dirbuf#setup() | endif

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

set history=10000
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gb2312,gb18030,gbk,cp936,big5,euc-jp,euc-kr,latin1
"set fileencoding=utf-8|" not needed, local to buffer, cause buffer "[No Name]" changed

set ruf=%120([%n]%-10.30f\ \ %y%=%-20(%l/%L\ %P%)%)
set ls=2
let stl = '%{ShowCount(999)}'
let stl .= '%7*[%n]'                                  " buffernr
let stl .= '%1*%-10.30f '                                " File+path
let stl .= '%2*%< %y '                                  " FileType
let stl .= "%3* %{''.(&fenc!=''?&fenc:&enc).''}"     " Encoding
let stl .= '%3* %{(&bomb?",BOM":"")} '            " Encoding2
let stl .= '%4* %{(&ff=="unix"?"":&ff)} '                              " FileFormat (dos/unix..) 
let stl .= '%8* %= %l/%L [%02p%%]'  " Rownumber/total (%)
let stl .= '%9* %03c '                           " Colnr
let stl .= '%{LineCountCurrentParagraph()}'
let stl .= '%0* %{IsBuffersModified()}%r%w %P '                      " Modified? Readonly? Top/bot.
let &statusline=stl
if version >= 700
    au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
    au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
endif

au StdinReadPost * set bt=nofile    " pager mode, 'shell-cmd | vim -'
hi ErrorMsg term=standout ctermfg=15 ctermbg=36

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
let g:bundle_ignore += ['vim-easymotion']
let g:bundle_ignore += ['indent-object.vim']
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

call bundle#init($ROOT . "vim")
call bundle#start('')   " same as call bundle#init()  + call bundle#start()
finish

let g:x = []
aug MyTest
    autocmd!
" au BufAdd * ++once call add(g:x, "BufAdd")
" au BufCreate * ++once call add(g:x, "BufCreate")
" au BufDelete * ++once call add(g:x, "BufDelete")
" au BufEnter * ++once call add(g:x, "BufEnter")
" au BufFilePost * ++once call add(g:x, "BufFilePost")
" au BufFilePre * ++once call add(g:x, "BufFilePre")
" au BufHidden * ++once call add(g:x, "BufHidden")
" au BufLeave * ++once call add(g:x, "BufLeave")
" au BufNew * ++once call add(g:x, "BufNew")
" au BufNewFile * ++once call add(g:x, "BufNewFile")
" au BufRead * ++once call add(g:x, "BufRead")
" au BufReadCmd * ++once call add(g:x, "BufReadCmd")
" au BufReadPost * ++once call add(g:x, "BufReadPost")
" au BufReadPre * ++once call add(g:x, "BufReadPre")
" au BufUnload * ++once call add(g:x, "BufUnload")
" au BufWinEnter * ++once call add(g:x, "BufWinEnter")
" au BufWinLeave * ++once call add(g:x, "BufWinLeave")
" au BufWipeout * ++once call add(g:x, "BufWipeout")
" au BufWrite * ++once call add(g:x, "BufWrite")
" au BufWriteCmd * ++once call add(g:x, "BufWriteCmd")
" au BufWritePost * ++once call add(g:x, "BufWritePost")
" au BufWritePre * ++once call add(g:x, "BufWritePre")
" au CmdUndefined * ++once call add(g:x, "CmdUndefined")
" au CmdlineChanged * ++once call add(g:x, "CmdlineChanged")
" au CmdlineEnter * ++once call add(g:x, "CmdlineEnter")
" au CmdlineLeave * ++once call add(g:x, "CmdlineLeave")
" au CmdwinEnter * ++once call add(g:x, "CmdwinEnter")
" au CmdwinLeave * ++once call add(g:x, "CmdwinLeave")
" au ColorScheme * ++once call add(g:x, "ColorScheme")
" au ColorSchemePre * ++once call add(g:x, "ColorSchemePre")
" au CompleteChanged * ++once call add(g:x, "CompleteChanged")
" au CompleteDone * ++once call add(g:x, "CompleteDone")
" au CursorHold * ++once call add(g:x, "CursorHold")
" au CursorHoldI * ++once call add(g:x, "CursorHoldI")
" au CursorMoved * ++once call add(g:x, "CursorMoved")
" au CursorMovedI * ++once call add(g:x, "CursorMovedI")
" au DiffUpdated * ++once call add(g:x, "DiffUpdated")
" au DirChanged * ++once call add(g:x, "DirChanged")
" au EncodingChanged * ++once call add(g:x, "EncodingChanged")
" au ExitPre * ++once call add(g:x, "ExitPre")
" au FileAppendCmd * ++once call add(g:x, "FileAppendCmd")
" au FileAppendPost * ++once call add(g:x, "FileAppendPost")
" au FileAppendPre * ++once call add(g:x, "FileAppendPre")
" au FileChangedRO * ++once call add(g:x, "FileChangedRO")
" au FileChangedShell * ++once call add(g:x, "FileChangedShell")
" au FileChangedShellPost * ++once call add(g:x, "FileChangedShellPost")
" au FileEncoding * ++once call add(g:x, "FileEncoding")
" au FileReadCmd * ++once call add(g:x, "FileReadCmd")
" au FileReadPost * ++once call add(g:x, "FileReadPost")
" au FileReadPre * ++once call add(g:x, "FileReadPre")
" au FileType * ++once call add(g:x, "FileType")
" au FileWriteCmd * ++once call add(g:x, "FileWriteCmd")
" au FileWritePost * ++once call add(g:x, "FileWritePost")
" au FileWritePre * ++once call add(g:x, "FileWritePre")
" au FilterReadPost * ++once call add(g:x, "FilterReadPost")
" au FilterReadPre * ++once call add(g:x, "FilterReadPre")
" au FilterWritePost * ++once call add(g:x, "FilterWritePost")
" au FilterWritePre * ++once call add(g:x, "FilterWritePre")
" au FocusGained * ++once call add(g:x, "FocusGained")
" au FocusLost * ++once call add(g:x, "FocusLost")
" au FuncUndefined * ++once call add(g:x, "FuncUndefined")
" au GUIEnter * ++once call add(g:x, "GUIEnter")
" au GUIFailed * ++once call add(g:x, "GUIFailed")
" au InsertChange * ++once call add(g:x, "InsertChange")
" au InsertCharPre * ++once call add(g:x, "InsertCharPre")
" au InsertEnter * ++once call add(g:x, "InsertEnter")
" au InsertLeave * ++once call add(g:x, "InsertLeave")
" au MenuPopup * ++once call add(g:x, "MenuPopup")
" au OptionSet * ++once call add(g:x, "OptionSet")
" au QuickFixCmdPost * ++once call add(g:x, "QuickFixCmdPost")
" au QuickFixCmdPre * ++once call add(g:x, "QuickFixCmdPre")
" au QuitPre * ++once call add(g:x, "QuitPre")
" au RemoteReply * ++once call add(g:x, "RemoteReply")
" au SessionLoadPost * ++once call add(g:x, "SessionLoadPost")
" au ShellCmdPost * ++once call add(g:x, "ShellCmdPost")
" au ShellFilterPost * ++once call add(g:x, "ShellFilterPost")
" au SourceCmd * ++once call add(g:x, "SourceCmd")
" au SourcePost * ++once call add(g:x, "SourcePost")
" au SourcePre * ++once call add(g:x, "SourcePre")
" au SpellFileMissing * ++once call add(g:x, "SpellFileMissing")
" au StdinReadPost * ++once call add(g:x, "StdinReadPost")
" au StdinReadPre * ++once call add(g:x, "StdinReadPre")
" au SwapExists * ++once call add(g:x, "SwapExists")
" au Syntax * ++once call add(g:x, "Syntax")
" au TabClosed * ++once call add(g:x, "TabClosed")
" au TabEnter * ++once call add(g:x, "TabEnter")
" au TabLeave * ++once call add(g:x, "TabLeave")
" au TabNew * ++once call add(g:x, "TabNew")
" au TermChanged * ++once call add(g:x, "TermChanged")
" au TermResponse * ++once call add(g:x, "TermResponse")
" au TerminalOpen * ++once call add(g:x, "TerminalOpen")
" au TextChanged * ++once call add(g:x, "TextChanged")
" au TextChangedI * ++once call add(g:x, "TextChangedI")
" au TextChangedP * ++once call add(g:x, "TextChangedP")
" au TextYankPost * ++once call add(g:x, "TextYankPost")
" au User * ++once call add(g:x, "User")
" au VimEnter * ++once call add(g:x, "VimEnter")
" au VimLeave * ++once call add(g:x, "VimLeave")
" au VimLeavePre * ++once call add(g:x, "VimLeavePre")
" au VimResized * ++once call add(g:x, "VimResized")
" au WinEnter * ++once call add(g:x, "WinEnter")
" au WinLeave * ++once call add(g:x, "WinLeave")
" au WinNew * ++once call add(g:x, "WinNew")
" au BufWinEnter ++once echom fix shell 'v.'
augroup END " 

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
