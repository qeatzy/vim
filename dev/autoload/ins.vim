func! ins#test()
    let g:s = v:char
    if v:char =~ '\r' | let g:y = 11 | endif
    let g:x += 1
    return
    " if v:char !=# "\<Enter>"
    if v:char !=# "\n"
    " if v:char ==# " "
        return
    endif
    if !exists('g:x') | let g:x = 0 | endif
    let g:x += 1
endfunc " ins#test

au! InsertCharPre
au InsertCharPre * call ins#test()
au InsertEnter * let g:x += 1
let g:x = 0
let g:y = 0
" au InsertCharPre
echo g:x
echo g:s char2nr(g:s)
echo g:y   

" ls $this-
" echo s
" expand '$this-' to '$this->'
function! s:expand() abort
  if v:char isnot '-'
    return
  endif
  if strpart(getline('.'), 0, col('.') - 1) =~# '\$this$'
      let g:s = v:char
    let v:char = '->'
  endif
endfunction
augroup vimrc-expand
  autocmd!
  autocmd InsertCharPre * call <sid>expand()
augroup END

ino <C-j> <Down>
ino <C-k> <Up>
