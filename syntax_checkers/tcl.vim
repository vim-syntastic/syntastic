"============================================================================
"File: tcl.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer: Eric Thomas <eric.l.m.thomas at gmail dot com>
"License: This program is free software. It comes without any warranty,
" to the extent permitted by applicable law. You can redistribute
" it and/or modify it under the terms of the Do What The Fuck You
" Want To Public License, Version 2, as published by Sam Hocevar.
" See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("loaded_tcl_syntax_checker")
    finish
endif
let loaded_tcl_syntax_checker = 1

"bail if the user doesnt have tclsh installed
if !executable("tclsh")
    finish
endif

function! SyntaxCheckers_tcl_GetLocList()
    let makeprg = 'tclsh '.shellescape(expand('%'))
    let errorformat = '%f:%l:%m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
