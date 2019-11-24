set guifont=Consolas:h14:cANSI:qDRAFT

func! gvim#after(...)
nnoremap <M-x> :<C-u>call run#GetInputCommandThenCaptureAndPut()<CR>
" inoremap <M-x> <Esc>:<C-u>call run#GetInputCommandThenCaptureAndPut()<CR>
nnoremap <M-c> :<C-u>pu= C(input(':'))<CR>
endfunc " gvim#after

call timer_start(1000, 'gvim#after')
