
func! pager#filter() abort
    set noswapfile nomod nolist nospell 
    if exists('$MAN_PN')
        file $MAN_PN
        unlet $MAN_PN
        if search('\[\dm','n')
            sil! keepp %s/\[\d\{1,2\}m//g
        else
            sil! keepp %s/\(.\)\1/\1/g
            sil! keepp %s/_//g
        endif
        " set ft=man
    else
        sil! keepp g/^\s*\[/s/\[\d\%(;\d\d\?\)\?m//g
        sil! keepp g/^\s*./s/\(.\)\1/\1/g
    endif
endfunc " pager#filter

finish

export PAGER='vim --startuptime p.out --not-a-term -c "call pager#filter() | 1" -'

https://github.com/vim/vim/issues/2823

Usually, MANPAGER expects nroff-processed text as its input, e.g., N^HNA^HAM^HME^HE for NAME (bold), and _^Hg_^Hi_^Ht for git (underlined), where ^H is <C-H>.

On the other hand, according to the screenshot, those byte strings are somehow converted into the escape sequences starting with ^[[1m and ^[[4m, respectively, where ^[ is <Esc>. The former renders characters in bold, and the latter does them underlined.

https://vi.stackexchange.com/questions/4682/how-can-i-suppress-the-reading-from-stdin-message-from-within-vim/4687#4687
@DennisWilliamson See the changelog by :help version8.txt. --not-a-term option itself was added in 7.4.1419 and its behavior was changed to also suppress the Reading from stdin... message in 8.0.1308. (By the way, the N files to edit message is also be suppressed from 8.1.1258) – ynn Oct 20 at 15:13

https://unix.stackexchange.com/questions/15855/how-to-dump-a-man-page
https://vim.fandom.com/wiki/Using_vim_as_a_man-page_viewer_under_Unix
