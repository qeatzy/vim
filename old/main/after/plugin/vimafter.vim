augroup vimafter
au!
autocmd VimEnter * so /cygdrive/e/notes/task/install/vim/main/mapping-VimEnter.vim
augroup END

try
" if match(&rtp,'ultisnips') != -1
" if bundle#has('YouCompleteMe')
    " let g:ycm_min_num_of_chars_for_completion = 3   " default 2
    let g:ycm_seed_identifiers_with_syntax=1            " to let semantic completion popup automatically
    let g:ycm_collect_identifiers_from_tags_files = 1   " add extra identifiers, not work reliably, open in buffer instead
    " try
    unlet g:ycm_filetype_blacklist['text']      " dict used as set
    " catch /.*/
    " endtry
    " how to temporarily disable/re-enable YouCompleteMe
    " let g:ycm_auto_trigger=0
    " https://github.com/ycm-core/YouCompleteMe/issues/1731
    " https://github.com/ycm-core/YouCompleteMe/issues/662
    " That's already possible; put let g:loaded_youcompleteme = 1 in your vimrc and YCM won't load.
" endif " YouCompleteMe
catch /E121/    " E121: Undefined variable: g:ycm_filetype_blacklist
endtry

" {{{ postvimrc.vim -- old postion, need refactor
" ln -s $(realpath postvimrc.vim) ~/.vim/after/plugin/postvimrc.vim

if !has('s:has_color_vanilla')
    try
        colorscheme vanila
        let s:has_color_vanilla = 1
    catch /E185/
        let s:has_color_vanilla = 0
    endtry
elseif s:has_color_vanilla
    colorscheme vanila
endif

func! VimLinesCapture(lno, n) abort
    let out = Capture(join(getline(a:lno, a:lno + a:n - 1),"\n"))
    call WinScratch('b','',g:sz_scratch, exists('b:cpurge') ? b:cpurge : g:cpurge)
    pu=out
    if g:st_winback
        winc p
    endif
endfunc

sil! delc Explore

cnoremap <C-k> <Up>

" {{{ ic-object.vim
func! Ic_Object(cnt, pat) abort
    let pos = match(getline('.'), a:pat, 0, a:cnt)
    " echo match(getline('2'),  '\<\w\+\S\{-1,\}', 0, 2)
    " echom [a:cnt, pos]
    call cursor([0,pos+1])
    norm! ve
endfunc

onoremap ic :<C-u>call Ic_Object(v:count1, '\<\w\+\S\{-1,\}')<CR>
" }}} ic-object.vim

com! -nargs=0 BG norm! 
call CmdAlias('bg', 'BG')
call CmdAlias('fg', 'BG')

" inoremap <Tab> <C-n>
" inoremap jj <Esc>Ea
" inoremap kk <Esc>Bi
" inoremap h <BS>
" " inoremap   <C-o>o
" nnoremap , <<

let g:ulti_expand_res = 0
func! Supertab()
    let nr = col('.') - 1
    " get char under cursor https://vi.stackexchange.com/questions/11476/how-can-i-get-the-character-at-the-cursor-position-in-a-multibyte-aware-manner
    if nr == 0 || strcharpart(strpart(getline('.'), nr-1),0,1) !~# '[_0-9a-zA-Z]'
        " return 1
        return "\<Tab>"
    else
        call UltiSnips#ExpandSnippet()
        if g:ulti_expand_res == 0
        " return 2
            return "\<C-n>"
        endif
        return ""
    endif
endfunc " Supertab()
" inoremap <expr> <Tab> Supertab()
inoremap <Tab> <C-r>=Supertab()<CR>
 
let g:jedi#completions_command = "<Tab>"
let g:jedi#completions_enabled = 0

" }}} postvimrc.vim
