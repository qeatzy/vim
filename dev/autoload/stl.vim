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

func! stl#0()
let stl = '%{ShowCount(999)}'
let stl .= '%7*[%n]'                                " buffernr
let stl .= '%1*%-10.30f '                           " File+path
let stl .= '%2*%< %y '                              " FileType
let stl .= "%3* %{''.(&fenc!=''?&fenc:&enc).''}"    " Encoding
let stl .= '%3* %{(&bomb?",BOM":"")} '              " Encoding2
let stl .= '%4* %{(&ff=="unix"?"":&ff)} '           " FileFormat (dos/unix..) 
let stl .= '%8* %= %l/%L [%02p%%]'                  " Rownumber/total (%)
let stl .= '%9* %03c '                              " Colnr
let stl .= '%{LineCountCurrentParagraph()}'
let stl .= '%0* %{IsBuffersModified()}%r%w %P '     " Modified? Readonly? Top/bot.
let &stl = stl
endfunc " stl#0

func! stl#1()
let stl = '%{ShowCount(999)}'
let stl .= '%-'. (&columns * 7/9) .'.(%2*[%n]'      " buffernr
let stl .= '%-10.30f '                              " File+path
let stl .= '%y '                                 " FileType
let stl .= ' %{&fenc!=""?&fenc:&enc}'               " Encoding
let stl .= ' %{&ff=="unix"?"":&ff} %< '                " FileFormat (dos/unix..) 
let stl .= '%) %{strftime("%H:%M")} '
let stl .= ' %= %l/%L [%02p%%]'                     " Rownumber/total (%)
let stl .= ' %03c '                                 " Colnr
let stl .= '%{LineCountCurrentParagraph()}'
let stl .= '%0* %{IsBuffersModified()}%r%w %P '     " Modified? Readonly? Top/bot.
let &stl = stl
endfunc " stl#1
call stl#1()

finish

" excellent https://stackoverflow.com/questions/5375240/a-more-useful-statusline-in-vim

set rulerformat=%55(%{strftime('%a\ %b\ %e\ %I:%M\ %p')}\ %5l,%-6(%c%V%)\ %P%)
https://stackoverflow.com/questions/8065777/is-it-possible-to-display-the-date-time-in-vim-over-putty

let &stl = '%1*%-40.${&columns/9*7}(%-.30([%n]%-10f%) %y %(%< %{&fenc!=""?&fenc:&enc} %{(&ff=="unix"?"":&ff)}%)%)   %{strftime("%H:%M")} %= %l/%L [%02p%%] %03c %{LineCountCurrentParagraph()} %{IsBuffersModified()}%r%w %P '
let &stl = '%1*%-40.60(%-.30([%n]%-10f%) %y %(%< %{&fenc!=""?&fenc:&enc} %{(&ff=="unix"?"":&ff)}%)%)   %{strftime("%H:%M")} %= %l/%L [%02p%%] %03c %{LineCountCurrentParagraph()} %{IsBuffersModified()}%r%w %P '
set rulerformat=%55(%{strftime('%a\ %b\ %e\ %I:%M\ %p')}\ %5l,%-6(%c%V%)\ %P%)

h stl
h ruf
h tabline

for non-bottom window, statusline always show.
for bottom window, either statusline or rulerformat is show.
    rulerformat is show if, set ls=0, or 
        set ls=1 and winnr('$') == 1


rulerformat only for bottom window

leaderf
echo g:Lf_Buffer_StlCategory
echo g:Lf_Buffer_StlCwd
echo g:Lf_Buffer_StlMode
echo g:Lf_Buffer_StlResultsCount
echo g:Lf_Buffer_StlRunning
echo g:Lf_Buffer_StlTotal
echo g:Lf_StlSeparator

{'right': '◄', 'left': '►', 'font': ''}
let &stl='%#Lf_hl_Buffer_stlName# LeaderF %#Lf_hl_Buffer_stlSeparator0#%{g:Lf_StlSeparator.left}%#Lf_hl_Buffer_stlCategory# %{g:Lf_Buffer_StlCategory} %#Lf_hl_Buffer_stlSeparator1#%{g:Lf_StlSeparator.left}%#Lf_hl_Buffer_stlMode# %(%{g:Lf_Buffer_StlMode}%) %#Lf_hl_Buffer_stlSeparator2#%{g:Lf_StlSeparator.left}%#Lf_hl_Buffer_stlCwd# %<%{g:Lf_Buffer_StlCwd} %#Lf_hl_Buffer_stlSeparator3#%{g:Lf_StlSeparator.left}%=%#Lf_hl_Buffer_stlBlank#%#Lf_hl_Buffer_stlSeparator4#%{g:Lf_StlSeparator.right}%#Lf_hl_Buffer_stlLineInfo# %l/%{g:Lf_Buffer_StlResultsCount} %#Lf_hl_Buffer_stlSeparator5#%{g:Lf_StlSeparator.right}%#Lf_hl_Buffer_stlTotal# Total%{g:Lf_Buffer_StlRunning} %{g:Lf_Buffer_StlTotal}'
