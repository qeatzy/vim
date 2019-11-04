function! s:getchar()
  let c = getchar()
  if c =~ '^\d\+$'
    let c = nr2char(c)
  endif
  return c
endfunction

" Interactively change the window size
function! InteractiveWindow()
  let char = "s"
  while char =~ '^\w$'
    echo "(InteractiveWindow) TYPE: h,j,k,l to resize or a for auto resize"
    let char = s:getchar()
    if char == "h" | call SetWindowSize( "incr" ,-5 ,0 ) | endif
    if char == "j" | call SetWindowSize( "incr"  ,0 ,5 ) | endif
    if char == "k" | call SetWindowSize( "incr"  ,0 ,-5) | endif
    if char == "l" | call SetWindowSize( "incr"  ,5 ,0 ) | endif
    if char == "a" | call SetWindowSize( "abs"  ,0  ,0 ) | endif
    redraw
  endwhile
endfunction
