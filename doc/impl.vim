https://github.com/ycm-core/YouCompleteMe/issues/234#issuecomment-465663225
    Text properties
    1.1. :h textprop
    Byte compiled vimscript
    2.1. Part 1 - vim/vim#3857
    2.2. I think it was the first highest requested thing in the poll
    Popup windows
    3.1 Depend on text properties
    3.2. Can be used for signature help
2019-05-29 https://github.com/ycm-core/YouCompleteMe/issues/234#issuecomment-496708353
For anyone following this issue, work has begun based on: vim/vim#4063
https://github.com/vim/vim/issues/4063

https://github.com/vim/vim/issues/4063#issuecomment-473228035
One of reasons that I don't like balloon is that doesn't allow highlight.
https://github.com/vim/vim/issues/4063#issuecomment-491623499
I have added a detailed design in patch 8.1.1329. Feel free to comment.
2019-05-18  https://github.com/vim/vim/issues/4063#issuecomment-493675215
See a discussion about using a buffer instead of a List of lines: https://groups.google.com/forum/#!topic/vim_dev/6RXkRnhpMNM
below brammool commented on May 21  comment with neovim float window feature
https://github.com/vim/vim/issues/4063#issuecomment-494313795
 below https://github.com/vim/vim/issues/4063#issuecomment-495244077
A small group of users would like floating windows for editing, toplevel
GUI windows, non-tiling window layout, etc.  I think this is what Neovim
is intending to provide, and have popup windows as a side effect.
2019-05-27 https://github.com/vim/vim/issues/4063#issuecomment-496024538
Implementation has started and the design is now in runtime/doc/popup.txt.
Let's close this issue now. If you have ideas or comments regarding popup windows, please open a new issue.
https://github.com/vim/vim/issues/4063#issuecomment-496897664
I recently fixed the background color (there is a screendump test for
that).  
https://github.com/vim/vim/issues/4063#issuecomment-496920705
 Thanks, since the popup window is local to the current tabpage, is the
 winid an unique id across tabpages ?
Yes, ":help window-ID".
Popup windows can also be global, they hang around when going through
tab pages.
 how to change highlighting ??
Use text properties.
  https://github.com/vim/vim/issues/4063#issuecomment-497619429
Whether you use syntax highlighting or text properties in a popup window
is completely up to you.  You can also mix them.
  https://github.com/vim/vim/issues/4063#issuecomment-497619432
I played around with this a bit and realized that using setwinvar() for
'syntax' does not work, because setwinvar() blocks autocommands, and
setting up syntax highligting needs autocommands.  So the best way is:
	call win_execute(winid, "set syntax=python")
I added test for that.  And fixed that an unintended side effect was
that 'buftype' got reset.
  mattn https://github.com/vim/vim/issues/4063#issuecomment-499444065
@Yggdroot you can implement with filter. This is confirm dialog when open new buffer.
 06-11  https://github.com/vim/vim/issues/4063#issuecomment-500718050
someone would write a readline library for popups？
  https://github.com/vim/vim/issues/4063#issuecomment-502391905
@prabirshrestha , Scroll your content by
    call win_execute("normal \<c-e>")
    call win_execute("normal \<c-y>")
?? and bind them to <m-e> and <m-y>, you will be able to scroll your popup window without focsing.
  https://github.com/vim/vim/issues/4063#issuecomment-533992216
    Are we able to have a foating fuzzyfinder (FZF) or grep. Can't seem to figure it out.
Well the infrastructure for that is available. Needs a plugin writer for that, if there is none available yet.
  https://github.com/vim/vim/issues/4063#issuecomment-535039624
    Popup windows do not have a cursor. When you open a popup window, the focus and
the cursor stay on the window it was called from. The way to interact with a popup
window is through popup-filter.
  https://github.com/vim/vim/issues/4063#issuecomment-535111479
    Why are you trying to run a terminal window in a popup window?  It smells like
you want to show the result of some external command.  Using channel functions
for this is probably a better solution.  Or use a hidden terminal window and
copy the text to the popup window (the terminal debugger does this).


h popup.txt

14:20
Data Type added over the years
...
Funcref, Partial
Special
Job
Channel
16:00
bulitin functions
vim 7.0 213
vim 8.0 350
vim Now 402
27:06 - 27:56
few plugin use python/ruby/perl/etc/.
try to make vimscript better & faster.
33:12
plugin dependency is missing
40:10
plugin support
test with assert_functions, feedkeys(), screenshot tests.
41:04
pugin support poll

h findfile()
h finddir()
h globpath()
h glob()
h readdir()
h isdirectory()
h fnamemodify()
h filename-modifiers
echo fnamemodify('/path/to/ls.pwd/33.vim', ':h')

h setbufline()
h setline()
:d to remove lines
    https://stackoverflow.com/questions/2531132/removing-a-line-from-the-buffer-in-a-vim-script

call setline(1,a)
