func! cms#c(first, last) abort
    " exec 'keepp '. a:first ','. a:last .'s=\%(^\s*/\*\_.\{-}\*/\)\|^\s*//.*==g'
    exec 'keepp '. a:first ','. a:last .'s=\%(/\*\_.\{-}\*/\)\|//.*==g'
endfunc " cms#c

func! cms#python(first, last) abort
    exec 'keepp '. a:first ','. a:last .'s=\%(^\s*\([''"]\{3}\)\_.\{-}\1\)\|^\s*#.*==g'
endfunc " cms#python

func! cms#line(first, last, s, ...) abort
    if !a:0
        exec 'keepp '. a:first ','. a:last .'s?^\s*' . a:s . '.*??'
    else
        exec 'keepp '. a:first ','. a:last .'g?^\s*' . a:s . '.*?d_'
    endif
endfunc " cms#line

func! cms#vim(first, last) abort
    call cms#line(a:first, a:last, '"', 1)
endfunc " cms#vim

func! cms#cms(first, last, ...) abort
    " toggle line comments
    let [first,last] = [a:first,a:last]
    " let first = line(a:first)
    " let last = line(a:last)
    " let last = (last is# 0 && a:last > first) ? line('$') : last
    let indent = []
    let leading = []
    let cms = a:0 ? a:1 : '"'
    let has_cms = 0
    let no_cms = 0
    let min_indent = 1000000
    for line in range(first, last)
        " call add(indent, indent(line))
        " call add(leading, matchstr(getline(line), '\%(\s*\)\zs\S'))
        let ch = matchstr(getline(line), '\%(\s*\)\zs\S')
        if ch isnot# ''
            if ch is# cms
                let has_cms = 1
            else
                let no_cms = 1
            endif
            let indent = indent(line)
            if indent < min_indent
                let min_indent = indent
            endif
        endif
    endfor
    if has_cms - no_cms == 1
        exec first .','. last .'s~'. cms .'\s\?'
    else
        exec first .','. last .'s~\%'. (min_indent+1) .'c~\0'. cms .' ~'
    endif
    return [first, last, has_cms, no_cms, min_indent]
endfunc " cms#cms
breakdel *
" breakadd func 1 cms#cms
" echo cms#cms(17,52)
" echo cms#cms(23,42)
 " echo cms#cms(34,35)
func! cms#cms_vim(first, last) abort
    call cms#cms(a:first, a:last, '"')
endfunc " cms#cms_vim
func! cms#cms_python(first, last) abort
    call cms#cms(a:first, a:last, '#')
endfunc " cms#cms_python
