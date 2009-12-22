"============================================================================
"File:        c.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Gregor Uhlenheuer <kongo2002 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

" in order to also check header files add this to your .vimrc:
" (this usually creates a .gch file in your source directory)
"
"   let g:syntastic_c_check_header = 1

if exists('loaded_c_syntax_checker')
    finish
endif
let loaded_c_syntax_checker = 1

if !executable('gcc')
    finish
endif

function! SyntaxCheckers_c_GetLocList()
    let makeprg = 'gcc -fsyntax-only %'
    let errorformat =  '%-G%f:%s:,%f:%l: %m'

    if expand('%') =~? '.h$'
        if exists('g:syntastic_c_check_header')
            let makeprg = 'gcc -c %'
        else
            return []
        endif
    endif

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
