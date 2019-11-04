nn Y y$
set timeout|"-- default on
set timeoutlen=200
set ttimeout|"-- default off
set ttimeoutlen=100
ino <space>s :up<CR>
nn  <Space>m    :bm<CR>
nn  <Space>;    :bm<CR>
   nn  gt          <C-^>
nn  <Esc>s      :up<CR>
nn  q           :q<CR>

    " pu=Capture('nn q')


" n  qn          * :setl bt=nofile<CR>
" n  qf          * :exec 'Ack! "\b'.expand("<cword>").'\b"'<CR>
" n  qg          * :call TogBG()<CR>
" n  qo          * <C-W><C-O>
" n  q0          * :<C-U>call HideAlternateWindow()<CR>
" n  qq          * :<C-U> call Hide_cur_window_or_quit_vim(v:count)<CR>
" n  qp          * :pclose<CR>
" n  q;          * q:k
" n  qm          * :exec '!'.g:my_man_program.shellescape(expand('<cword>')).' '.g:my_man_program_suffix.' > '.g:my_tmpdoc<CR>:redraw!<CR>:exec 'e '.g:my_tmpdoc<CR>
" n  ql          * :<C-U>call dirbufcore#dh_open('.')<CR>
" n  qj          * :exec 'silent !'.g:my_doc_program.shellescape(expand('<cword>'),1).' '.g:my_doc_program_suffix.' > '.g:my_tmpdoc<CR>:redraw!<CR>:exec 'e '.g:my_tmpdoc<CR>
" n  qk          * :exec 'silent !'.g:my_doc_program.shellescape(expand('<cWORD>'),1).' '.g:my_doc_program_suffix.' > '.g:my_tmpdoc<CR>:redraw!<CR>:exec 'e '.g:my_tmpdoc<CR>
" n  qr          * :<C-U>call Run_lines_as_shell_cmd(line('.'),v:count1)<CR>




" n  g>b           <Plug>TComment_Commentb
" n  g>c           <Plug>TComment_Commentc
" n  g>            <Plug>TComment_Comment
" n  g<b           <Plug>TComment_Uncommentb
" n  g<c           <Plug>TComment_Uncommentc
" n  g<            <Plug>TComment_Uncomment
" n  gcb           <Plug>TComment_gcb
" n  gcc           <Plug>TComment_gcc
" n  gc9c          <Plug>TComment_gc9c
" n  gc9           <Plug>TComment_gc9
" n  gc8c          <Plug>TComment_gc8c
" n  gc8           <Plug>TComment_gc8
" n  gc7c          <Plug>TComment_gc7c
" n  gc7           <Plug>TComment_gc7
" n  gc6c          <Plug>TComment_gc6c
" n  gc6           <Plug>TComment_gc6
" n  gc5c          <Plug>TComment_gc5c
" n  gc5           <Plug>TComment_gc5
" n  gc4c          <Plug>TComment_gc4c
" n  gc4           <Plug>TComment_gc4
" n  gc3c          <Plug>TComment_gc3c
" n  gc3           <Plug>TComment_gc3
" n  gc2c          <Plug>TComment_gc2c
" n  gc2           <Plug>TComment_gc2
" n  gc1c          <Plug>TComment_gc1c
" n  gc1           <Plug>TComment_gc1
" n  gc            <Plug>TComment_gc
"    gC            :'a,. s/^/ */^M:. s/\(.*\)/\1^V^V^M **************\//^M:'a s/\(.*\)/\/**************^V^V^M\1/^M
"    n  g/            gc
"    n  g[          * :TComment<CR>
"    n  gm          * Op_pos('RemoveEmptyLines')
"    n  g"          * :%v/^"[^ ]/d_<CR>
"    n  gs          * :g//p<CR>
"    n  gb          * :s/  \+/ /g<CR>
"    n  gp          * :silent! exec 'call '.Pdf_PasteAndJoinPossiblyReplace('*')<CR>
"    n  gpp         * :<C-U>call PasteAppendWithSpace()<CR>
"    n  gy          * mp'<y'>`p
"    n  g*          * search('<cWORD>')
"    n  gf          * :<C-U>call Gf_search()<CR>
"    n  gjj         * <C-W><C-X>
"    n  goo         * <C-W>W
"    n  go          * <C-W><C-W>
"    n  g9          * :blast<CR>
"    n  g0          * :bfirst<CR>
"    n  gh          * :<C-U>call Buf_go_buffer(v:count)<CR>
"    n  gr          * :<C-U>call BashLinesCapture(line('.'),v:count1)<CR>

" n  <Space>k    *@:<C-U>call Vim_help()<CR>
"    <Space>p      <Plug>(ctrlp)
"    n  <Space>k    * mo:call SetOpfunc('Tmux_send_lines')<CR>g@
"    n  <Space>j    * mo:call SetOpfunc('Tmux_send_lines_one_pass')<CR>g@
"    n  <Space>d    * :t.<CR>
"    n  <Space>,    * :s/,//gn<CR>
"    n  <Space>i    * :CtrlPBuffer<CR>
"    n  <Space>'    * :scr<CR>
"    n  <Space>w    * :pwd<CR>
"    n  <Space>o    * :<C-U>call Echo_Option_Or_Expression()<CR>
"    n  <Space>e    * :let @j = '['',()]*\([^''=, ]*\).*'<CR>:let @k = substitute(expand('<cWORD>'),@j,'\1','')<CR>:exec 'echo '@k<CR>
"    n  <Space>f    * :set nomore|:ls|:set more<CR>:b<Space>
"    n  <Space>l    * :<C-U>call Buffer_left_0_right_1(v:count1, 1)<CR>
"    n  <Space>h    * :<C-U>call Buffer_left_0_right_1(v:count1, 0)<CR>
"    n  <Space>g    * :e<CR>
"    n  <Space>b    * :call DeleteCurBufferNotCloseWindow()<CR>
"    n  <Space>r    * :call Run_lines_as_vimscript()<CR>
"    n  <Space>n    * :exec 'map ' expand('<cWORD>')<CR>
"    n  <Space>s    * :update<CR>
