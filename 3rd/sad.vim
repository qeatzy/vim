" https://github.com/hauleth/sad.vim
" autoload/sad.vim
func! sad#search(type, ...) abort
    let l:temp = @v
    if a:0
        silent exe 'norm! gv"vy'
    elseif a:type is# 'line'
        silent exe "normal! '[V']\"vy"
    else
        silent exe 'normal! `[v`]"vy'
    endif

    let l:search = @v
    let @v = l:temp
    let @/ = '\V\C' . substitute(escape(l:search, '\'), '\n', '\\n', 'g')
    call histadd('/', substitute(@/, '[?/]', '\="\\%d".char2nr(submatch(0))', 'g'))
    call feedkeys("\<Plug>(sad-enable-hlsearch)")

    return l:search
endfunc

func! sad#search_forward(...) abort
    call call('sad#search', a:000)
    norm! /
endfunc

func! sad#search_backward(...) abort
    call call('sad#search', a:000)
    norm! ?
endfunc

func! s:search_and_replace(dir, ...) abort
    if a:0 > 0 && a:1 is# "\<C-v>"
        return feedkeys('gv"'.v:register.'c', 'n')
    endif

    let l:search = call('sad#search', a:000)
    exe 'let @'.v:register.' = "'.escape(l:search, '"').'"'
    call feedkeys('"'.v:register.'cg'.a:dir, 'n')
endfunc

func! sad#search_and_replace_forward(...) abort
    call call('s:search_and_replace', ['n'] + a:000)
endfunc

func! sad#search_and_replace_backward(...) abort
    call call('s:search_and_replace', ['N'] + a:000)
endfunc

func! sad#be_happy(bang) abort
    if a:bang
        echom 'Be happy now.'
    else
        echom "Don't worry, be happy!"
    endif
endfunc

" plugin/sad.vim
" sad.vim - simplify visual search
" Maintainer: Hauleth <lukasz@niemier.pl>

" if exists('g:loaded_sad_vim') || v:version < 700 || &cp
"     finish
" endif
" let g:loaded_sad_vim = 1
" unlet g:loaded_sad_vim
let s:save_cpo = &cpo
set cpo&vim

nnoremap <silent> <Plug>(sad-enable-hlsearch) :<C-u>let v:hlsearch=1<CR>

xnoremap <silent> <Plug>(sad-search-forward) :<C-u>call sad#search_forward(visualmode(), 1)<CR>
xnoremap <silent> <Plug>(sad-search-backward) :<C-u>call sad#search_backward(visualmode(), 1)<CR>

nnoremap <silent> <Plug>(sad-search-forward) :<C-u>set opfunc=sad#search_forward<CR>g@
nnoremap <silent> <Plug>(sad-search-backward) :<C-u>set opfunc=sad#search_backward<CR>g@

xnoremap <silent> <Plug>(sad-change-forward) :<C-u>call sad#search_and_replace_forward(visualmode(), 1)<CR>
xnoremap <silent> <Plug>(sad-change-backward) :<C-u>call sad#search_and_replace_backward(visualmode(), 1)<CR>

nnoremap <expr><silent> <Plug>(sad-change-forward) ':<C-u>set opfunc=sad#search_and_replace_forward<CR>"'.v:register.'g@'
nnoremap <expr><silent> <Plug>(sad-change-backward) ':<C-u>set opfunc=sad#search_and_replace_backward<CR>"'.v:register.'g@'

func! s:trymap(mode, lhs, rhs) abort
    if maparg(a:lhs, a:mode) ==# ''
        exec a:mode.'map <unique> '.a:lhs.' '.a:rhs
    endif
endfunc

if !hasmapto('<Plug>(sad-search-forward)') && !hasmapto('<Plug>(sad-search-backward)')
    call s:trymap('x', '*', '<Plug>(sad-search-forward)')
    call s:trymap('x', '#', '<Plug>(sad-search-backward)')
endif

if !hasmapto('<Plug>(sad-change-forward)') && !hasmapto('<Plug>(sad-change-backward)')
    call s:trymap('x', 's', '<Plug>(sad-change-forward)')
    call s:trymap('x', 'S', '<Plug>(sad-change-backward)')

    call s:trymap('n', 's', '<Plug>(sad-change-forward)')
    call s:trymap('n', 'S', '<Plug>(sad-change-backward)')
endif

nmap <expr> <Plug>(sad-change-forward-linewise) '0"'.v:register.'<Plug>(sad-change-forward)'.v:count1.'g_'
nmap <expr> <Plug>(sad-change-backward-linewise) '0"'.v:register.'<Plug>(sad-change-backward)'.v:count1.'g_'

command! -bang Sad call sad#be_happy(<bang>0)

let &cpo = s:save_cpo
unlet s:save_cpo
