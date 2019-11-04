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
    " if s:debug
    "     echom (idx == -1 ? 'normal' : (idx == 0 ? 'ignore' : printf("%-6d",idx))) a:name
    " endif
    " -1 : normal, 0 : ignore, > 50 : miliseconds to load
    return idx
endfunc " bundle#action


func! bundle#newadd(root, name, ...) abort
    let path = a:root . '/' . a:name
    " if !isdirectory(path) | return | endif
    let action = get(a:, 1, bundle#action(a:name))
    if 0
    " if !isdirectory(path . '/plugin')
    "     if isdirectory(path . '/autoload')
    "         exec printf('set rtp+=%s', path)
    "     else " has ftdetect ftplugin syntax
    "     endif
    else
        if action == 0  " ignore
            return
        " elseif action == -1  " normal
        "     exec printf('set rtp+=%s', path)  " move to centralized, i.e., after call bundle#start()
        else
            " echom "    path = " path " action = " action isdirectory(path . '/after')
            call add(a:name == 'after' ? s:after : s:plugin, [path,action])
        endif
    endif
    if isdirectory(path . '/after')
        call bundle#newadd(path, 'after', action)
    endif
endfunc " bundle#newadd

func! s:do_lazy_load(kv)
    let [path, time] = a:kv
    let timer = timer_start(time, {timer -> execute([printf('set rtp+=%s', path),
        \ printf('source %s/plugin/**/*.vim', path)])})
    " echom "setup timer " timer
    " func! s:ndo_load(timer) closure
    "     exec printf('set rtp+=%s', path)
    "     exec printf('source %s/plugin/**/*.vim', path)
    "     echo "      timer = " timer " wait " time " miliseconds"
    "     echom printf('set rtp+=%s', path)
    "     echom printf('source %s/plugin/**/*.vim', path)
    " endfunc " s:ndo_load
    " let timer = timer_start(time, function('s:ndo_load'))
endfunc

func! s:load_plugins() abort
    for bundle in values(s:bundles)
        for kv in bundle['plugin']
            if kv[1] == -1
                exec printf('set rtp+=%s', kv[0])
            else
                call s:do_lazy_load(kv)
            endif
        endfor
    endfor
    for bundle in values(s:bundles)
        for kv in bundle['after']
            if kv[1] == -1
                exec printf('set rtp+=%s', kv[0])
            else
                call s:do_lazy_load(kv)
            endif
        endfor
    endfor
    echom s:bundles
endfunc " s:load_plugins

let s:bundles = {}
func! bundle#start(...) abort
    let basetime = get(a:, 1)
    for root in a:000[1:]
    " echom "\t basetime = " basetime "root = " root
        let time = basetime > 0 ? basetime : 0
        if type(root) == v:t_list
            let [root, time] = root
        elseif type(root) == v:t_dict
        endif
        if has_key(s:bundles, root)
            echom "already added [" . root "]" expand('<s:file>')
            continue
        endif
        let current = {'plugin' : [], 'after' : []}
        let s:bundles[root] = current
        let s:plugin = current['plugin']
        let s:after = current['after']
        call bundle#init(root, 1)
    endfor
    if basetime >= 0
        call s:load_plugins()
    endif
endfunc " bundle#start

func! bundle#init(...) abort
    let root = get(a:, 1, $HOME . "/.vim/bundle")
    let action = get(a:, 2, 0)
    if action == 0
        call bundle#start(-1, root) " to setup s:plugin & s:after
    else
        " /home/zyq3e/.vim/bundle
        " for d in readdir(root)
        for d in readdir(root, 'isdirectory(root . "/" . v:val)')   " to reduce syscall, better syscall together
            " call bundle#add(root, d)
            call bundle#newadd(root, d)
        endfor
    endif
endfunc " bundle#init

