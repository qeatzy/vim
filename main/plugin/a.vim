set timeout|"-- default on
set timeoutlen=200
set ttimeout|"-- default off
set ttimeoutlen=100
set nostartofline|" duplicate line remain same column

        " set ruler
        " set laststatus=0
        " set noshowmode  " to get rid of thing like --INSERT--
        " set noshowcmd  " to get rid of display of last command
        " set shortmess+=F  " to get rid of the file name displayed in the command line bar
        set shortmess+=c    " Back at original" during autocompletion  https://github.com/Shougo/neocomplete.vim/issues/186
        set showcmd

func! CmdAlias(lhs, rhs, ...)
" https://vi.stackexchange.com/questions/12872/how-to-make-command-line-abbreviations-that-only-trigger-at-begining-of-line
exec 'cnorea <expr> ' . a:lhs . ' ("' . get(a:,1,":") . '" =~# getcmdtype() && getcmdline() =~ "^\s*'. a:lhs . '$") ? "' . a:rhs . '" : "' . a:lhs .'"'
endfunc

func! Capture(excmd) abort  " inspired by tpope's scriptease.vim
    let excmd = type(a:excmd) !=# 3 ? [a:excmd] : a:excmd
    try
        redir => out
        for cmd in excmd
            exe 'silent! ' . cmd
        endfor
    finally
        redir END
    endtry
    return out
endfunc

function! MapToggle(key, opt)
    let cmd = ':set ' . a:opt . '! \| set ' . a:opt . "?\<CR>"
    exec 'nnoremap ' . a:key . ' ' . cmd
    exec 'inoremap ' . a:key . " \<C-O>" . cmd
endfunction
command! -nargs=+ MapToggle call MapToggle(<f-args>)

" callback is a funcref or function name
func! SetOpfunc(callback) abort
    func! RangeCallFunc(type, ...) abort closure
        let lines = op#line(a:type)
        call call(a:callback, lines)
        norm! g`o
    endfunc
    norm! mo
    set opfunc=RangeCallFunc
    " return 'g@'
endfunc


onoremap if :<C-U>normal! ggVG<CR>
