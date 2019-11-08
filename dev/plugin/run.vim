
nnoremap x :<C-u>call run#GetInputCommandThenCaptureAndPut()<CR>
inoremap x <Esc>:<C-u>call run#GetInputCommandThenCaptureAndPut()<CR>

nnoremap r :<C-u>call run#r(v:count1)<CR>

" let ss_save = &shortmess
" nun r
"
" let &shortmess = ss_save . 'l'
" set shortmess=filnxtToOSIc
