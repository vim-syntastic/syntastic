"============================================================================
"File:        perl.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Anthony Carapetis <anthony.carapetis at gmail dot com>,
"             Eric Harmon <http://eharmon.net>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
"
" In order to add some custom lib directories that should be added to the
" perl command line you can add those to the global variable
" g:perl_lib_path.
"
"   let g:perl_lib_path = './lib'
"
if exists("loaded_perl_syntax_checker")
    finish
endif
let loaded_perl_syntax_checker = 1

"bail if the user doesnt have perl installed
if !executable("perl")
    finish
endif

" Any command line parameters needed for this program should be included in
" the variable declaration. This program should expect a single parameter;
" the fully qualified filename of the file to be checked.

if exists("g:syntastic_perl_efm_program")
    let s:checker = g:syntastic_perl_efm_program
else
    let s:checker = 'perl ' . shellescape(expand('<sfile>:p:h') . '/efm_perl.pl') . ' -c -w'
endif

function! SyntaxCheckers_perl_GetLocList()
    if exists("g:perl_lib_path")
        let makeprg = s:checker . ' -I' . g:perl_lib_path . ' ' . shellescape(expand('%'))
    else
        let makeprg = s:checker . ' ' . shellescape(expand('%'))
    endif
    let errorformat =  '%t:%f:%l:%m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
