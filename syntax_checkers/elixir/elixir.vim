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
if exists("g:loaded_syntastic_elixir_elixir_checker")
    finish
endif
let g:loaded_syntastic_elixir_elixir_checker=1

let s:syntastic_elixir_compile_command = 'elixir'

function! SyntaxCheckers_elixir_elixir_IsAvailable()
    if s:syntastic_elixir_compile_command == 'elixir'
        return executable('elixir')
    else
        return executable('mix')
    endif
endfunction

function! SyntaxCheckers_elixir_elixir_GetLocList()

    let s:syntastic_elixir_compile_command = 'elixir'

    let mix_file = syntastic#util#findInParent('mix.exs', expand('%:p:h'))

    if filereadable(mix_file)
        let s:syntastic_elixir_compile_command = 'mix compile'
        let cwd = fnamemodify(mix_file, ':p:h')
    else
        let cwd = expand('%:p:h')
    endif

    let makeprg = syntastic#makeprg#build({
        \ 'exe': s:syntastic_elixir_compile_command,
        \ 'filetype': 'elixir',
        \ 'subchecker': 'elixir' })

    let errorformat = '** %*[^\ ] %f:%l: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'cwd': cwd })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'elixir',
    \ 'name': 'elixir'})
