" https://jordanelver.co.uk/blog/2015/05/27/working-with-vim-colorschemes/
command! -nargs=0 HI so $VIMRUNTIME/syntax/hitest.vim
nmap f :call <SID>SynStack()<CR>
function! s:SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
