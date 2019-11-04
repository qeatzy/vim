func! Test(a) abort
    try
        echo a:a + 0
    catch /.*/
        echo v:exception
    endtry
endfunc
call Test([])
call Test({})
call Test('xx')
