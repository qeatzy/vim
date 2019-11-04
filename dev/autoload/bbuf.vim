if has('*bbuf#init')
    " finish
endif
func! bbuf#init() abort
endfunc " bbuf#init

" let s:nr = bufnr('[buffers]', 1)
let s:nr = buf#addscratch('[buffers]')
" call bufload(s:nr)
" call setbufvar(s:nr, '&bt', 'nofile')
" call setbufvar(s:nr, '&ft', 'bbuf')
" call setbufvar(s:nr, '&swapfile', 0)

func! bbuf#openbuffers() abort
    let b = getbufinfo()
    call filter((b), 'v:val.listed')
    call map((b),'v:val.name')
    let cwd = getcwd(-1)
    call map((b),'s:pathreduce(v:val,cwd)')
    call setbufline(s:nr, 1, b)
    exec s:nr . 'b'
    redraw!
    " call io#getinput(b, s:nr)
    " call io#getinput([b,keys(g:dirs), run#cmdhist()], s:nr)
    call io#getinput([b,keys(g:dirs), run#cmdhist()], s:nr, ['bbuf','dirbuf','runcmd'])
endfunc " bbuf##openbuffers

func! s:pathreduce(abspath, prefix) abort
    let n = len(a:prefix)
    if a:abspath[:n-1] ==# a:prefix
        return a:abspath[n+1:]
    endif
    return a:abspath
endfunc

" let b = getbufinfo()
" echo filter(copy(b), 'v:val.listed')
" echo len(filter(copy(b), 'v:val.listed'))
" echo len(b) b[0]
" pu = map(copy(b),'v:val.name')

func! bbuf#setup() abort
    nn <buffer> i :<C-u>exec 'b' . bufnr(getline('.'))<CR>
endfunc
