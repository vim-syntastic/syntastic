"============================================================================
"File:        c.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_c_syntax_checker")
    finish
endif
let loaded_c_syntax_checker = 1

if !executable("gcc")
    finish
endif

function! SyntaxCheckers_c_GetLocList()
    " only check c files
    if expand('%') =~ '.h$'
        return []
    endif
    let makeprg = 'gcc -fsyntax-only %'
    let errorformat =  '%-G%f:%s:,%f:%l: %m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

