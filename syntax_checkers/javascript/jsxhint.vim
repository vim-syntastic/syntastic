"============================================================================
"File:        jsxhint.vim
"Description: Javascript syntax checker - using jsxhint
"Maintainer:  Thomas Boyt <me@thomasboyt.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists('g:loaded_syntastic_javascript_jsxhint_checker')
    finish
endif
let g:loaded_syntastic_javascript_jsxhint_checker=1

if !exists('g:syntastic_jsxhint_exec')
    let g:syntastic_jsxhint_exec = 'jsxhint'
endif

if !exists('g:syntastic_javascript_jsxhint_conf')
    let g:syntastic_javascript_jsxhint_conf = ''
endif

function! SyntaxCheckers_javascript_jsxhint_IsAvailable() dict
    return executable(expand(g:syntastic_jsxhint_exec))
endfunction

function! SyntaxCheckers_javascript_jsxhint_GetLocList() dict
    let jsxhint_new = s:JsxhintNew()
    let makeprg = self.makeprgBuild({
        \ 'exe': expand(g:syntastic_jsxhint_exec),
        \ 'post_args': (jsxhint_new ? ' --verbose ' : '') . s:Args() })

    let errorformat = jsxhint_new ?
        \ '%A%f: line %l\, col %v\, %m \(%t%*\d\)' :
        \ '%E%f: line %l\, col %v\, %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr('')} })
endfunction

function! s:JsxhintNew()
    return syntastic#util#versionIsAtLeast(syntastic#util#getVersion(expand(g:syntastic_jsxhint_exec) . ' --version'), [1, 1])
endfunction

function! s:Args()
    " jsxhint uses .jshintrc as config unless --config arg is present
    return !empty(g:syntastic_javascript_jsxhint_conf) ? ' --config ' . g:syntastic_javascript_jsxhint_conf : ''
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'javascript',
    \ 'name': 'jsxhint'})

