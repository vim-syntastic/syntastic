"============================================================================
"File:        handlebars.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================
if exists("g:loaded_syntastic_handlebars_handlebars_checker")
    finish
endif
let g:loaded_syntastic_handlebars_handlebars_checker=1

function! SyntaxCheckers_handlebars_handlebars_IsAvailable()
    return executable('handlebars')
endfunction

function! SyntaxCheckers_handlebars_handlebars_GetLocList()
    let makeprg = syntastic#makeprg#build({
        \ 'exe': 'handlebars',
        \ 'filetype': 'handlebars',
        \ 'subchecker': 'handlebars' })

    let errorformat =
        \ 'Error: %m on line %l:,'.
        \ '%-Z%p^,' .
        \ "Error: %m,".
        \ '%-Z%p^,' .
        \ '%-G'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'handlebars',
    \ 'name': 'handlebars'})
