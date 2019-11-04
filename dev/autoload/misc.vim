if exists('*main#init')
    finish
endif

func! main#init() abort
    call utils#init()
endfunc " main#init

" fileencoding 是在打开文件的时候，由 Vim 进行探测后自动设置的。因此，如果出现乱码，我们无法通过在打开文件后重新设置 fileencoding 来纠正乱码。
" 编码的自动识别是通过设置 fileencodings 实现的，注意是复数形式。 因此，我们在设置 fileencodings 的时候，一定要把要求严格的、当文件不是这个编码的时候更容易出现解码失败的编码方式放在前面，把宽松的编码方式放在后面。
" 其中，ucs-bom 是一种非常严格的编码，非该编码的文件几乎没有可能被误判为 ucs-bom，因此放在第一位。
" utf-8 也相当严格，除了很短的文件外(例如许多人津津乐道的 GBK 编码的'联通'被误判为 UTF-8 编码的经典错误)，现实生活中一般文件是几乎不可能被误判的，因此放在第二位。
" 如果编码被误判了，解码后的结果就无法被人类识别，于是我们就说，这个文件乱码了。此时，如果你知道这个文件的正确编码的话，可以在打开文件的时候使用 ++enc=encoding 的方式来打开文件，如： :e ++enc=utf-8 myfile.txt     http://edyfox.codecarver.org/html/vim_fileencodings_detection.html
"encoding, mainly for compatibility with file in chinese language
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gb2312,gb18030,gbk,cp936,big5,euc-jp,euc-kr,latin1
set fileencoding=utf-8
" scriptencoding utf-8
" set termencoding
" EUC-CN可以理解为GB2312的别名，和GB2312完全相同。
" 微软的CP936通常被视为等同GBK，连 IANA 也以'CP936'为'GBK'之别名。事实上比较起来， GBK 定义之字符较 CP936 多出95字 (15个非汉字及80个汉字) 。 http://blog.wuliaoa.com/?p=503
" GB2312  1980,   GBK  1995,   GB18030-2000,  GB18030-2005
" GB2312有6763个汉字，GBK有21003个汉字，GB18030-2000有27533个汉字，GB18030-2005有70244个汉字。 http://www.fmddlmyy.cn/text24.html
" 从 ASCII、GB2312、GBK 到 GB18030，这些编码方法是向下兼容的。
" BIG5 是通行于台湾、香港地区的一个繁体字编码方案。
" ASCII 、GB2312、GBK、GB18030、unicode、UTF-8字符集编码详解  http://www.cnblogs.com/frankliiu-java/archive/2010/04/01/1702154.html
" What's different between UTF-8 and UTF-8 without BOM?  https://stackoverflow.com/questions/2223882/whats-different-between-utf-8-and-utf-8-without-bom

" :h pastetoggle
set pastetoggle=<F2>
" https://nvie.com/posts/how-i-boosted-my-vim/

