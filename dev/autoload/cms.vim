func! cms#c(first, last) abort
    " keepp g/^\s*\/\*/.,/\*\/\s*$/d_
    " keepp g/^\s*\/\//d_
    keepp %s/\%(\/\*\_.\{-}\*\/\)\|\/\/.*//
endfunc " cms#c
