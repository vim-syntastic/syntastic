"============================================================================
"File:        rapper.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Sebastian Tramp <mail@sebastian.tramp.name>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

" file is build based on the given guide as well as existing checker plugins
" https://github.com/scrooloose/syntastic/wiki/Syntax-Checker-Guide

if exists('g:loaded_syntastic_trig_rapper_checker') " {{{1
    finish
else
    let g:loaded_syntastic_trig_rapper_checker = 1
endif " }}}1

" redirect trig syntax check to turtle syntax check {{{1
call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'trig',
    \ 'name': 'rapper',
    \ 'redirect': 'turtle/rapper'})
" }}}1

" vim: set sw=4 sts=4 et fdm=marker:
