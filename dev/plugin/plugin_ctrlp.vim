augroup plugin_ctrlp
autocmd CmdUndefined CtrlP* ++once call bundle#load('ctrlp.vim')
augroup END

let g:ctrlp_clear_cache_on_exit = 0

"ctrlp, see " grep " fzf " denite " leaderf
" Change the default mapping and the default command to invoke CtrlP: https://github.com/ctrlpvim/ctrlp.vim#basic-options
if isdirectory($HOME.'/.vim/bundle/ctrlp.vim')
let g:ctrlp_map = '<Space>p'
" let g:ctrlp_cmd = 'CtrlPCurFile'
let g:ctrlp_cmd = 'CtrlPCurWD'
    let g:ctrlp_use_caching = 1     " use caching
    let g:ctrlp_clear_cache_on_exit = 1   " enable cross session caching
if executable('fd')
    if has("win32unix")
    let g:ctrlp_user_command = 'fd --hidden -c never "" "$(cygpath --dos %s)"'
    else
    let g:ctrlp_user_command = 'fd -c never "" "%s"'
    endif
    " let g:ctrlp_use_caching = 0
elseif !has("win32unix") && executable('rg')
    " cygwin path not recognized by rg binary on windows
    " let g:ctrlp_user_command = 'rg %s -i --color=never
    "             \ ""'
    " let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
    " set grepprg=rg\ --color=never
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
    " let g:ctrlp_user_command = 'rg --files %s'
elseif executable('ag')
    " below command from https://stackoverflow.com/a/32520039/3625404
                                    " -i --ignore-case        Match case insensitively
    let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
                \ --ignore .git
                \ --ignore .svn
                \ --ignore .hg
                \ --ignore .DS_Store
                \ --ignore build
                \ --ignore debug
                \ --ignore "**/*.html|epub"
                \ --ignore "**/*.pyc"
                \ --depth 8
                \ -g ""'
                " --depth 8 is useful for if I accidentally hit ctrl-p while editing a file in my home folder.
    " ag is fast enough that CtrlP doesn't need to cache
endif
let g:ctrlp_by_filename = 1
let g:ctrlp_brief_prompt = 1
let g:ctrlp_tilde_homedir = 1
nnoremap <F8> :CtrlPClearAllCaches<CR>
nnoremap ,d :CtrlPDir<CR>
nnoremap ,f :CtrlPMRUFiles<CR>
nnoremap <Space>i :CtrlPBuffer<CR>
nnoremap ;q :<C-u>if winnr('.') > 1 |
" tag search is useful, eg, vim doc, ctags of large C/C++ project.
nnoremap ,t :CtrlPTag<CR>
" CtrlPLastMode not work if invoked via key mapping? works, but the ---dir option may depends on current buffer.
nnoremap ,, :CtrlPLastMode --dir<CR>
let g:ctrlp_open_new_file = 'r' |" r:current, v: vertical split, h: horizontal split, t: new tab
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
endif
