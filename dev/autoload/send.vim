func! send#curline(bufnr, ...) abort
    let ncol = col('$')
    if col('.') == ncol || a:0
        call term_sendkeys(a:bufnr, getline('.') . "\r")
    endif
    return a:0 ? a:1 : "\<CR>" 
endfunc " send#curline

func! send#init() abort
    ino <buffer> <expr> <CR> send#curline(b:termnr)
    imap [109;5u <CR>|" <C-m> different from <CR> on ssh + vim + term
endfunc " send#init
