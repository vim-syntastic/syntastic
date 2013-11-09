"============================================================================
"File:        eslint.vim
"Description: Javascript syntax checker - using eslint
"Maintainer:  Maksim Ryzhikov <rv.maksim at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists('g:loaded_syntastic_javascript_eslint_checker')
    finish
endif
let g:loaded_syntastic_javascript_eslint_checker=1

if !exists('g:syntastic_eslint_exec')
    let g:syntastic_eslint_exec = 'eslint'
endif

if !exists('g:syntastic_javascript_eslint_conf')
    let g:syntastic_javascript_eslint_conf = ''
endif

function! SyntaxCheckers_javascript_eslint_IsAvailable()
    return executable(expand(g:syntastic_eslint_exec))
endfunction

function! SyntaxCheckers_javascript_eslint_GetLocList()
    let makeprg = syntastic#makeprg#build({
        \ 'exe': expand(g:syntastic_eslint_exec),
        \ 'post_args': s:Args(),
        \ 'filetype': 'javascript',
        \ 'subchecker': 'eslint' })

    let errorformat =
          \ '%A%f: '.
          \ 'line %l\, '.
          \ 'col %v\, '.
          \ 'Error - %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr('')} })
endfunction

function! s:Args()
    " node-eslint uses .eslintrc as config unless --config arg is present
    return !empty(g:syntastic_javascript_eslint_conf) ? ' --config ' . g:syntastic_javascript_eslint_conf : ''
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'javascript',
    \ 'name': 'eslint'})

