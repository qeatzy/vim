" nmap g <Plug>Nmap_g
" nn g :<C-u>call nmap#g()<CR>
" nmap g :<C-u>call nmap#g()<CR>
" nmap <expr> g nmap#g()

nnoremap <Plug>yank_filename :<C-u>call nmap#yank_filename()<CR>

nmap yg <Plug>nmap#yank_filename
nmap yg <Plug>yank_filename

nnoremap qr :<C-u>call run#runbash(line('.'),v:count1)<CR>
nnoremap gr :<C-u>call run#capturebash(line('.'),v:count1)<CR>
