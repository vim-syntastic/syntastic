"============================================================================
"File:        elixir.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Richard Ramsden <rramsden at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
function! SyntaxCheckers_elixir_elixir_IsAvailable()
    return executable('elixir')
endfunction

function! SyntaxCheckers_elixir_elixir_GetLocList()
    let makeprg = syntastic#makeprg#build({ 'exe': 'elixir' })
    let errorformat = '** %*[^\ ] %f:%l: %m'

    let elixir_results = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    if !empty(elixir_results)
        return elixir_results
    endif
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'elixir',
    \ 'name': 'elixir'})
