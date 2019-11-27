" let $BASH_ENV = $HOME . '/rc/lib/bash/profile'
let $BASH_ENV = $HOME . '/nnotes/dev/rc/lib/bash/profile'

nnoremap x :<C-u>call run#GetInputCommandThenCaptureAndPut()<CR>
inoremap x <Esc>:<C-u>call run#GetInputCommandThenCaptureAndPut()<CR>
" nnoremap c :<C-u>pu= C(input(':'))<CR>
nnoremap c :<C-u>call run#runvimL(input(':'))<CR>

nnoremap r :<C-u>call run#r(v:count1)<CR>

augroup pyinter
    autocmd!
    au filetype pyinter call send#pyinter()
augroup END " pyinter 

" let ss_save = &shortmess
" nun r
"
" let &shortmess = ss_save . 'l'
" set shortmess=filnxtToOSIc
