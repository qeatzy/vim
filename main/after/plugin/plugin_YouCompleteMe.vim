
try
" if match(&rtp,'ultisnips') != -1
" if bundle#has('YouCompleteMe')
    " let g:ycm_min_num_of_chars_for_completion = 3   " default 2
    let g:ycm_seed_identifiers_with_syntax=1            " to let semantic completion popup automatically
    let g:ycm_collect_identifiers_from_tags_files = 1   " add extra identifiers, not work reliably, open in buffer instead
    " try
    unlet g:ycm_filetype_blacklist['text']      " dict used as set
    " catch /.*/
    " endtry
    " how to temporarily disable/re-enable YouCompleteMe
    " let g:ycm_auto_trigger=0
    " https://github.com/ycm-core/YouCompleteMe/issues/1731
    " https://github.com/ycm-core/YouCompleteMe/issues/662
    " That's already possible; put let g:loaded_youcompleteme = 1 in your vimrc and YCM won't load.
" endif " YouCompleteMe
catch /E121/    " E121: Undefined variable: g:ycm_filetype_blacklist
endtry

