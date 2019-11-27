" !cp % ~/.vim/autoload
" !ln -s %:p ~/.vim/autoload
" !ln -s `cygpath -w %:p` ~/.vim/autoload/bundle.vim
" !cygpath -w %:p
" rm ~/.vim/autoload/bundle.vim
" ll ~/.vim/autoload/bundle.vim

if exists('g:loaded_bundle') || get(g:, 'ibundle') == 1    " see below for ibundle format
    if exists('*bundle#init') | echom "already loaded" | endif
    func! bundle#init(...)  " to make bundle#init() a no-op
    endfunc
    func! bundle#start(...)
    endfunc
    finish
endif
let g:loaded_bundle = 1
let s:debug = get(g:, 'debug', 0)

" let bundle#action_list = {} 
let s:action_list = {} 

func! s:config(lst)
    " echo 'len(a:lst) =' len(a:lst)
    " echo type(a:lst) a:lst
    for spec in a:lst
        " echo type(spec) spec
        " continue
        let [name, times] = spec
        for i in range(2)
            " echo name i times[i] type(times[i])
            if type(times[i]) == v:t_float || times[i] < 50
                let times[i] = float2nr(times[i]*1000)
            else
                let times[i] = times[i] + 0
            endif
            if times[i] < 0 
                let times[i] = -1 
            endif
        endfor
        let [plugin, after] = times
        let s:action_list[tolower(name)] = [plugin, after]
    endfor
endfunc " s:config

