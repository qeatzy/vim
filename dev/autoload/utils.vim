func! utils#init()
endfunc " utils#init
" put only essential ones here
" rather that have a general monolithic utils.vim in autoload, better put 
" specific ones in its own file in autoload, and put essential ones in
" plugin/utils.vim
" but there are another problem, some plugin sourced before may depend this.

" write lines to a temp file, return the name of temp file
func! WriteLinesToFile(lines) abort
    let fn = tempname()
    let fn = 'xx'
    call writefile(a:lines, fn)
    return fn
endfunc

" called inside opfunc to get range of operator
" return '3,20' if only_pos else getline(3,20). '3,3' or getline(3,3)
func! LineRange(type, ...) abort
    let only_pos = get(a:, 1, 0)
    " echom visualmode() a:type '[]' getpos("'[") getpos("']")
    " echom visualmode() a:type '<>' getpos("'<") getpos("'>")
    if only_pos
        if a:type == 'line' || a:type == 'char'
            return printf("%d,%d", line("'["), line("']"))
        " elseif a:type == 'char'
        "     return line("'[")
        else
            return printf("%d,%d", line("'<"), line("'>"))
        endif
    else
        return (a:type == 'line' || a:type == 'char') ? getline("'[", "']") : getline("'<", "'>")
    endif
endfunc

" callback is a funcref or function name
func! SetOpfunc(callback) abort
    " let g:save_pos = getcurpos()
    " mark! o     " :mark does not mark column
    let Callback = function(a:callback)
    func! RangeCallFunc(type, ...) abort closure
        let lines = LineRange(a:type)
        call Callback(lines)
        " call setpos('.', g:save_pos)
        norm! g`o
    endfunc
    norm! mo
    set opfunc=RangeCallFunc
    return 'g@'
endfunc


