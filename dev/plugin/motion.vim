func! NextWindowOrTab(...) abort
"n  <C-L>       * :if winnr('$') == 1|tabn|else|winc l|endif<CR>
endfunc

nn <C-l> :<C-u>call NextWindowOrTab(v:count1)<CR>

func! TestRange() range
    echo a:firstline a:lastline
endfunc
