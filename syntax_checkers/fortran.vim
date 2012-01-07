"============================================================================
"File:        fortran.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Karl Yngve Lervåg <karl.yngve@lervag.net>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"Note:        This syntax checker uses gfortran with the option -fsyntax-only
"             to check for errors and warnings. Additional flags may be
"             supplied through both local and global variables,
"               b:syntastic_fortran_flags,
"               g:syntastic_fortran_flags.
"             This is particularly useful when the source requires module files
"             in order to compile (that is when it needs modules defined in
"             separate files).
"
"============================================================================

if exists("loaded_fortran_syntax_checker")
    finish
endif
let loaded_fortran_syntax_checker = 1

"bail if the user doesnt have fortran installed
if !executable("gfortran")
    finish
endif

if !exists('g:syntastic_fortran_flags')
    let g:syntastic_fortran_flags = ''
endif

function! SyntaxCheckers_fortran_GetLocList()
    let makeprg  = 'gfortran -fsyntax-only'
    let makeprg .= g:syntastic_fortran_flags
    if exists('b:syntastic_fortran_flags')
        let makeprg .= b:syntastic_fortran_flags
    endif
    let makeprg .= ' ' . shellescape(expand('%'))
    let errorformat = '%-C %#,%-C  %#%.%#,%A%f:%l.%c:,%Z%m,%G%.%#'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
