"============================================================================
"File:        objcpp.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Val Markovic <val at markovic dot io>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
" NOTE: This plugin only supports use of the YouCompleteMe Vim plugin as the
" source of the diagnostics. If you would like to have Syntastic support without
" the use of YCM, feel free to contribute changes to this file.

if exists("loaded_objcpp_syntax_checker")
    finish
endif
let loaded_objcpp_syntax_checker = 1

if !exists('g:loaded_youcompleteme')
    finish
endif

function! SyntaxCheckers_objcpp_GetLocList()
    return youcompleteme#CurrentFileDiagnostics()
endfunction
