cnoremap . <Up>
nnoremap q; q:k
nnoremap ; :
cnoremap ; <C-e><C-u><C-h><Esc><Esc><Esc>

call CmdAlias('ts', 'tabs')
call CmdAlias('tl', 'tabs')
call CmdAlias('tne', 'tabnew')
call CmdAlias('tnew', 'tabnew')
call CmdAlias('tn', 'tabnext')
call CmdAlias('t0', 'tabfirst')
call CmdAlias('t9', 'tablast')

" [+] if only current modified, [+3] if 3 modified including current buffer.
" [3] if 3 modified and current not, "" if none modified.
func! IsBuffersModified()
    " let cnt = CountModifiedBuffer()
    let cnt = len(filter(getbufinfo(), 'v:val.changed == 1'))
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

        " set ruler
        " set laststatus=0
        " set noshowmode  " to get rid of thing like --INSERT--
        " set noshowcmd  " to get rid of display of last command
        " set shortmess+=F  " to get rid of the file name displayed in the command line bar

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
