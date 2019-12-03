

" let &stl = stl_saved
" let stl_saved = &stl
" echo stl_saved
let &stl = '[%n]%-10.30f %y  %{&fenc!=""?&fenc:&enc} %{(&ff=="unix"?"":&ff)}   %{strftime("%H:%M")} %= %l/%L [%02p%%] %03c %{LineCountCurrentParagraph()} %{IsBuffersModified()}%r%w %P '
