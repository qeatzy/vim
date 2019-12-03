" !cp % ~/.vim/autoload
" !ln -s %:p ~/.vim/autoload
" !ln -s `cygpath -w %:p` ~/.vim/autoload/bundle.vim
" !cygpath -w %:p
" rm ~/.vim/autoload/bundle.vim
" ll ~/.vim/autoload/bundle.vim

if exists('g:loaded_bundle')
    func! bundle#init(...)
    endfunc
    finish
endif
let g:loaded_bundle = 1
let s:debug = get(g:, 'debug', 0)

let g:if_plugin_same_name = get(g:, 'ifexists', 'error')
" ignore: first apply, override: last apply, error: first apply & echoerr

let s:path ={}

" let bundle#action_list = {} 
let s:action_list = {} 
for kv in get(g:, 'bundle_ignore', [])
    if type(kv) == v:t_string
        let s:action_list[kv] = 0   " ignore
        " echo 'kv' kv
    else
        try
            let [k,v] = kv
            if type(v) == v:t_float || v < 50
                let v = float2nr(v*1000)
            else
                let v = v + 0
            endif
            let s:action_list[k] = v  " 0 to disable, or miliseconds before load
        catch /.*/
            echoerr 'wrong value or format for g:bundle_ignore'
        endtry
    endif
endfor
if s:debug
    echom 'g:bundle_ignore' g:bundle_ignore 
    echom 's:action_list' s:action_list 
endif

func! bundle#action(name) abort
    let names = keys(s:action_list)
    let idx = match(names, a:name)
    if idx != -1
        let idx = s:action_list[names[idx]]
    endif
    if s:debug
        echom (idx == -1 ? 'normal' : (idx == 0 ? 'ignore' : printf("%-6d",idx))) a:name
    endif
    " -1 : normal, 0 : ignore, > 50 : miliseconds to load
    return idx
endfunc " bundle#action


func! s:lazy_load(path, miliseconds)
    func! s:do_load(timer) closure
        call execute([printf('set rtp+=%s', a:path),
            \ printf('source %s/plugin/**/*.vim', a:path)])
    endfunc " s:do_load
    let timer = timer_start(a:miliseconds, function('s:do_load'))
endfunc

func! bundle#add(root, name) abort
    let path = a:root . '/' . a:name
    if !isdirectory(path . '/plugin') | return | endif
    if !empty(get(s:path, a:name, {}))
        if g:if_plugin_same_name == 'error' |
            echoerr printf("plugin [%s] has same name") | endif
        if g:if_plugin_same_name != 'override'
            return
        endif
    endif
    let action = bundle#action(a:name)
    if action == 0
        return
    endif
    let d = {'path' : path}
    if isdirectory(path . '/after/plugin')
        let d['after'] = path . '/after'
    endif
    if action == -1
        exec printf("set rtp+=%s", d['path'])
        exec printf("set rtp+=%s", get(d,'after',''))
    else    " time in miliseconds
        " echo 
        call s:lazy_load(d['path'], action)
        if has_key(d, 'after')
            call s:lazy_load(d['after'], action)
        endif
    endif
    let s:path[a:name] = d
endfunc " s:add

func! bundle#init(...) abort
    let root = get(a:, 1, $HOME . "/.vim/bundle")
    " /home/zyq3e/.vim/bundle
    " let plugins = readdir(root)
    for d in readdir(root)
        call bundle#add(root, d)
        continue
        if bundle#ignore(d)
            continue
        endif
        let d = root . '/' . d
        if isdirectory(d)
            let g:a2 = d
            " let &rtp .= printf(",%s", d)
            exec printf("set rtp+=%s", d)
            if isdirectory(d . '/after')
                " let &rtp .= ',' . d . '/after'
                exec printf("set rtp+=%s/after", d)
            endif
        endif
    endfor
endfunc " bundle#init


