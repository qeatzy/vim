
command! -nargs=0 HI so $VIMRUNTIME/syntax/hitest.vim
" default color 46 under cygwin is good for ErrorMsg ctermbg.
hi ErrorMsg term=standout ctermfg=15 ctermbg=36
" call execute(['nmap <buffer> j <C-a><F2>gf','nmap <buffer> k <C-x><F2>gf'])
" call execute(['nun <buffer> j','nun <buffer> k'])
" call execute(['nun gt','runtime plugin/buffer.vim'])
" h execute(


" https://jordanelver.co.uk/blog/2015/05/27/working-with-vim-colorschemes/
command! -nargs=0 HI so $VIMRUNTIME/syntax/hitest.vim
nmap f :call <SID>SynStack()<CR>
function! s:SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

func! color#theme(filename, ...)
        exec 'sil! !cat ' . a:filename
        redraw!
        if a:0 | echo a:filename | endif
endfunc " color#theme
