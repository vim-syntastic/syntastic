"============================================================================
"File:        govet.vim
"Description: Perform static analysis of Go code with the vet tool
"Maintainer:  Kamil Kisiel <kamil@kamilkisiel.net>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("g:loaded_syntastic_go_govet_checker")
    finish
endif
let g:loaded_syntastic_go_govet_checker=1

function! SyntaxCheckers_go_govet_IsAvailable()
    return executable('go')
endfunction

function! SyntaxCheckers_go_govet_GetLocList()
    let makeprg = 'go vet'
    let errorformat = '%Evet: %.%\+: %f:%l:%c: %m,%W%f:%l: %m,%-G%.%#'

    " The go tool needs to either be run with an import path as an
    " argument or directly from the package directory. Since figuring out
    " the poper import path is fickle, just pushd/popd to the package.
    let popd = getcwd()
    let pushd = expand('%:p:h')
    "
    " pushd
    exec 'lcd ' . fnameescape(pushd)

    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'defaults': {'type': 'w'} })

    " popd
    exec 'lcd ' . fnameescape(popd)

    return errors
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'go',
    \ 'name': 'govet'})
