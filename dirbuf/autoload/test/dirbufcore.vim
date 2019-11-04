

func! test#dirbufcore#abspath() abort
    let names = ['/', '.', '..', './non-exists/..',
            \ './xx/..',
                \ repeat('../',4),
                \ '/path/to/some/' . repeat('/..',2),
                \ repeat('/..',4),
                \ '/cygdrive/e/notes/task/vim/buffer.txt/../../../../../../../..']
    for name in names
        echo name " -> " dirbufcore#abspath(name)
    endfor
" echo      dirbufcore#abspath('./non-exists/../../..')
" echo      dirbufcore#abspath('../non-exists/../x')
" echo      dirbufcore#abspath('.')
" echo      dirbufcore#abspath('/')
" echo      dirbufcore#abspath('/lib/..')
" echo      dirbufcore#abspath('/lib/../')
" echo      dirbufcore#abspath('/lib/../..')
endfunc " test#dirbufcore#abspath

func! test#dirbufcore#simplify() abort
    let names = ['/', '.', '..', './non-exists/..',
            \ './xx/..',
                \ repeat('../',4),
                \ '/path/to/some/' . repeat('/..',2),
                \ repeat('/..',4),
                \ '/cygdrive/e/notes/task/vim/buffer.txt/../../../../../../../..']
    for name in names
        echo name " -> " dirbufcore#simplify(name)
    endfor
endfunc " test#dirbufcore#simplify

func! test#dirbufcore#parent() abort
    let names = ['/home/zyq3e/notes/task/vim/buffer.txt', '', '.', 'buffer.txt']
    for name in names
        echo 'name : ' name
        for cnt in [0,1,2,3,4,8]
            echo cnt " -> " dirbufcore#parent(cnt, name)
        endfor
    endfor
endfunc " test#dirbufcore#parent


" cd todo
" cd ..
" echo dirbufcore#cwd() getcwd() get(g:, 'a')
" cd ~/.vim/bundle
" cd ~/notes

