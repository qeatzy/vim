func! op#line(type, ...) abort
    " if a:0  " invoked from visualmode, see `:h map-operator`
    return a:0 ? [line("'<"),line("'>")] : [line("'["),line("']")]
endfunc " op#line

