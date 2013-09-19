"============================================================================
"File:        coffeelint.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Lingliang Zhang (lingliangz@gmail.com)
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("g:loaded_syntastic_litcoffee_coffeelint_checker")
    finish
endif
let g:loaded_syntastic_litcoffee_coffeelint_checker=1

function! SyntaxCheckers_litcoffee_coffeelint_IsAvailable()
    return executable('coffeelint')
endfunction

function! SyntaxCheckers_litcoffee_coffeelint_GetLocList()
    let makeprg = syntastic#makeprg#build({
        \ 'exe': 'coffeelint',
        \ 'args': '--csv',
        \ 'filetype': 'litcoffee',
        \ 'subchecker': 'coffeelint' })

    let errorformat =
        \ '%f\,%l\,%\d%#\,%trror\,%m,' .
        \ '%f\,%l\,%trror\,%m,' .
        \ '%f\,%l\,%\d%#\,%tarn\,%m,' .
        \ '%f\,%l\,%tarn\,%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype': 'Style',
        \ 'returns': [0, 1] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'litcoffee',
    \ 'name': 'coffeelint'})
