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

    let makeprg .= s:CheckGtk()

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

" search for a gtk include statement in the first 50 lines
" if true, try to find the gtk headers with 'pkg-config'
function! s:CheckGtk()
    if executable('pkg-config')
        for i in range(50)
            if getline(i) =~? '^#include.*\%(gtk\|glib\)'
                if !exists('s:gtk_flags')
                    let s:gtk_flags = system('pkg-config --cflags gtk+-2.0')
                    let s:gtk_flags = ' '.s:gtk_flags
                endif
                return s:gtk_flags
            endif
        endfor
    endif
    return ''
endfunction
