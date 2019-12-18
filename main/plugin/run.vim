
com! -nargs=* Ack call run#ag(<f-args>)
call CmdAlias('ack', 'Ack')
call CmdAlias('ag', 'Ack')


" let $BASH_ENV = $HOME . '/rc/lib/bash/profile'
let $BASH_ENV = $HOME . '/nnotes/dev/rc/lib/bash/profile'

nnoremap x :<C-u>call run#GetInputCommandThenCaptureAndPut()<CR>
inoremap x <Esc>:<C-u>call run#GetInputCommandThenCaptureAndPut()<CR>
nnoremap <M-x> :<C-u>call run#GetInputCommandThenCaptureAndPut()<CR>
nnoremap c :<C-u>call run#runvimL(input(':'))<CR>
nnoremap <M-c> :<C-u>call run#runvimL(input(':'))<CR>

" nnoremap r :<C-u>call run#r(v:count1)<CR>
nn <silent> r :<C-u>call key#prefix({0: 'key#r', 'f': 'file#cfile'}, v:count)<CR>

augroup pyinter
    autocmd!
    au filetype pyinter call send#pyinter()
augroup END " pyinter 

" let ss_save = &shortmess
" nun r
"
" let &shortmess = ss_save . 'l'
" set shortmess=filnxtToOSIc