" TODO ibundle format, 
" function vp() { vi --startuptime p.out -c 'set bt=nofile' -c 'call setline(1, "p.out")' -c 'nn f gfG' -c 'nn q :<C-u>q<CR>' "$@"; }
" vp --cmd 'let ibundle="YouCompleteMe"'    # TODO 
" vp --cmd 'let ibundle="YouCompleteMe:5"'
" vi --cmd 'let ibundle ="pa, pb:3, pc:0/3"'
let g:ibundle = get(g:, 'ibundle', '')
let s:ibundle = []
for spec in split(g:ibundle, '\s*,\s*')
    if spec =~# ':'
        let [name, times] = split(spec, ':')
        let times = map(((times =~# '/') ? split(times, '/') : [times, times]), 'str2float(v:val)')
    else
        let name = spec
        let times = [-1, -1]
    endif
    call add(s:ibundle, [name, times])
endfor
let g:bundle_ignore = get(g:, 'bundle_ignore', [])
let s:bundle_ignore = []
for spec in deepcopy(g:bundle_ignore)
    if type(spec) == v:t_list
        let [name, times] = spec
        let times = type(times) == v:t_list ? times : [times, times]
    else
        let name = spec
        let times = [-1, -1]
    endif
    " echo [name, times]
    call add(s:bundle_ignore, [name, times])
endfor
call s:config(s:bundle_ignore)
call s:config(s:ibundle)        " this one rules if both specified

" ~/.vim/autoload/pathogen.vim
let g:action_list = deepcopy(s:action_list)
if s:debug
    echom 'g:bundle_ignore' g:bundle_ignore 
    echom 'g:ibundle' g:ibundle
    echom 's:bundle_ignore' s:bundle_ignore 
    echom 's:ibundle' s:ibundle
    " echom 's:action_list' s:action_list 
    echom 'g:action_list' g:action_list 
endif

" finish

func! bundle#action(name, is_after) abort
    " is_after: int, 0 or 1
    let names = keys(s:action_list)
    let idx = match(names, tolower(a:name))
    if idx == -1
        let action = 0     " normal
    else
        let action = s:action_list[names[idx]][a:is_after]
    endif
    if s:debug > 1
        echom (action == -1 ? 'ignore' : (action == 0 ? 'normal' : printf("%-6d",action))) a:name '' (a:is_after ? "        after" : '')
    endif
    " -1 : normal, 0 : ignore, > 50 : miliseconds to load
    return action
endfunc " bundle#action


func! s:lazy_load(path, time)
    if s:debug > 1
        echom 'lazy_load' a:time printf('source %s/plugin/**/*.vim', a:path)
    endif
    let timer = timer_start(a:time, {timer -> execute([printf('set rtp+=%s', a:path),
        \ printf('source %s/plugin/**/*.vim', a:path)])})
endfunc

func! s:loader(path) abort
    let lazy = get(a:, 1, 0)

    " let l:Callback = {path -> execute([printf('set rtp+=%s', path),
    "     \ printf('source %s/plugin/**/*.vim', path)])}
    let l:Callback = {timer -> execute([printf('set rtp+=%s', a:path),
                \ printf('echom "fire: path = %s"', a:path)] + 
        \ map(glob(a:path . '/plugin/**/*.vim',0,1), '"source " . v:val'))}
    return l:Callback
    " printf('set rtp+=%s', a:path),
    " printf('source %s/plugin/**/*.vim', a:path)
endfunc s:loader

func! s:load(path, ...) abort
    let l:Callback = s:loader(a:path)
    let lazy = get(a:, 1, 0)
    if lazy == 0
        call l:Callback(0)
    else
        let timer = timer_start(lazy, l:Callback)
        " echom "path = " a:path "lazy = " lazy "l:Callback = " l:Callback
    endif
endfunc s:load

func! bundle#load(name, ...) abort
    let names = keys(s:flat_bundle)
    let idx = match(names, a:name)
    if idx != -1
        let name = names[idx]
        let pa = s:flat_bundle[name]
        let lazy = get(a:, 1, 0)
        if s:debug | echom "will load plugin " name pa " lazy = " lazy | endif
        call s:load(pa[0], lazy)
        if pa[1] != ''
            call s:load(pa[1], lazy)
        endif
    endif
endfunc bundle#load

let g:root = []
func! s:load_plugins() abort
    for root in s:roots
        let root = root == '' ? $ROOT . 'bundle/' : root . '/'
        call add(g:root, root)
        "continue
        let names = readdir(root, 'isdirectory(root . v:val)')
        let plugins = {}
        for name in names
            let plugin = root . name
            let after = plugin . '/after'
            let plugins[name] = [plugin, isdirectory(after) ? after : '']
        endfor
        let s:bundles[root] = plugins
    endfor
let s:flat_bundle = {}
for [root,bundle] in items(deepcopy(s:bundles))
    call extend(s:flat_bundle, bundle)
endfor
" pu=items(g:bundles)
    for bundle in values(s:bundles)
        for [name,pa] in items(bundle)
            let plugin = pa[0]
            let action = bundle#action(name, 0)
            let s:flat_bundle[name] = add(copy(pa), action)
            if action == 0      " 0: normal, >0: lazy, -1: ignore
                exec printf('set rtp+=%s', plugin)
            elseif action > 0
                " call s:lazy_load(plugin, action)
                call s:load(plugin, action)
            endif
        endfor
        for [name,pa] in items(bundle)
            let plugin = pa[1]      " corresponding after directory
            let action = bundle#action(name, 1)
            call add(s:flat_bundle[name], action)
            if plugin == ''
                continue
            endif
            if action == 0      " 0: normal, >0: lazy, -1: ignore
                exec printf('set rtp+=%s', plugin)
            elseif action > 0
                " call s:lazy_load(plugin, action)
                call s:load(plugin, action)
            endif
        endfor
    endfor
let g:bundles = deepcopy(items(s:flat_bundle))
endfunc " s:load_plugins

let s:bundles = {}
let s:roots = []
func! bundle#start(...) abort
    let s:roots += a:000
    call s:load_plugins()
endfunc " bundle#start

fu bundle#root()
    return s:root
endfu

func! bundle#init(...) abort
    call add(s:roots, get(a:, 1, ''))
endfunc " bundle#init
