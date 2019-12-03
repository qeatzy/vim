" motion & view
" motion 1 screen change, cursor not 2 cursor change, screen (may) not
nnoremap ;v :call motion#TogViewMode()<CR>

"screen
nn zh zt

"cursor
nnoremap <BS> k$
nnoremap <C-h> k$
