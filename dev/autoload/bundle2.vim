if exists('g:loaded_bundle') || get(g:, 'ibundle') == 1    " see below for ibundle format
    if exists('*bundle2#init') | echom "already loaded" | endif
    func! bundle2#init(...)  " to make bundle2#init() a no-op
    endfunc
    func! bundle2#start(...)
    endfunc
    finish
endif
let g:loaded_bundle = 1
let s:debug = get(g:, 'debug', 0)

let s:action_list = {} 
let s:default_action = get(g:, 'default_action', 0)  " default 0: norma load, -1: disable, 2000: 2s lazy

func! s:toaction(time) abort
    if type(a:time) == v:t_float || a:time < 50
        let time = float2nr(a:time*1000)
    else
        let time = a:time + 0
    endif
    if time < 0 
        let time = -1 
    endif
    return time
endfunc " s:toaction

func! s:config(lst)
    for [name, times] in a:lst
        let s:action_list[tolower(name)] = map(times,'s:toaction(v:val)')
    endfor
endfunc " s:config

func! s:match(names, name) abort
    return match(a:names, tolower(a:name))
endfunc " s:match

func! bundle2#action(name, is_after) abort
    " if name not specified in g:bundle_ignore & g:ibundle,
    " use s:default_action, else action: -1 ignore, 0 normal, 5 5s lazy
    let names = keys(s:action_list)
    let idx = s:match(names, a:name)
    if idx == -1    " name not specified
        let action = s:default_action     " normal
    else
        let action = s:action_list[names[idx]][a:is_after]
    endif
    return action
endfunc " bundle2#action
func! s:action(name)
endfunc " s:action

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
    call add(s:bundle_ignore, [name, times])
endfor
call s:config(s:bundle_ignore)
call s:config(s:ibundle)        " this one rules if both specified

func! bundle2#load(...) abort
    for name in a:000
        for plugins in values(s:bundles)
            let names = keys(plugins)
            let idx = s:match(names, name)
            if idx >= 0
                let [plugin, after] = plugins[names[idx]]
                call s:load(plugin)
                if !empty(after)
                    call s:load(after)
                endif
                break
            endif
        endfor
    endfor
endfunc " bundle2#load
command -nargs=+ Load call bundle2#load(<f-args>)

func! s:loader(path) abort
        " \ printf('echom "fire: path = %s"', a:path)] + 
    let l:Callback = {timer -> execute([printf('set rtp+=%s', a:path),] +
        \ map(glob(a:path . '/plugin/**/*.vim',0,1), '"source " . v:val'))}
    return l:Callback
endfunc s:loader

func! s:load(path, ...) abort
    let l:Callback = s:loader(a:path)
    let lazy = get(a:, 1, 0)
    if lazy == 0
        call l:Callback(0)
    else
        let timer = timer_start(lazy, l:Callback)
    endif
endfunc s:load

func! s:load_plugins() abort
    for root in s:roots
        let root = root == '' ? $ROOT . 'bundle/' : root . '/'
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
    for bundle in values(s:bundles)
        for [name,pa] in items(bundle)
            let plugin = pa[0]
            let action = bundle2#action(name, 0)
            let s:flat_bundle[name] = add(copy(pa), action)
            if action == 0      " 0: normal, >0: lazy, -1: ignore
                exec printf('set rtp+=%s', plugin)
            elseif action > 0
                call s:load(plugin, action)
            endif
        endfor
        for [name,pa] in items(bundle)
            let plugin = pa[1]      " corresponding after directory
            let action = bundle2#action(name, 1)
            call add(s:flat_bundle[name], action)
            if plugin == ''
                continue
            endif
            if action == 0      " 0: normal, >0: lazy, -1: ignore
                exec printf('set rtp+=%s', plugin)
            elseif action > 0
                call s:load(plugin, action)
            endif
        endfor
    endfor
let g:bundles = deepcopy(items(s:flat_bundle))
" let g:d = deepcopy(s:bundles)
endfunc " s:load_plugins

let s:bundles = {}
let s:roots = []
func! bundle2#start(...) abort
    let s:roots += a:000
    call s:load_plugins()
endfunc " bundle2#start

func! bundle2#root()
    return s:roots
endfunc " bundle2#root

func! bundle2#init(...) abort
    call add(s:roots, get(a:, 1, ''))
endfunc " bundle2#init

