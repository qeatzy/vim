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
    for kv in a:lst
        if type(kv) == v:t_string
            let s:action_list[tolower(kv)] = 0   " ignore
            " echo 'kv' kv
        else
            try
                let [k,v] = kv
                if type(v) == v:t_float || v < 50
                    let v = float2nr(v*1000)
                else
                    let v = v + 0
                endif
                let s:action_list[tolower(k)] = v  " 0 to disable, or miliseconds before load
            catch /.*/
                echoerr 'wrong value or format for g:bundle_ignore'
                echom 'wrong value or format for g:bundle_ignore'
            endtry
        endif
    endfor
endfunc " s:config

" TODO ibundle format, 
" function vp() { vi --startuptime p.out -c 'set bt=nofile' -c 'call setline(1, "p.out")' -c 'nn f gfG' -c 'nn q :<C-u>q<CR>' "$@"; }
" vp --cmd 'let ibundle="YouCompleteMe"'    # TODO 
" vp --cmd 'let ibundle="YouCompleteMe:5"'
let s:ibundle = split(get(g:, 'ibundle', ''), ',')
for i in range(len(s:ibundle))
    if s:ibundle[i] =~# ':'
        let s:ibundle[i] = split(s:ibundle[i], ':')
    endif
endfor
let g:bundle_ignore = get(g:, 'bundle_ignore', [])
call s:config(g:bundle_ignore)
call s:config(s:ibundle)        " this one rules if both specified

" ~/.vim/autoload/pathogen.vim
if s:debug
    echom 'g:bundle_ignore' g:bundle_ignore 
    echom 's:ibundle' s:ibundle
    echom 's:action_list' s:action_list 
endif

func! bundle#action(name) abort
    let names = keys(s:action_list)
    let idx = match(names, tolower(a:name))
    if idx != -1
        let idx = s:action_list[names[idx]]
    endif
    if s:debug
        echom (idx == -1 ? 'normal' : (idx == 0 ? 'ignore' : printf("%-6d",idx))) a:name
    endif
    " -1 : normal, 0 : ignore, > 50 : miliseconds to load
    return idx
endfunc " bundle#action


func! s:lazy_load(path, time)
    let timer = timer_start(a:time, {timer -> execute([printf('set rtp+=%s', a:path),
        \ printf('source %s/plugin/**/*.vim', a:path)])})
endfunc

func! s:loader(path) abort
    let lazy = get(a:, 1, 0)

    " let l:Callback = {path -> execute([printf('set rtp+=%s', path),
    "     \ printf('source %s/plugin/**/*.vim', path)])}
    let l:Callback = {timer -> execute([printf('set rtp+=%s', a:path),
                \ printf('echom "fire: path = %s"', a:path),
        \ printf('source %s/plugin/**/*.vim', a:path)])}
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
    let names = keys(s:bundles_all)
    let idx = match(names, a:name)
    if idx != -1
        let name = names[idx]
        let pa = s:bundles_all[name][1:]
        let lazy = get(a:, 1, 0)
        echom "will load plugin " name pa " lazy = " lazy
        call s:load(pa[0], lazy)
        if pa[1] != ''
            call s:load(pa[1], lazy)
        endif
    endif
endfunc bundle#load

func! s:load_plugins() abort
    for root in s:roots
        if root == '' | let root = $HOME . "/.vim/bundle" | endif
        let base = root . '/'
        let names = readdir(root, 'isdirectory(base . v:val)')
        let plugins = {}
        for name in names
            let plugin = base . name
            let after = plugin . '/after'
            let plugins[name] = [plugin, isdirectory(after) ? after : '']
        endfor
        let s:bundles[root] = plugins
    endfor
" let g:bundles = deepcopy(s:bundles)
" let g:bundles2 = map(copy(values(g:bundles)), {k,v -> values(map(copy(v), {kk,vv -> [kk, bundle#action(kk)] + vv})) })
" pu=bundles2[0]
" pu=bundles2[1]
let s:bundles_all = {}
for [root,bundle] in items(deepcopy(s:bundles))
    call extend(s:bundles_all, map(copy(bundle), {k,v -> [bundle#action(k)] + v}))
endfor
let g:bundles = deepcopy(items(s:bundles_all))
" pu=items(g:bundles)
    for bundle in values(s:bundles)
        for [name,pa] in items(bundle)
            let action = bundle#action(name)
            if action == -1
                exec printf('set rtp+=%s', pa[0])
            elseif action > 0
                call s:lazy_load(pa[0], action)
                " call s:load(pa[0], action)
            endif
            let pa[0] = action  " p plugin, a after, now p holds action
        endfor
        for [name,pa] in items(bundle)
            if pa[0] == 0 || pa[1] == ''
                continue
            endif
            if pa[0] == -1
                exec printf('set rtp+=%s', pa[0])
            else
                call s:lazy_load(pa[1], pa[0])
                " call s:load(pa[1], pa[0])
            endif
        endfor
    endfor
endfunc " s:load_plugins

let s:bundles = {}
let s:roots = []
func! bundle#start(...) abort
    let s:roots += a:000
    call s:load_plugins()
endfunc " bundle#start

func! bundle#init(...) abort
    call add(s:roots, get(a:, 1, ''))
endfunc " bundle#init
