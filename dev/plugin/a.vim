
set timeout|"-- default on
set timeoutlen=200
set ttimeout|"-- default off
set ttimeoutlen=100

        " set ruler
        " set laststatus=0
        " set noshowmode  " to get rid of thing like --INSERT--
        " set noshowcmd  " to get rid of display of last command
        " set shortmess+=F  " to get rid of the file name displayed in the command line bar
        set showcmd

func! CmdAlias(lhs, rhs)
" https://vi.stackexchange.com/questions/12872/how-to-make-command-line-abbreviations-that-only-trigger-at-begining-of-line
exec 'cnorea <expr> ' . a:lhs . ' (getcmdtype() == ":" && getcmdline() =~ "^\s*'. a:lhs . '$")?"' . a:rhs . '":"' . a:lhs .'"'
endfunc

func! Capture(excmd) abort  " from tpope's scriptease.vim
  try
    redir => out
    exe 'silent! '.a:excmd
    " silent 'exe! '.a:excmd
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

onoremap if :<C-U>normal! ggVG<CR>
