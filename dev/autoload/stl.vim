
func! stl#default()
let stl = '%{ShowCount(999)}'
let stl .= '%7*[%n]'                                  " buffernr
let stl .= '%1*%-10.30f '                                " File+path
let stl .= '%2*%< %y '                                  " FileType
let stl .= "%3* %{''.(&fenc!=''?&fenc:&enc).''}"     " Encoding
let stl .= '%3* %{(&bomb?",BOM":"")} '            " Encoding2
let stl .= '%4* %{(&ff=="unix"?"":&ff)} '                              " FileFormat (dos/unix..) 
let stl .= '%8* %= %l/%L [%02p%%]'  " Rownumber/total (%)
let stl .= '%9* %03c '                           " Colnr
let stl .= '%{LineCountCurrentParagraph()}'
let stl .= '%0* %{IsBuffersModified()}%r%w %P '                      " Modified? Readonly? Top/bot.
return stl
endfunc " stl#default

func! stl#1()
    echo 'hello'
endfunc " stl#1
" call stl#1()
