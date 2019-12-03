
" you can loop though terminal themes, when in hitest buffer,
" the highlight color will change accordingly. Same as in python
" or javascript file.

" beside SynStack, add hi xxx output.

let g:color#explore_err = [range(0,255),-1]
func! color#next_err(step) abort
    let nr = loop#next(g:color#explore_err, a:step)
    exec 'hi ErrorMsg term=standout ctermfg=15 ctermbg=' . nr
    return printf('%3i',nr)
endfunc " color#next_err
func! color#explore_err(...) abort
    if !a:0
        nn <silent> j :<C-u>exec 'NotExistCommand '. color#next_err(v:count1)<CR>
        nn <silent> k :<C-u>exec 'NotExistCommand '. color#next_err(-v:count1)<CR>
        nn <silent> <down> :<C-u>exec 'NotExistCommand '. color#next_err(v:count1)<CR>
        nn <silent> <up> :<C-u>exec 'NotExistCommand '. color#next_err(-v:count1)<CR>
        nn q :<C-u>call color#explore_err(1)<CR>
    else
        nun <silent> j
        nun <silent> k
        nun <silent> <down>
        nun <silent> <up>
        nn q :q<CR>
    endif
endfunc " color#explore_err
call color#explore_err()

func! color#explore_hi(...)
if get(a:, 0) is# 0
call execute(["nn <silent> j :<C-u>call execute(['norm! ' . v:count1 . 'j'])<CR>:norm f<CR>", "nn <silent> k :<C-u>call execute(['norm! ' . v:count1 . 'k'])<CR>:norm f<CR>", "nn q :<C-u>call color#explore_hi(1)<CR>"])
else
call execute(['sil! nun j', 'sil! nun k', 'nn q :q<CR>'])
endif
" remember q map, then q to restore
return
" test phase
nn <silent> j :<C-u>call execute(['norm! ' . v:count1 . 'j'])<CR>:norm f<CR>
nn <silent> k :<C-u>call execute(['norm! ' . v:count1 . 'k'])<CR>:norm f<CR>
endfunc " color#explore_hi


command! -nargs=0 HI so $VIMRUNTIME/syntax/hitest.vim
" default color 46 under cygwin is good for ErrorMsg ctermbg.
" hi ErrorMsg term=standout ctermfg=15 ctermbg=36
" hi ErrorMsg term=standout ctermfg=15 ctermbg=24
" call execute(['nmap <buffer> j <C-a><F2>gf','nmap <buffer> k <C-x><F2>gf'])
" call execute(['nun <buffer> j','nun <buffer> k'])
" call execute(['nun gt','runtime plugin/buffer.vim'])
" h execute(


" https://jordanelver.co.uk/blog/2015/05/27/working-with-vim-colorschemes/
command! -nargs=0 HI so $VIMRUNTIME/syntax/hitest.vim
nn <plug>SynStack :call <SID>SynStack()<CR>
function! s:SynStack()
  if !exists("*synstack")
    return
  endif
  " echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
  let lst = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
  " echo lst
  let out = !empty(lst) ? Capture('hi ' . lst[-1]) : ''
  " let out = !empty(lst) ? substitute(Capture('hi ' . lst[-1]), '^\%(\s\|\n\)*','    ','') : ''
  let out = !empty(lst) ? substitute(Capture('hi ' . lst[-1]), '^.*xxx\s','    ','') : ''
  echo string(lst) . out
endfunc

func! color#theme(filename, ...)
    " nmap <buffer> f <plug>SynStack
        " exec 'sil! !cat ' . a:filename
        exec 'sil! !head -1 ' . a:filename
        redraw!
        if a:0 | echo a:filename | endif
endfunc " color#theme

func! color#loop(lst, step, ...)
    let cnt = get(a:, 1, 1)
    let cnt = cnt >= 0 ? cnt : len(a:lst[0])
    let sleep = cnt > 1 ? ('sleep ' . get(a:, 2, 200) . 'm') : ''
    try
    for i in range(cnt)
        " call loop#next(a:lst, a:step, 'color#theme')
        call loop#next(a:lst, a:step, {fn -> color#theme(fn,'echo')})
        exec sleep
    endfor
    catch /^Vim:Interrupt$/ 
    endtry
endfunc " color#loop
" call color#loop(g:lst, 1, -1)

let g:color_dir = '~/.colors/' . (len($TMUX) ? 'tmux' : '') . 'persist'
let g:lst = get(g:, 'lst', [glob(g:color_dir . '/*', 1, 1), -1])
" echo fns
" let g:color_dir
func! color#explore()
    if exists('g:color#explore')
        call loop#map(g:color#explore)
        return
    endif
    let g:color#explore = [
        \ ["nn j :<C-u>call color#loop(g:lst, v:count1)<CR>", "sil! nun j"],
        \ ["nn k :<C-u>call color#loop(g:lst, -v:count1)<CR>", "sil! nun k"],
        \ ["nn s :<C-u>call color#loop(g:lst, 1, v:count?v:count:-1)<CR>", "nmap s <Plug>Sneak_s"],
        \ ["nn S :<C-u>call color#loop(g:lst, -1, v:count?v:count:-1)<CR>", "nmap S <Plug>Sneak_S"],
        \ ["nn q :<C-u>call loop#map(g:color#explore, 1)<CR>", "nn q :q<CR>"]
        \]
    call color#explore()
endfunc " color#explore
" unlet g:color#explore
" call color#explore()

func! Test(lst)
    for [a,b] in a:lst
        echo a b a*b
    endfor
endfunc " Test
" let g:x = get(g:,'x',[0,0])
let g:x = [[1,2],[3,4]]
" call Test(g:x)
" call Test(g:x) | echo g:x
" au bufwritepost


" au! AutoSource bufwritepost /cygdrive/e/nnotes/dev/vim/dev/autoload/color.vim
" call remove(g:AutoSource, '/cygdrive/e/nnotes/dev/vim/dev/autoload/color.vim')



